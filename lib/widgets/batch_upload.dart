import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/export_template.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class BatchUpload extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onUpload;

  BatchUpload({required this.onUpload});

  @override
  _BatchUploadState createState() => _BatchUploadState();
}

class _BatchUploadState extends State<BatchUpload> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('driversAccount');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? errorMessage;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  double? _selectedFileSize;
  bool _isUploading = false;

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
        _selectedFileSize =
            result.files.single.bytes!.lengthInBytes / (1024 * 1024); // In MB
        errorMessage = null;
      });
    } else {
      _setError('No file selected.');
    }
  }

  void _processExcelFile() {
    if (_selectedFileBytes == null) {
      _setError('Please select a file to upload.');
      return;
    }

    var spreadsheet = excel.Excel.decodeBytes(_selectedFileBytes!);
    List<Map<String, dynamic>> data = [];
    errorMessage = null;

    for (var table in spreadsheet.tables.keys) {
      if (spreadsheet.tables[table]!.rows.isNotEmpty) {
        for (int rowIndex = 1;
            rowIndex < spreadsheet.tables[table]!.rows.length;
            rowIndex++) {
          var row = spreadsheet.tables[table]!.rows[rowIndex];

          String birthdate = row[2]?.value?.toString() ?? '';
          String idNumber = row[3]?.value?.toString() ?? '';
          String bodyNumber = row[4]?.value?.toString() ?? '';
          String phoneNumber = row[6]?.value?.toString() ?? '';
          String email = row[7]?.value?.toString() ?? '';
          String codingScheme = row[8]?.value?.toString() ?? '';
          String tag = row[9]?.value?.toString() ?? '';

          final driverData = {
            'uid': '',
            'firstName': row[0]?.value?.toString(),
            'lastName': row[1]?.value?.toString(),
            'birthdate': birthdate,
            'idNumber': idNumber,
            'bodyNumber': bodyNumber,
            'address': row[5]?.value?.toString(),
            'phoneNumber': phoneNumber,
            'email': email,
            'driverPhoto': '',
            'status': "active",
            'codingScheme' : codingScheme ,
            'tag': tag,
            'totalRatings': {
              'averageRating': 5,
              'ratingCount': 0,
              'ratingSum': 0,
            },
          };
          data.add(driverData);
        }
      }
    }

    _createUserAccountsAndUploadData(context, data);
  }

  Future<void> _createUserAccountsAndUploadData(
      BuildContext context, List<Map<String, dynamic>> data) async {
    setState(() {
      _isUploading = true;
    });

    for (var driverData in data) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: driverData['email'],
          password: driverData['birthdate'],
        );

        driverData['uid'] = userCredential.user?.uid ?? '';

        await _databaseRef.push().set(driverData);

        widget.onUpload(data);

        _setError(null);

        await _addAuditLogEntry(
            "Batch uploaded driver data for ${driverData['firstName']} ${driverData['lastName']}");
      } on FirebaseAuthException catch (e) {
        _setError(e.message ?? 'An error occurred during user creation.');
      } catch (e) {
        _setError('An unknown error occurred.');
      }
    }

    setState(() {
      _isUploading = false;
    });
  }

  Future<void> _addAuditLogEntry(String action) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('audit_logs').add({
        'adminId': user.uid,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _setError(String? message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Important: Download the export template and follow its format.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: CustomButtonStyles.elevatedButtonStyle,
              onPressed: () {
                ExcelTemplateDownloader.downloadExcelTemplate(context);
              },
              child: const Text('Export Template'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: CustomButtonStyles.elevatedButtonStyle,
              onPressed: () {
                _pickFile(context);
              },
              child: const Text('Import File'),
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 10),
              Text(
                'File: $_selectedFileName (${_selectedFileSize!.toStringAsFixed(2)} MB)',
                style: const TextStyle(color: Colors.green),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              style: CustomButtonStyles.elevatedButtonStyle,
              onPressed: _selectedFileBytes != null && !_isUploading
                  ? _processExcelFile
                  : null,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Upload'),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
