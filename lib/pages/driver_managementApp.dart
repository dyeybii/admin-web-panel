import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AddDriverUserPage extends StatefulWidget {
  static const String id = "webPageDriverManagement";

  const AddDriverUserPage({Key? key}) : super(key: key);

  @override
  State<AddDriverUserPage> createState() => _AddDriverUserPageState();
}

class _AddDriverUserPageState extends State<AddDriverUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  List<Map<String, dynamic>> _driverUsers = []; // Define _driverUsers list

  @override
  void initState() {
    super.initState();
    _fetchDriverUsers(); // Call method to fetch driver users from Firestore
  }

  void _fetchDriverUsers() {
    _firestore
        .collection('driverUsers')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _driverUsers = querySnapshot.docs
            .where((doc) => doc.exists) // Check if document exists
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    });
  }

  void _addDriverUser() async {
    await _firestore.collection('driverUsers').add({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'birthdate': _birthdateController.text,
      'idNumber': _idNumberController.text,
      'bodyNumber': _bodyNumberController.text,
      'email': _emailController.text,
      'status': _statusController.text,
    });
    _fetchDriverUsers(); // Fetch updated list of driver users
    _clearControllers();
  }

  void _clearControllers() {
    _firstNameController.clear();
    _lastNameController.clear();
    _birthdateController.clear();
    _idNumberController.clear();
    _bodyNumberController.clear();
    _emailController.clear();
    _statusController.clear();
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
                    return AlertDialog(
                      title: Text('Add New User'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              decoration: InputDecoration(labelText: 'Birthdate'),
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
                            TextField(
                              controller: _statusController,
                              decoration: InputDecoration(labelText: 'Status'),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addDriverUser();
                            Navigator.of(context).pop();
                          },
                          child: Text('Add User'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("+ Add new User"),
            ),
            SizedBox(height: 16.0),
            // Table to display added driver users
            DataTable(
              columns: const [
                DataColumn(label: Text('First Name')),
                DataColumn(label: Text('Last Name')),
                DataColumn(label: Text('Birthdate')),
                DataColumn(label: Text('ID Number')),
                DataColumn(label: Text('Body Number')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Status')),
              ],
              rows: _buildUserRows(),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildUserRows() {
    return _driverUsers.map((user) {
      return DataRow(cells: [
        DataCell(Text(user['firstName'])),
        DataCell(Text(user['lastName'])),
        DataCell(Text(user['birthdate'])),
        DataCell(Text(user['idNumber'])),
        DataCell(Text(user['bodyNumber'])),
        DataCell(Text(user['email'])),
        DataCell(Text(user['status'])),
      ]);
    }).toList();
  }
}
