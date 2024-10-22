import 'dart:typed_data';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/Data_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // For Firebase Realtime Database
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
                  width: 300,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      labelStyle: const TextStyle(
                        color: Color(0xFF2E3192),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF2E3192), // Outline color
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(
                              0xFF2E3192), // Outline color when not clicked
                          width: 2.0, // Optional: Adjust width
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color:
                              Color(0xFF2E3192), // Outline color when clicked
                          width: 2.0, // Optional: Adjust width
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF2E3192), // Icon color
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(
                          255, 255, 255, 255), // Background color
                    ),
                  ),
                ),
              ),
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
              iconEnabledColor: Color(0xFF2E3192), // Set the arrow color
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
                ExcelTemplateDownloader.downloadExcelTemplate(context);
              },
              child: const Text('Export Template'),
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
              child: const Text('Download Table'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: CustomButtonStyles.elevatedButtonStyle,
              onPressed: () {
                // Show the BatchUpload dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Batch Upload'),
                      content: SizedBox(
                        height: 300, // Set the desired height here
                        width: 200,
                        child: BatchUpload(
                          onUpload: (List<Map<String, dynamic>> uploadedData) {
                            // Handle the uploaded data if necessary
                            print('Uploaded Data: $uploadedData');
                            Navigator.of(context)
                                .pop(); // Close the dialog after upload
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Batch Upload',
              ),
            ),
            const SizedBox(width: 20),
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
              selectedDrivers: _selectedDrivers,
              onSelectedDriversChanged: (List<DriversAccount> selected) {
                setState(() {
                  _selectedDrivers = selected;
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
            ),
          ),
        );
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
    final String driverPhoto = _driverPhotoController.text
        .trim(); // This should be the image path or image URL.

    Uint8List? imageBytes; // Prepare this if you are uploading an image
    String?
        imageFileName; // This should be the file name if you are uploading an image

    try {
      // Create the user in Firebase Auth using email and birthdate as password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: birthdate);

      final String uid = userCredential.user!.uid;

      // Create a new reference for the driver in the Realtime Database
      final newDriverRef = _dataService
          .getDriversDatabaseReference()
          .push(); // Generates a unique key

      // Use the unique key from Firebase as the driverId
      final String driverId = newDriverRef.key!;

      // Create a new driver account object
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
        driverPhoto: driverPhoto, // This should be the image URL if available
        driverId: driverId, // Assign the auto-generated driverId
      );

      // Add the new driver to Firebase Realtime Database with the generated driverId
      await newDriverRef.set(newDriver.toJson());

      // Optionally, you can upload an image if available
      if (imageBytes != null && imageFileName != null) {
        await _dataService.uploadImage(imageBytes, imageFileName);
      }

      _fetchDriversData(); // Refresh the drivers list
      Navigator.of(context).pop(); // Close the dialog after adding
    } catch (e) {
      print('Error adding driver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding driver: $e')),
      );
    }
  }
}
