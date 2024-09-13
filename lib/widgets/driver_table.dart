import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/Style/data_grid_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:data_table_2/data_table_2.dart';

class DriverTable extends StatefulWidget {
  final List<DriversAccount> driversAccountList;

  const DriverTable({Key? key, required this.driversAccountList}) : super(key: key);

  @override
  _DriverTableState createState() => _DriverTableState();
}

class _DriverTableState extends State<DriverTable> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController searchController = TextEditingController();
  List<DriversAccount> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = widget.driversAccountList;
    searchController.addListener(_filterDriverList);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterDriverList() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredList = widget.driversAccountList.where((driver) {
        return driver.firstName.toLowerCase().contains(query) ||
               driver.lastName.toLowerCase().contains(query) ||
               driver.idNumber.toLowerCase().contains(query) ||
               driver.bodyNumber.toLowerCase().contains(query) ||
               driver.tag.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _filterDriverList();
                },
              ),
            ),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: DataTable2(
                    columns: const [
                      DataColumn2(label: Text('First Name')),
                      DataColumn2(label: Text('Last Name')),
                      DataColumn2(label: Text('ID Number')),
                      DataColumn2(label: Text('Body Number')),
                      DataColumn2(label: Text('Tag')),
                    ],
                    rows: filteredList.map((driver) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(driver.firstName)),
                          DataCell(Text(driver.lastName)),
                          DataCell(Text(driver.idNumber)),
                          DataCell(Text(driver.bodyNumber)),
                          DataCell(Text(driver.tag)),
                        ],
                        onSelectChanged: (selected) {
                          if (selected != null && selected) {
                            _showDriverDetailsDialog(driver, context);
                          }
                        },
                      );
                    }).toList(),
                    border: TableBorder(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    headingRowColor: MaterialStateColor.resolveWith((states) => const Color.fromARGB(255, 145, 179, 230)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    dataRowHeight: 60,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverDetailsDialog(DriversAccount driver, BuildContext context) {
    // Controllers
    TextEditingController firstNameController = TextEditingController(text: driver.firstName);
    TextEditingController lastNameController = TextEditingController(text: driver.lastName);
    TextEditingController idNumberController = TextEditingController(text: driver.idNumber);
    TextEditingController bodyNumberController = TextEditingController(text: driver.bodyNumber);
    TextEditingController emailController = TextEditingController(text: driver.email);
    TextEditingController birthdateController = TextEditingController(text: driver.birthdate);
    TextEditingController addressController = TextEditingController(text: driver.address);
    TextEditingController phoneNumberController = TextEditingController(text: driver.phoneNumber);
    TextEditingController codingSchemeController = TextEditingController(text: driver.codingScheme);
    TextEditingController tagController = TextEditingController(text: driver.tag);
    TextEditingController driverPhotosController = TextEditingController(text: driver.driverPhotos);

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          driverPhotosController.text = pickedFile.path;
        });
      }
    }

     void _updateDriverData() async {
      try {
        await _firestore
            .collection('DriversAccount')
            .doc(driver.driverId)
            .update({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'idNumber': idNumberController.text,
          'bodyNumber': bodyNumberController.text,
          'email': emailController.text,
          'birthdate': birthdateController.text,
          'address': addressController.text,
          'phoneNumber': phoneNumberController.text,
          'codingScheme': codingSchemeController.text,
          'tag': tagController.text,
          'driver_photos': driverPhotosController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $e')),
        );
      }
    }

    void _deleteDriverData() async {
      try {
        await _firestore
            .collection('DriversAccount')
            .doc(driver.driverId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
    // Show Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildDialogTitle(context),
          content: _buildDialogContent(driver, driverPhotosController, _pickImage),
          actions: <Widget>[
            TextButton(
              onPressed: _deleteDriverData,
              child: const Text('Delete Account'),
            ),
            ElevatedButton(
              onPressed: _updateDriverData,
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Personal Information'),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDialogContent(DriversAccount driver, TextEditingController driverPhotosController, Future<void> Function() _pickImage) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileImage(driver.driverPhotos, _pickImage),
          const SizedBox(height: 20),
          Form(
            child: Column(
              children: [
                _buildEditableTextField('First Name', driver.firstName),
                _buildEditableTextField('Last Name', driver.lastName),
                _buildEditableTextField('ID Number', driver.idNumber),
                _buildEditableTextField('Body Number', driver.bodyNumber),
                _buildEditableTextField('Email', driver.email),
                _buildEditableTextField('Date of Birth', driver.birthdate),
                _buildEditableTextField('Address', driver.address),
                _buildEditableTextField('Phone Number', driver.phoneNumber),
                _buildEditableTextField('Coding Scheme', driver.codingScheme),
                _buildEditableTextField('Tag', driver.tag),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, Future<void> Function() _pickImage) {
    return InkWell(
      onTap: _pickImage,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildEditableTextField(String labelText, String initialValue) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(labelText: labelText),
        controller: TextEditingController(text: initialValue),
      ),
    );
  }

  Future<List<DriversAccount>> _fetchDrivers() async {
    // Implement fetching the updated driver list from both Firebase Realtime Database and Firestore if needed
    return widget.driversAccountList; // Dummy return for now
  }
}
