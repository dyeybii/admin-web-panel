import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';
import 'package:admin_web_panel/widgets/batch_upload.dart';
import 'package:admin_web_panel/widgets/export_template.dart';
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
  List<DriversAccount> _filteredDriversList = [];
  String selectedTagFilter = 'All'; // To track the selected filter
    DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> tripsData = []; // List to hold trip data


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _driverPhotoController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _driverIdController = TextEditingController();

  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchDriversData();
    searchController.addListener(_filterDrivers);
  }

  Future<void> _fetchDriversData() async {
    List<DriversAccount> driversList = await _getDriversFromRealtimeDatabase();
    if (mounted) {
      setState(() {
        _driversAccountList = driversList;
        _filteredDriversList = driversList;
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

  void _filterDrivers() {
    setState(() {
      String query = searchController.text.toLowerCase();
      _filteredDriversList = _driversAccountList.where((driver) {
        final matchesSearch = driver.firstName.toLowerCase().contains(query) ||
            driver.lastName.toLowerCase().contains(query) ||
            driver.idNumber.toLowerCase().contains(query) ||
            driver.bodyNumber.toLowerCase().contains(query);

        final matchesTag = selectedTagFilter == 'All' || driver.tag == selectedTagFilter;
        
        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  void _filterByTag(String? tag) {
    setState(() {
      selectedTagFilter = tag ?? 'All';
      _filterDrivers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _bodyNumberController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _tagController.dispose();
    _driverPhotoController.dispose();
    _uidController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Members and Operators'),
              Center(
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: [
            DropdownButton<String>(
              value: selectedTagFilter,
              items: ['All', 'Operator', 'Member'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _filterByTag,
              underline: Container(), // To remove default dropdown underline
            ),
            ElevatedButton(
              onPressed: _showAddMemberDialog,
              child: const Text('Add Member'),
            ),
            const SizedBox(width: 10),
                        ElevatedButton(
              onPressed: () {
                ExcelTemplateDownloader.downloadExcelTemplate(context);
              },
              child: const Text('Export Template'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                ExcelDownloader.downloadExcel(context, _driversAccountList);
              },
              child: const Text('Download Excel'),
            ),
            const SizedBox(width: 10),
            BatchUpload(
  onUpload: (List<Map<String, dynamic>> uploadedDrivers) {
    List<DriversAccount> driversList = uploadedDrivers.map((driverData) {
      return DriversAccount.fromJson(driverData);
    }).toList();

    _handleBatchUpload(driversList); // Call your function with the correct type
  },
),
        ]),
        
        body: StreamBuilder<DatabaseEvent>(
          stream: _databaseRef.child('driversAccount').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('No drivers found.'));
            }

            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final driversList = data.entries.map((entry) {
              return DriversAccount.fromJson(Map<String, dynamic>.from(entry.value));
            }).toList();

            return DriverTable(
              driversAccountList: _filteredDriversList.isNotEmpty ? _filteredDriversList : driversList,
            );
          },
        ),
      ),
    );
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
              tagController: _tagController,
              uidController: _uidController,
              driverPhotoController: _driverPhotoController,
              ontagSelected: (tag) {
                _tagController.text = tag!;
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
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: 'defaultPassword123',
      );
      String uid = userCredential.user!.uid;
      DatabaseReference ref = _databaseRef.child('driversAccount').child(uid);
      DriversAccount newDriver = DriversAccount(
        driverId: _driverIdController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        idNumber: _idNumberController.text,
        bodyNumber: _bodyNumberController.text,
        email: _emailController.text,
        birthdate: _birthdateController.text,
        address: _addressController.text,
        phoneNumber: _phoneNumberController.text,
        tag: _tagController.text,
        driverPhoto: _driverPhotoController.text,
        uid: uid,
      );
      await ref.set(newDriver.toJson());

      Navigator.of(context).pop();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add driver: $e')),
      );
    }
  }

void _handleBatchUpload(List<DriversAccount> uploadedDrivers) {
  setState(() {
    _driversAccountList.addAll(uploadedDrivers);
    _filterDrivers();
  });
}

}

