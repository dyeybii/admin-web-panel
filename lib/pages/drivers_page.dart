import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:admin_web_panel/Data_service.dart';
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

  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

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
              const Text('Members and Operator'),
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
                        borderRadius: BorderRadius.circular(40),
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
              )
            ],
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh,
                  color: Color(0xFF2E3192)), // Updated refresh button color
              onPressed: _fetchDriversData,
            ),
            DropdownButton<String>(
              value: selectedTagFilter,
              items: ['All', 'Operator', 'Member'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: const TextStyle(
                          color:
                              Color(0xFF2E3192))), // Updated filter text color
                );
              }).toList(),
              onChanged: _filterByTag,
              underline: Container(),
            ),
            ElevatedButton(
              onPressed: _showAddMemberDialog,
              child: const Text('Add Driver'),
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
                  ExcelDownloader.downloadExcel(
                      context, _driversAccountList, _selectedDrivers);
                } else {
                  ExcelDownloader.downloadExcel(
                      context, _driversAccountList, []);
                }
              },
              child: const Text('Download Excel'),
            ),
            const SizedBox(width: 10),
            BatchUpload(
              onUpload: (List<Map<String, dynamic>> uploadedDrivers) {
                List<DriversAccount> driversList = uploadedDrivers
                    .map((driverData) => DriversAccount.fromJson(driverData))
                    .where((driver) => driver != null)
                    .cast<DriversAccount>()
                    .toList();

                _handleBatchUpload(driversList);
              },
            ),
            const SizedBox(
              width: 10,
              height: 10,
            )
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
      driverPhoto: _driverPhotoController
          .text, // Assuming this is a URL or a placeholder
      driverId: _driverIdController.text,
    );

    try {
      Uint8List? imageBytes = await _pickImage(); // Pick the image
      String? imageFileName = _getFileName(); // Get the file name

      if (imageBytes != null && imageFileName != null) {
        await _dataService.addDriverToRealtimeDatabase(
            newDriver, imageBytes, imageFileName);
        _fetchDriversData();
        Navigator.of(context).pop(); // Close the dialog after adding
      } else {
        // Handle the case where image is not selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      print('Error adding driver: $e');
    }
  }

  Future<Uint8List?> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes(); // Read the image as bytes
    }
    return null; // Return null if no image was picked
  }

  String? _getFileName() {
    // Implement a way to retrieve the file name if needed
    return null; // Return a file name or null if not applicable
  }

  void _handleBatchUpload(List<DriversAccount> driversList) async {
    try {
      await _dataService.batchUploadDrivers(driversList);
      _fetchDriversData();
    } catch (e) {
      print('Error in batch upload: $e');
    }
  }
}
