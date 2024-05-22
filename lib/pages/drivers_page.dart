import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';
import 'package:admin_web_panel/widgets/batch_upload.dart';
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
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _codingSchemeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _driverPhotoController = TextEditingController();

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
      driversList.add(DriversAccount.fromJson(doc.data() as Map<String, dynamic>));
    }

    return driversList;
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Driver'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
              driverPhotoController: _driverPhotoController, 
              onRoleSelected: (role) {
                _tagController.text = role!;
              },
              onAddPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addMemberToFirestore();
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
        );
      },
    );
  }

  void _addMemberToFirestore() {
    // Extracting data from text controllers
    String? firstName = _firstNameController.text.isNotEmpty ? _firstNameController.text : null;
    String? lastName = _lastNameController.text.isNotEmpty ? _lastNameController.text : null;
    String? idNumber = _idNumberController.text.isNotEmpty ? _idNumberController.text : null;
    String? bodyNumber = _bodyNumberController.text.isNotEmpty ? _bodyNumberController.text : null;
    String? email = _emailController.text.isNotEmpty ? _emailController.text : null;
    String? birthdate = _birthdateController.text.isNotEmpty ? _birthdateController.text : null;
    String? address = _addressController.text.isNotEmpty ? _addressController.text : null;
    String? emergencyContact = _emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : null;
    String? codingScheme = _codingSchemeController.text.isNotEmpty ? _codingSchemeController.text : null;
    String tag = _tagController.text.isNotEmpty ? _tagController.text : '';
    String? driverPhoto = _driverPhotoController.text.isNotEmpty ? _driverPhotoController.text : null; // Get driver photo

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
      'driverPhoto': driverPhoto,
    }).then((value) {
      print('Member added to Firestore');
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error adding member to Firestore: $error');
    });
  }

  void _handleBatchUpload(List<Map<String, dynamic>> data) {
    for (var driverData in data) {
      FirebaseFirestore.instance.collection('DriversAccount').add(driverData).then((docRef) {
        print('Driver added with ID: ${docRef.id}');
      }).catchError((error) {
        print('Error adding driver data to Firestore: $error');
      });
    }
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
            const SizedBox(width: 10),
            BatchUpload(onUpload: _handleBatchUpload),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('DriversAccount').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<DriversAccount> driversList = snapshot.data!.docs
              .map((doc) => DriversAccount.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
            return DriverTable(driversAccountList: driversList);
          },
        ),
      ),
    );
  }
}
