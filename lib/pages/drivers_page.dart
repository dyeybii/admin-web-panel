import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';
import 'package:admin_web_panel/widgets/batch_upload.dart';
import 'package:admin_web_panel/widgets/export_template.dart';

class DriversPage extends StatefulWidget {
  static const String id = "/webPageDrivers";

  const DriversPage({Key? key}) : super(key: key);

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<DriversAccount> _driversAccountList = [];
  List<DriversAccount> _filteredDriversList = [];
  List<DriversAccount> _selectedDrivers =
      []; 
  String selectedTagFilter = 'All'; 

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
      driversList = data.entries
          .map((entry) =>
              DriversAccount.fromJson(Map<String, dynamic>.from(entry.value)))
          .where((driver) => driver != null)
          .cast<DriversAccount>()
          .toList();
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

        final matchesTag =
            selectedTagFilter == 'All' || driver.tag == selectedTagFilter;

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
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchDriversData, 
            ),
            DropdownButton<String>(
              value: selectedTagFilter,
              items: ['All', 'Operator', 'Member'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _filterByTag,
              underline: Container(), 
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
                
                if (_selectedDrivers.isNotEmpty) {
                  
                  ExcelDownloader.downloadExcel(context, _driversAccountList,
                      _selectedDrivers);
                } else {
                  
                  ExcelDownloader.downloadExcel(context, _driversAccountList,
                      []); 
                }
              },
              child: const Text('Download Excel'),
            ),
            const SizedBox(width: 10),
            BatchUpload(
              onUpload: (List<Map<String, dynamic>> uploadedDrivers) {
                List<DriversAccount> driversList = uploadedDrivers
                    .map((driverData) {
                      return DriversAccount.fromJson(driverData);
                    })
                    .where((driver) => driver != null)
                    .cast<DriversAccount>()
                    .toList();

                _handleBatchUpload(driversList);
              },
            ),
          ],
        ),
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
            final driversList = data.entries
                .map((entry) => DriversAccount.fromJson(
                    Map<String, dynamic>.from(entry.value)))
                .where((driver) => driver != null)
                .cast<DriversAccount>()
                .toList();

            return DriverTable(
              driversAccountList: _filteredDriversList.isNotEmpty
                  ? _filteredDriversList
                  : driversList,
              selectedDrivers:
                  _selectedDrivers, 
              onSelectedDriversChanged: (List<DriversAccount> selected) {
                setState(() {
                  _selectedDrivers =
                      selected;
                });
              },
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
          )),
        );
      },
    );
  }

  Future<void> _addMemberToFirebaseAndRealtimeDatabase() async {
    final newDriver = DriversAccount(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      idNumber: _idNumberController.text,
      bodyNumber: _bodyNumberController.text,
      email: _emailController.text,
      birthdate: _birthdateController.text,
      address: _addressController.text,
      phoneNumber: _phoneNumberController.text,
      tag: _tagController.text,
      uid: _uidController.text,
      driverPhoto: _driverPhotoController.text,
      driverId: _driverIdController.text,
    );
    await _databaseRef.child('driversAccount').push().set(newDriver.toJson());

    _firstNameController.clear();
    _lastNameController.clear();
    _idNumberController.clear();
    _bodyNumberController.clear();
    _emailController.clear();
    _birthdateController.clear();
    _addressController.clear();
    _phoneNumberController.clear();
    _tagController.clear();
    _uidController.clear();
    _driverPhotoController.clear();

    Navigator.of(context).pop(); 
    _fetchDriversData(); 
  }

  void _handleBatchUpload(List<DriversAccount> driversList) {
    for (var driver in driversList) {
      _databaseRef.child('driversAccount').push().set(driver.toJson());
    }
    _fetchDriversData();
  }
}
