import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BatchUpload extends StatelessWidget {
  final Function(List<Map<String, dynamic>>) onUpload;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('driversAccount');

  BatchUpload({required this.onUpload});

  Future<void> _pickFileAndUpload(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      var bytes = result.files.single.bytes!;
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> data = [];

      for (var table in excel.tables.keys) {
        if (excel.tables[table]!.rows.isNotEmpty) {
          for (int rowIndex = 1;
              rowIndex < excel.tables[table]!.rows.length;
              rowIndex++) {
            var row = excel.tables[table]!.rows[rowIndex];

            final driverData = {
              'firstName': row[0]?.value?.toString(),
              'lastName': row[1]?.value?.toString(),
              'birthdate': row[2]?.value?.toString(),
              'idNumber': row[3]?.value?.toString(),
              'bodyNumber': row[4]?.value?.toString(),
              'address': row[5]?.value?.toString(),
              'phoneNumber': row[6]?.value?.toString(),
              'email': row[7]?.value?.toString(),
              'tag': row[8]?.value?.toString(),
            };
            data.add(driverData);
          }
        }
      }


      await _createUserAccountsAndUploadData(context, data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }

  Future<void> _createUserAccountsAndUploadData(
      BuildContext context, List<Map<String, dynamic>> data) async {
    for (var driverData in data) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: driverData['email'],
          password: driverData['birthdate'], 
        );


        await _databaseRef.push().set(driverData);

        print('User created: ${userCredential.user?.email}');

 
        onUpload(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch upload and user creation completed.')),
        );
      } on FirebaseAuthException catch (e) {
        _showAlertDialog(context, e.message ?? 'An error occurred');
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _pickFileAndUpload(context),
      child: const Text('Batch Upload'),
    );
  }
}
