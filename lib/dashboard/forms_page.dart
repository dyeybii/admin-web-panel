import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPopUp extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
          TextField(
            controller: _birthdateController,
            decoration:const InputDecoration(labelText: 'BirthDate'),
          ),
          TextField(
            controller: _idNumberController,
            decoration:const InputDecoration(labelText: 'ID Number'),
          ),
          TextField(
            controller: _bodyNumberController,
            decoration:const InputDecoration(labelText: 'Body Number'),
          ),
          TextField(
            controller: _emailController,
            decoration:const InputDecoration(labelText: 'Email'),
          ),
          // Add more text fields for other user information
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final newUser = {
              'firstName': _firstNameController.text,
              'lastName': _lastNameController.text,
              'birthDate': _birthdateController.text,
              'idNumber': _idNumberController.text,
              'bodyNumber': _bodyNumberController.text,
              'email': _emailController.text,
            };

            try {
              // Add user data to Firestore
              await _firestore.collection('users').add(newUser);
              print('User added to Firestore: $newUser');
              // Optionally, show a success message
            } catch (e) {
              print('Error adding user to Firestore: $e');
              // Handle error (e.g., display error message)
            }

            // Close the pop-up
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),

        TextButton(
          onPressed: () {
            // Close the pop-up without saving
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
