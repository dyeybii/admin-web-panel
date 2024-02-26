import 'package:flutter/material.dart';

import '../dashboard/forms_page.dart';

class AddDriverUserPage extends StatefulWidget {
  static const String id = "webPageDriverManagement"; // Removed the backslash

  const AddDriverUserPage({super.key});

  @override
  State<AddDriverUserPage> createState() => _AddDriverUserPageState();
}

class _AddDriverUserPageState extends State<AddDriverUserPage> {
  final List<Map<String, dynamic>> _driverUsers = []; // List to store added driver users
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  void _addDriverUser() {
    setState(() {
      _driverUsers.add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'birthdate': _birthdateController.text,
        'idNumber': _idNumberController.text,
        'bodyNumber': _bodyNumberController.text,
        'email': _emailController.text,
        'status': _statusController.text,
      });
      // Clear text fields after adding the user
      _firstNameController.clear();
      _lastNameController.clear();
      _birthdateController.clear();
      _idNumberController.clear();
      _bodyNumberController.clear();
      _emailController.clear();
      _statusController.clear();
    });
  }

  void _deleteUser(int index) {
    setState(() {
      _driverUsers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Driver User"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddUserPopUp(); // Show the pop-up
                  },
                );
              },
              child: Text("+ Add new User"),
            ),
            SizedBox(height: 16.0),
            // Form fields for adding driver users
            // Your existing form fields...
            SizedBox(height: 16.0),
            // Table to display added driver users
            DataTable(
              columns: [
                DataColumn(label: Text('First Name')),
                DataColumn(label: Text('Last Name')),
                DataColumn(label: Text('Birthdate')),
                DataColumn(label: Text('ID Number')),
                DataColumn(label: Text('Body Number')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')), // Column for actions (edit/delete)
              ],
              rows: _driverUsers.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                return DataRow(cells: [
                  DataCell(Text(user['firstName'])),
                  DataCell(Text(user['lastName'])),
                  DataCell(Text(user['birthdate'])),
                  DataCell(Text(user['idNumber'])),
                  DataCell(Text(user['bodyNumber'])),
                  DataCell(Text(user['email'])),
                  DataCell(Text(user['status'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navigate to edit screen
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteUser(index); // Delete user
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
