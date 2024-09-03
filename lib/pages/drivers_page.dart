import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';
import 'package:admin_web_panel/widgets/batch_upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _codingSchemeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _driverPhotoController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();

  final TextEditingController _adminEmailController = TextEditingController(); // Add these
  final TextEditingController _adminPasswordController = TextEditingController(); // Add these

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
              phoneNumberController: _phoneNumberController,
              codingSchemeController: _codingSchemeController,
              tagController: _tagController,
              driver_photosController: _driverPhotoController,
              uidController: _uidController,
              onRoleSelected: (role) {
                _tagController.text = role!;
              },
              onAddPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addMemberToFirebaseAndFirestore();
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

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Admin'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _adminEmailController,
                decoration: const InputDecoration(labelText: 'Admin Email *'),
              ),
              TextField(
                controller: _adminPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Admin Password *'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add function to create admin
                },
                child: const Text('Add Admin'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMemberToFirebaseAndFirestore() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: 'defaultPassword', // Ideally, use a secure method to generate this
      );

      String uid = userCredential.user!.uid;

      FirebaseFirestore.instance.collection('DriversAccount').doc(uid).set({
        'uid': uid,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'idNumber': _idNumberController.text,
        'bodyNumber': _bodyNumberController.text,
        'email': _emailController.text,
        'birthdate': _birthdateController.text,
        'address': _addressController.text,
        'phoneNumber': _phoneNumberController.text,
        'codingScheme': _codingSchemeController.text,
        'tag': _tagController.text,
        'driverPhoto': _driverPhotoController.text,
      }).then((value) {
        print('Member added to Firestore');
        Navigator.of(context).pop();
      });
    } catch (e) {
      print('Error adding member to Firebase or Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
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
              onPressed: _showAddAdminDialog, // Show Add Admin dialog
              child: const Text('Add Admin'),
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
          stream: FirebaseFirestore.instance
              .collection('DriversAccount')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<DriversAccount> driversList = snapshot.data!.docs
                .map((doc) =>
                    DriversAccount.fromJson(doc.data() as Map<String, dynamic>))
                .toList();
            return DriverTable(driversAccountList: driversList);
          },
        ),
      ),
    );
  }

  void _handleBatchUpload(List<Map<String, dynamic>> data) {
    for (var driverData in data) {
      FirebaseFirestore.instance
          .collection('DriversAccount')
          .add(driverData)
          .then((docRef) {
        print('Driver added with ID: ${docRef.id}');
      }).catchError((error) {
        print('Error adding driver data to Firestore: $error');
      });
    }
  }
}
