import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/data_service.dart';
import 'package:admin_web_panel/responsive/driver_form_desktop.dart';
import 'package:admin_web_panel/widgets/blacklist.dart';
import 'package:admin_web_panel/widgets/log_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/drivers_form.dart';

class DriversPageDesktop extends StatefulWidget {
  static const String id = "/webPageDrivers";

  const DriversPageDesktop({Key? key}) : super(key: key);

  @override
  State<DriversPageDesktop> createState() => _DriversPageDesktopState();
}

class _DriversPageDesktopState extends State<DriversPageDesktop> {
  bool isLoading = false;
  bool noResultsFound = false;
  final DataService _dataService = DataService();
  List<DriversAccount> _driversAccountList = [];
  List<DriversAccount> _filteredDriversList = [];
  List<DriversAccount> _selectedDrivers = [];
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
  final TextEditingController _codingSchemeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _driverIdController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDriversData();
    searchController.addListener(_filterDrivers);
  }

  Future<void> _fetchDriversData() async {
    try {
      List<DriversAccount> driversList =
          await _dataService.getDriversFromRealtimeDatabase();
      if (mounted) {
        setState(() {
          _driversAccountList = driversList;
          _filteredDriversList = driversList;
        });
      }
    } catch (e) {
      print('Error fetching drivers: $e');
    }
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
    _driverIdController.dispose();
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
                    width: 250,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by Name',
                        labelStyle: TextStyle(color: Color(0xFF2E3192)),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2E3192), width: 2.0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2E3192), width: 2.0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF2E3192), width: 2.0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        suffixIcon:
                            Icon(Icons.search, color: Color(0xFF2E3192)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF2E3192)),
                onPressed: _fetchDriversData,
              ),
              DropdownButton<String>(
                value: selectedTagFilter,
                items: ['All', 'Operator', 'Member'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Color(0xFF2E3192))),
                  );
                }).toList(),
                onChanged: _filterByTag,
                underline: Container(),
                iconEnabledColor: const Color(0xFF2E3192),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: CustomButtonStyles.elevatedButtonStyle,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return BlacklistDialog();
                    },
                  );
                },
                child: const Text('Blacklist'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: CustomButtonStyles.elevatedButtonStyle,
                onPressed: _showAddMemberDialog,
                child: const Text('+ Add Driver'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: CustomButtonStyles.elevatedButtonStyle,
                onPressed: () {
                  if (_selectedDrivers.isNotEmpty) {
                    ExcelDownloader.downloadExcel(
                        context, _driversAccountList, _selectedDrivers);
                  } else {
                    ExcelDownloader.downloadExcel(
                        context, _driversAccountList, []);
                  }
                },
                child: const Text('Export to csv'),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: StreamBuilder<DatabaseEvent>(
            stream: _dataService.getDriversStream(),
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

              final data = snapshot.data!.snapshot.value;

              if (data is Map<dynamic, dynamic>) {
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
                  selectedDrivers: _selectedDrivers,
                  onSelectedDriversChanged: (List<DriversAccount> selected) {
                    setState(() {
                      _selectedDrivers = selected;
                    });
                  },
                );
              } else {
                return const Center(child: Text('Unexpected data format.'));
              }
            },
          )),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2E3192),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add new Driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            content: Container(
              child: DriversFormDesktop(
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
                codingSchemeController: _codingSchemeController,
                statusController: _statusController,
                onTagSelected: (tag) {
                  _tagController.text = tag!;
                },
                onAddPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addMemberToFirebaseAndRealtimeDatabase();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content:
                              const Text('Please fill in all required fields.'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ));
      },
    );
  }

    Future<void> _addMemberToFirebaseAndRealtimeDatabase() async {
    final String email = _emailController.text.trim();
    final String birthdate = _birthdateController.text.trim();
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String idNumber = _idNumberController.text.trim();
    final String bodyNumber = _bodyNumberController.text.trim();
    final String address = _addressController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();
    final String tag = _tagController.text.trim();
    final String codingScheme = _codingSchemeController.text.trim();
    final String status = _statusController.text.trim().isEmpty
        ? "active"
        : _statusController.text.trim();
    final String driverPhoto = _driverPhotoController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: birthdate);

      final String uid = userCredential.user!.uid;

      final newDriverRef = _dataService.getDriversDatabaseReference().push();

      final String driverId = newDriverRef.key!;

      final newDriver = DriversAccount(
        firstName: firstName,
        lastName: lastName,
        idNumber: idNumber,
        bodyNumber: bodyNumber,
        email: email,
        birthdate: birthdate,
        address: address,
        phoneNumber: phoneNumber,
        tag: tag,
        uid: uid,
        codingScheme: codingScheme,
        status: status,
        driverPhoto: driverPhoto,
        driverId: driverId, 
      );

    
      await newDriverRef.set(newDriver.toJson());

       // Send email verification
    await _sendEmailVerification(userCredential.user!);

      _fetchDriversData(); 
      Navigator.of(context).pop(); 
    } catch (e) {
      print('Error adding driver: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error adding driver: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  
  Future<void> _sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBarStyles.success('Verification email sent!'),
      );
    } catch (e) {
      print('Error sending email verification: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBarStyles.error('Error sending verification email: $e'),
      );
    }
  }
}
