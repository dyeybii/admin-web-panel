import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class BatchUpload extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onUpload;

  BatchUpload({required this.onUpload});

  @override
  _BatchUploadState createState() => _BatchUploadState();
}

class _BatchUploadState extends State<BatchUpload> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('driversAccount');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? errorMessage;
  bool _isDragging = false;
  String? _selectedFileName;

  Future<void> _pickFileAndUpload(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      _processExcelFile(result.files.single.bytes!);
    } else {
      _setError('No file selected.');
    }
  }

  void _processExcelFile(Uint8List bytes) {
    var spreadsheet = excel.Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> data = [];
    errorMessage = null;

    for (var table in spreadsheet.tables.keys) {
      if (spreadsheet.tables[table]!.rows.isNotEmpty) {
        for (int rowIndex = 1; rowIndex < spreadsheet.tables[table]!.rows.length; rowIndex++) {
          var row = spreadsheet.tables[table]!.rows[rowIndex];

          String birthdate = row[2]?.value?.toString() ?? '';
          String idNumber = row[3]?.value?.toString() ?? '';
          String bodyNumber = row[4]?.value?.toString() ?? '';
          String phoneNumber = row[6]?.value?.toString() ?? '';
          String email = row[7]?.value?.toString() ?? '';
          String tag = row[8]?.value?.toString() ?? '';

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

  Future<void> _createUserAccountsAndUploadData(BuildContext context, List<Map<String, dynamic>> data) async {
    for (var driverData in data) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: driverData['email'],
          password: driverData['birthdate'],
        );

        driverData['uid'] = userCredential.user?.uid ?? '';

        await _databaseRef.push().set(driverData);

        widget.onUpload(data);

        _setError(null);

        await _addAuditLogEntry("Batch uploaded driver data for ${driverData['firstName']} ${driverData['lastName']}");
      } on FirebaseAuthException catch (e) {
        _setError(e.message ?? 'An error occurred during user creation.');
      } catch (e) {
        _setError('An unknown error occurred.');
      }
    }
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
    return GestureDetector(
      onTap: () {
        _pickFileAndUpload(context);
      },
      child: DragTarget<html.File>(
        onWillAcceptWithDetails: (data) {
          setState(() {
            _isDragging = true;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _isDragging = false;
          });
        },
        onAccept: (html.File data) async {
          setState(() {
            _isDragging = false;
            _selectedFileName = data.name;
          });

          final reader = html.FileReader();
          reader.readAsArrayBuffer(data);

          reader.onLoadEnd.listen((event) {
            if (reader.result != null) {
              Uint8List bytes = reader.result as Uint8List;
              _processExcelFile(bytes);
            }
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isDragging ? Colors.blue.shade50 : Colors.white,
              border: Border.all(
                color: _isDragging ? Colors.blue : Colors.grey,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.file_upload, size: 50, color: Colors.blue),
                const Text(
                  'Click here to submit files (Use only Excel file .xlsx)',
                  style: TextStyle(color: Colors.blue),
                ),
                if (_selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Selected file: $_selectedFileName',
                      style: const TextStyle(color: Colors.green),
                    ),
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
          );
        },
      ),
    );
  }
}
