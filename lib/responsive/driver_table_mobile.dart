import 'package:admin_web_panel/data_service.dart';
import 'package:admin_web_panel/responsive/driver_form_mobile.dart';
import 'package:admin_web_panel/responsive/edit_form_mobile.dart';
import 'package:admin_web_panel/widgets/blacklist.dart';
import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:admin_web_panel/widgets/drivers_account.dart';

class DriverTableMobile extends StatefulWidget {
  final List<DriversAccount> driversAccountList;
  final List<DriversAccount> selectedDrivers;
  final DataService _dataService = DataService();
  final Function(List<DriversAccount>) onSelectedDriversChanged;

  DriverTableMobile({
    Key? key,
    required this.driversAccountList,
    required this.selectedDrivers,
    required this.onSelectedDriversChanged,
  }) : super(key: key);

  @override
  _DriverTableMobileState createState() => _DriverTableMobileState();
}

class _DriverTableMobileState extends State<DriverTableMobile> {
  late List<DriversAccount> filteredList;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
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

  bool isAllSelected = false;

@override
void initState() {
  super.initState();
  
  filteredList = widget.driversAccountList
      .where((driver) => driver.firstName.isNotEmpty)
      .toList();
  isAllSelected = widget.selectedDrivers.length == filteredList.length;
  _fetchDriversData();
}

Future<void> _fetchDriversData() async {
  try {
    // Fetch data from service
    List<DriversAccount> driversList = await widget._dataService.fetchDrivers();
    if (mounted) {
      setState(() {
        filteredList = driversList.where((driver) => driver.firstName.isNotEmpty).toList();
      });
    }
  } catch (e) {
    print('Error fetching drivers: $e');
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      
      actions: [
        Checkbox(
          value: isAllSelected,
          onChanged: (bool? value) {
            setState(() {
              isAllSelected = value!;
              if (isAllSelected) {
                widget.selectedDrivers.clear();
                widget.selectedDrivers.addAll(filteredList);
              } else {
                widget.selectedDrivers.clear();
              }
              widget.onSelectedDriversChanged(widget.selectedDrivers);
            });
          },
        ),
        const Text("Select All"),
      ],
    ),
    body: filteredList.isEmpty
        ? Center(child: Text('No drivers available'))
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final driver = filteredList[index];
              final isSelected = widget.selectedDrivers.contains(driver);
              final textColor = driver.tag == 'Operator' ? Colors.red : Colors.blue;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          widget.selectedDrivers.add(driver);
                        } else {
                          widget.selectedDrivers.remove(driver);
                        }
                        widget.onSelectedDriversChanged(widget.selectedDrivers);
                        isAllSelected =
                            widget.selectedDrivers.length == filteredList.length;
                      });
                    },
                  ),
                  title: Text(
                    "${driver.firstName} ${driver.lastName}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: _buildDriverDetails(driver, textColor),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _showEditDialog(context, driver),
                  ),
                ),
              );
            },
          ),
    floatingActionButton: _buildSpeedDial(), // Add SpeedDial here
  );
}


 Widget _buildDriverDetails(DriversAccount driver, Color textColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Check if driverPhoto is not empty or null
          if (driver.driverPhoto.isNotEmpty)
            Image.network(driver.driverPhoto, height: 50, width: 50)
          else
            // If driverPhoto is empty or null, use the default avatar
            Image.asset('images/default_avatar.png', height: 50, width: 50),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID No: ${driver.idNumber}"),
                Text("Body No: ${driver.bodyNumber}"),
                Text(
                  "Tag: ${driver.tag}",
                  style: TextStyle(color: textColor),
                ),
                Text("Status: ${driver.status}"),
                Row(
                  children: _buildRatingWithStar(driver.totalRatings?.averageRating),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}


  SpeedDial _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Colors.blue,
      overlayOpacity: 0.5,
      spacing: 10,
      spaceBetweenChildren: 8,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.block),
          label: 'Blacklist',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return BlacklistDialog();
              },
            );
          },
          backgroundColor: Colors.red,
        ),
        SpeedDialChild(
          child: const Icon(Icons.download),
          label: 'Export to CSV',
          onTap: () {
            if (widget.selectedDrivers.isNotEmpty) {
              ExcelDownloader.downloadExcel(
                  context, widget.driversAccountList, widget.selectedDrivers);
            } else {
              ExcelDownloader.downloadExcel(
                  context, widget.driversAccountList, []);
            }
          },
          backgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: const Icon(Icons.info),
          label: 'Add TODA Driver',
          onTap: _showAddMemberDialog,
          backgroundColor: Colors.purple,
        ),
      ],
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
              child: DriversFormMobile(
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

  void _showEditDialog(BuildContext context, DriversAccount driver) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
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
                          'Edit Information',
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
                  Expanded(
                    child: EditDriverFormMobile(
                      driverId: driver.uid,
                      firstName: driver.firstName,
                      lastName: driver.lastName,
                      idNumber: driver.idNumber,
                      bodyNumber: driver.bodyNumber,
                      email: driver.email,
                      birthdate:
                          driver.birthdate.isNotEmpty ? driver.birthdate : '',
                      address: driver.address.isNotEmpty ? driver.address : '',
                      phoneNumber: driver.phoneNumber,
                      tag: driver.tag,
                      codingScheme: driver.codingScheme,
                      driverPhoto: driver.driverPhoto.isNotEmpty
                          ? driver.driverPhoto
                          : '',
                    ),
                  ),
                ],
              ),
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
    final String codingScheme = _codingSchemeController.text.trim();
    final String status = _statusController.text.trim();

    final String driverPhoto = _driverPhotoController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: birthdate);

      final String uid = userCredential.user!.uid;

      final newDriverRef =
          widget._dataService.getDriversDatabaseReference().push();

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

  List<Widget> _buildRatingWithStar(double? averageRating) {
    double rating = averageRating ?? 0.0;

    String ratingText = rating.toStringAsFixed(1);

    return [
      Text(ratingText),
      const Icon(Icons.star, color: Colors.yellow),
    ];
  }

  Future<void> _sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent!')),
      );
    } catch (e) {
      print('Error sending email verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending verification email: $e')),
      );
    }
  }
  // Other methods like `_showAddMemberDialog`, `_showEditDialog`, and `_addMemberToFirebaseAndRealtimeDatabase` remain unchanged.
}
