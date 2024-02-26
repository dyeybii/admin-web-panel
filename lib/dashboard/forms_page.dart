import 'package:flutter/material.dart';

class AddUserPopUp extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Last Name'),
          ),
          TextField(
            controller: _birthdateController,
            decoration: InputDecoration(labelText: 'BirthDate'),
          ),
          TextField(
            controller: _idNumberController,
            decoration: InputDecoration(labelText: 'ID Number'),
          ),
          TextField(
            controller: _bodyNumberController,
            decoration: InputDecoration(labelText: 'Body Number'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          // Add more text fields for other user information
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final newUser = {
              'firstName': _firstNameController.text,
              'lastName': _lastNameController.text,
              'birthDate': _birthdateController.text,
              'idNumber': _idNumberController.text,
              'bodyNumber': _bodyNumberController.text,
              'email': _emailController.text,
            };

            // Print the new user data for debugging
            print(newUser);

            // Save the user information and close the pop-up
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
