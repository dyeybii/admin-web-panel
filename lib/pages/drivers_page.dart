import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:excel/excel.dart';

class DriversPage extends StatefulWidget {
  static const String id = "/webPageDrivers";

  const DriversPage({Key? key}) : super(key: key);

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  late List<DriversAccount> driversAccountList;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Members and Operators'),
          automaticallyImplyLeading: false,
          actions: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.blue,
                        title: const Text(
                          'Add New Member',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter first name';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter last name';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    maxLength: 4,
                                    controller: _idNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'ID Number',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter ID number';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    maxLength: 4,
                                    controller: _bodyNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'Body Number',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter body number';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    maxLength: 8,
                                    controller: _birthdateController,
                                    decoration: const InputDecoration(
                                      labelText: 'Birthdate',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter birthdate';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Address',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter address';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    maxLength: 11,
                                    controller: _emergencyContactController,
                                    decoration: const InputDecoration(
                                      labelText: 'Emergency Contact',
                                      labelStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter emergency contact';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          Container(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  FirebaseDatabase.instance
                                      .ref()
                                      .child('driversAccount')
                                      .push()
                                      .set({
                                    'firstName': _firstNameController.text,
                                    'lastName': _lastNameController.text,
                                    'idNumber': _idNumberController.text,
                                    'bodyNumber': _bodyNumberController.text,
                                    'email': _emailController.text,
                                    'birthdate': _birthdateController.text,
                                    'address': _addressController.text,
                                    'emergencyContact':
                                        _emergencyContactController.text,
                                  })
                                      .then((_) {
                                    _firstNameController.clear();
                                    _lastNameController.clear();
                                    _idNumberController.clear();
                                    _bodyNumberController.clear();
                                    _emailController.clear();
                                    _birthdateController.clear();
                                    _addressController.clear();
                                    _emergencyContactController.clear();
                                    Navigator.of(context).pop();
                                  })
                                      .catchError((error) {
                                    print('Error adding user: $error');
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add user.'),
                                      ),
                                    );
                                  });
                                }
                              },
                              child: const Text(
                                'Add',
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _firstNameController.clear();
                              _lastNameController.clear();
                              _idNumberController.clear();
                              _bodyNumberController.clear();
                              _emailController.clear();
                              _birthdateController.clear();
                              _addressController.clear();
                              _emergencyContactController.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'Add Member',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _downloadExcel,
              child: const Text('Download Excel'),
            ),
          ],
        ),
        body: FutureBuilder<List<DriversAccount>>(
          future: generateDriversAccountList(),
          builder: (BuildContext context,
              AsyncSnapshot<List<DriversAccount>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              driversAccountList = snapshot.data ?? [];
              if (driversAccountList.isNotEmpty) {
                print("Data retrieved successfully: $driversAccountList");
              } else {
                print("No data retrieved from Firebase");
              }

              return SfDataGrid(
                allowSorting: true,
                sortingGestureType: SortingGestureType.tap,
                source: DriversDataSource(driversAccountList),
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'firstName', label: const Text('First Name')),
                  GridColumn(
                      columnName: 'lastName', label: const Text('Last Name')),
                  GridColumn(
                      columnName: 'idNumber', label: const Text('ID Number')),
                  GridColumn(
                      columnName: 'bodyNumber', label: const Text('Body Number')),
                  GridColumn(
                      columnName: 'email', label: const Text('Email')),
                  GridColumn(
                      columnName: 'birthdate', label: const Text('Birthdate')),
                  GridColumn(
                      columnName: 'address', label: const Text('Address')),
                  GridColumn(
                      columnName: 'emergencyContact',
                      label: const Text('Emergency Contact')),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<DriversAccount>> generateDriversAccountList() async {
    final databaseReference =
        FirebaseDatabase.instance.ref().child('driversAccount');

    try {
      final snapshot = await databaseReference.once();
      DataSnapshot dataSnapshot = snapshot.snapshot;

      List<DriversAccount> driversAccountList = [];

      Map<dynamic, dynamic> values =
          dataSnapshot.value as Map<dynamic, dynamic>? ?? {};
      values.forEach((key, value) {
        if (value != null && value is Map<String, dynamic>) {
          driversAccountList.add(DriversAccount.fromJson(value));
        } else {
          print('Invalid data found for key $key');
        }
      });

      print("Data mapped successfully: $driversAccountList");

      return driversAccountList;
    } catch (e) {
      print('Error fetching data from Firebase: $e');
      return [];
    }
  }

  Future<void> _downloadExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    final List<List<dynamic>> excelData = [];

    excelData.add([
      'First Name',
      'Last Name',
      'ID Number',
      'Body Number',
      'Email',
      'Birthdate',
      'Address',
      'Emergency Contact',
    ]);

    driversAccountList.forEach((driver) {
      excelData.add([
        driver.firstName,
        driver.lastName,
        driver.idNumber,
        driver.bodyNumber,
        driver.email,
        driver.birthdate,
        driver.address,
        driver.emergencyContact,
      ]);
    });

    for (var row in excelData) {
      sheet.appendRow(
        row.map((cellValue) => TextCellValue(cellValue.toString())).toList(),
      );
    }

    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final filePath = '${directory.path}/drivers_data.xlsx';
      final fileBytes = excel.encode();

      File(filePath).writeAsBytesSync(fileBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel file downloaded: $filePath'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to access storage for download.'),
        ),
      );
    }
  }
}

class DriversAccount {
  factory DriversAccount.fromJson(Map<String, dynamic> json) {
    try {
      return DriversAccount(
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        idNumber: json['idNumber']?.toString() ?? '',
        bodyNumber: json['bodyNumber']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        birthdate: json['birthdate']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        emergencyContact: json['emergencyContact']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing driver account data: $e');
      return DriversAccount.empty();
    }
  }

  DriversAccount({
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.bodyNumber,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.emergencyContact,
  });

  DriversAccount.empty()
      : firstName = '',
        lastName = '',
        idNumber = '',
        bodyNumber = '',
        email = '',
        birthdate = '',
        address = '',
        emergencyContact = '';

  final String firstName;
  final String lastName;
  final String idNumber;
  final String bodyNumber;
  final String email;
  final String birthdate;
  final String address;
  final String emergencyContact;
}

class DriversDataSource extends DataGridSource {
  DriversDataSource(this.driversAccountList) {
    buildDataGridRows();
  }

  final List<DriversAccount> driversAccountList;
  List<DataGridRow> dataGridRows = [];

  void buildDataGridRows() {
    dataGridRows = driversAccountList.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'firstName', value: data.firstName.toString()),
        DataGridCell<String>(
            columnName: 'lastName', value: data.lastName.toString()),
        DataGridCell<String>(
            columnName: 'idNumber', value: data.idNumber.toString()),
        DataGridCell<String>(
            columnName: 'bodyNumber', value: data.bodyNumber.toString()),
        DataGridCell<String>(
            columnName: 'email', value: data.email.toString()),
        DataGridCell<String>(
            columnName: 'birthdate', value: data.birthdate.toString()),
        DataGridCell<String>(
            columnName: 'address', value: data.address.toString()),
        DataGridCell<String>(
            columnName: 'emergencyContact',
            value: data.emergencyContact.toString()),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[0].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[1].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[3].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[4].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[5].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[6].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[7].value,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
