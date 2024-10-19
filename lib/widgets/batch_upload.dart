import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel; // Prefix added to avoid conflicts
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:typed_data'; // For Uint8List
import 'dart:html' as html; // For handling drag-and-drop in Flutter Web

class BatchUpload extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onUpload;

  BatchUpload({required this.onUpload});

  @override
  _BatchUploadState createState() => _BatchUploadState();
}

class _BatchUploadState extends State<BatchUpload> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('driversAccount');
  String? errorMessage;
  bool _isDragging = false;
  String? _selectedFileName;

  // Handle file picking and uploading
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

  // Helper function to process the Excel file
  void _processExcelFile(Uint8List bytes) {
    var spreadsheet = excel.Excel.decodeBytes(bytes); // Use the excel prefix

    List<Map<String, dynamic>> data = [];
    errorMessage = null; // Clear previous error message

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

          // Create driver data with additional fields
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

  // Create user accounts and upload data
  Future<void> _createUserAccountsAndUploadData(BuildContext context, List<Map<String, dynamic>> data) async {
    for (var driverData in data) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: driverData['email'],
          password: driverData['birthdate'], // Example: Use birthdate as default password
        );

        // Add UID to driverData
        driverData['uid'] = userCredential.user?.uid ?? '';

        // Upload to Firebase
        await _databaseRef.push().set(driverData);

        widget.onUpload(data); // Notify parent widget

        _setError(null); // Clear error message after successful upload
      } on FirebaseAuthException catch (e) {
        _setError(e.message ?? 'An error occurred during user creation.');
      } catch (e) {
        _setError('An unknown error occurred.');
      }
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
        _pickFileAndUpload(context); // Correctly passing BuildContext in a closure
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
            _selectedFileName = data.name; // Update the file name
          });

          // Read the file using FileReader
          final reader = html.FileReader();
          reader.readAsArrayBuffer(data); // Read file as bytes

          reader.onLoadEnd.listen((event) {
            if (reader.result != null) {
              Uint8List bytes = reader.result as Uint8List;
              _processExcelFile(bytes); // Process the Excel file
            }
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: EdgeInsets.all(20),
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
                Icon(Icons.file_upload, size: 50, color: Colors.blue),
                Text(
                  'Drag & drop files here or browse files',
                  style: TextStyle(color: Colors.blue),
                ),
                if (_selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Selected file: $_selectedFileName',
                      style: TextStyle(color: Colors.green),
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
