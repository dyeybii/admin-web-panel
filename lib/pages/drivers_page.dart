import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';
import 'package:admin_web_panel/widgets/batch_upload.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  final TextEditingController _adminEmailController = TextEditingController(); 
  final TextEditingController _adminPasswordController = TextEditingController(); 

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchDriversData();
  }

  Future<void> _fetchDriversData() async {
    List<DriversAccount> driversList = await _getDriversFromRealtimeDatabase();
    if (mounted) {
      setState(() {
        _driversAccountList = driversList;
      });
    }
  }

  Future<List<DriversAccount>> _getDriversFromRealtimeDatabase() async {
    List<DriversAccount> driversList = [];
    final snapshot = await _databaseRef.child('driversAccount').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      driversList = data.entries.map((entry) {
        return DriversAccount.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
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
                  _addMemberToFirebaseAndRealtimeDatabase();
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

  Future<void> _addMemberToFirebaseAndRealtimeDatabase() async {
    try {
      // Attempt to create a new user with the provided email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: 'defaultPassword', // Consider prompting the user for a password or using a more secure method
      );

      String uid = userCredential.user!.uid;

      // Store user details in Realtime Database
      await _databaseRef.child('driversAccount').child(uid).set({
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
        'driverPhotos': _driverPhotoController.text,
        'role': 'driver', // Ensure this is set correctly
        'deviceToken': '', // Set appropriately or remove if not used
        'driverId': '', // Set appropriately or remove if not used
      }).then((_) {
        print('Member added to Realtime Database');
        Navigator.of(context).pop();
      }).catchError((error) {
        print('Error writing to Realtime Database: $error');
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The email address is already in use by another account.'),
          ),
        );
      } else {
        print('Error adding member to Firebase or Realtime Database: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
          ),
        );
      }
    } catch (e) {
      print('Error adding member to Firebase or Realtime Database: $e');
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
              onPressed: _showAddAdminDialog, 
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
        body: StreamBuilder<DatabaseEvent>(
          stream: _databaseRef.child('driversAccount').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('No drivers found.'));
            }

            final Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final List<DriversAccount> driversList = data.entries.map((entry) {
              return DriversAccount.fromJson(Map<String, dynamic>.from(entry.value));
            }).toList();

            print('Drivers List: $driversList');

            return Expanded(
              child: DriverTable(driversAccountList: driversList),
            );
          },
        ),
      ),
    );
  }

  void _handleBatchUpload(List<Map<String, dynamic>> data) {
    for (var driverData in data) {
      _databaseRef.child('driversAccount').push().set(driverData).then((_) {
        print('Driver added with data: $driverData');
      }).catchError((error) {
        print('Error adding driver data to Realtime Database: $error');
      });
    }
  }
}
