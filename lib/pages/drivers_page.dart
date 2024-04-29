import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriversPage extends StatefulWidget {
  static const String id = "/webPageDrivers";

  const DriversPage({Key? key}) : super(key: key);

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<DriversAccount> _driversAccountList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _codingSchemeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  String _selectedRole = '';

  @override
  void initState() {
    super.initState();
    _fetchDriversData();
  }

  Future<void> _fetchDriversData() async {
    List<DriversAccount> driversList = await _getDriversFromFirestore();
    if (mounted) {
      setState(() {
        _driversAccountList = driversList;
      });
    }
  }

  Future<List<DriversAccount>> _getDriversFromFirestore() async {
    List<DriversAccount> driversList = [];

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('DriversAccount').get();
    for (var doc in snapshot.docs) {
      driversList
          .add(DriversAccount.fromJson(doc.data() as Map<String, dynamic>));
    }

    return driversList;
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: SingleChildScrollView(
            child: DriversForm(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              idNumberController: _idNumberController,
              bodyNumberController: _bodyNumberController,
              emailController: _emailController,
              birthdateController: _birthdateController,
              addressController: _addressController,
              emergencyContactController: _emergencyContactController,
              codingSchemeController: _codingSchemeController,
              tagController: _tagController,
              onRoleSelected: (role) {
                setState(() {
                  _selectedRole = role;
                  _tagController.text = role;
                });
              },
              onAddPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Extracting data from text controllers
                  String firstName = _firstNameController.text;
                  String lastName = _lastNameController.text;
                  String idNumber = _idNumberController.text;
                  String bodyNumber = _bodyNumberController.text;
                  String email = _emailController.text;
                  String birthdate = _birthdateController.text;
                  String address = _addressController.text;
                  String emergencyContact = _emergencyContactController.text;
                  String codingScheme = _codingSchemeController.text;
                  String tag = _tagController.text;

                  // Adding member to Firestore
                  FirebaseFirestore.instance.collection('DriversAccount').add({
                    'firstName': firstName,
                    'lastName': lastName,
                    'idNumber': idNumber,
                    'bodyNumber': bodyNumber,
                    'email': email,
                    'birthdate': birthdate,
                    'address': address,
                    'emergencyContact': emergencyContact,
                    'codingScheme': codingScheme,
                    'tag': tag,
                  }).then((value) {
                    print('Member added to Firestore');
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print('Error adding member to Firestore: $error');
                    // Handle error if needed
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields.'),
                    ),
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Extracting data from text controllers
                  String firstName = _firstNameController.text;
                  String lastName = _lastNameController.text;
                  String idNumber = _idNumberController.text;
                  String bodyNumber = _bodyNumberController.text;
                  String email = _emailController.text;
                  String birthdate = _birthdateController.text;
                  String address = _addressController.text;
                  String emergencyContact = _emergencyContactController.text;
                  String codingScheme = _codingSchemeController.text;
                  String tag = _tagController.text;

                  // Adding member to Firestore
                  FirebaseFirestore.instance.collection('DriversAccount').add({
                    'firstName': firstName,
                    'lastName': lastName,
                    'idNumber': idNumber,
                    'bodyNumber': bodyNumber,
                    'email': email,
                    'birthdate': birthdate,
                    'address': address,
                    'emergencyContact': emergencyContact,
                    'codingScheme': codingScheme,
                    'tag': tag,
                  }).then((value) {
                    print('Member added to Firestore');
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print('Error adding member to Firestore: $error');
                    // Handle error if needed
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields.'),
                    ),
                  );
                }
              },
              child: const Text('Add Member'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Members and Operators'),
          automaticallyImplyLeading: false,
          actions: [
            ElevatedButton(
              onPressed: _showAddMemberDialog,
              child: const Text('Add Member'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                ExcelDownloader.downloadExcel(context, _driversAccountList);
              },
              child: const Text('Download Excel'),
            ),
          ],
        ),
        body: _driversAccountList.isNotEmpty
            ? DriverTable(driversAccountList: _driversAccountList)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
