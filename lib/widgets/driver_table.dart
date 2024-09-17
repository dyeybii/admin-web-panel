import 'package:admin_web_panel/widgets/edit_drivers_form.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'drivers_account.dart';

class DriverTable extends StatefulWidget {
  final List<DriversAccount> driversAccountList;

  const DriverTable({Key? key, required this.driversAccountList}) : super(key: key);

  @override
  _DriverTableState createState() => _DriverTableState();
}

class _DriverTableState extends State<DriverTable> {
  List<DriversAccount> filteredList = [];
  int rowsPerPage = 6;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    filteredList = widget.driversAccountList;
  }

  @override
  Widget build(BuildContext context) {
    int totalDrivers = filteredList.length;
    int totalPages = (totalDrivers / rowsPerPage).ceil();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text("Filter by Tag"),
              items: ['All', 'Operator', 'Member'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (filter) {
                setState(() {
                  if (filter == 'All') {
                    filteredList = widget.driversAccountList;
                  } else {
                    filteredList = widget.driversAccountList.where((driver) => driver.tag == filter).toList();
                  }
                  currentPage = 0;
                });
              },
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
                      DataColumn2(label: Text('Email')),
                      DataColumn2(label: Text('Phone Number')), // Added Phone Number
                      DataColumn2(label: Text('Tag')),
                    ],
                    rows: _getCurrentPageDrivers().map((driver) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(driver.firstName)),
                          DataCell(Text(driver.lastName)),
                          DataCell(Text(driver.idNumber)),
                          DataCell(Text(driver.bodyNumber)),
                          DataCell(Text(driver.email)),
                          DataCell(Text(driver.phoneNumber)), // Added Phone Number
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
                    headingRowColor: MaterialStateProperty.resolveWith((states) => const Color.fromARGB(255, 145, 179, 230)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    dataRowHeight: 60,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Drivers: $totalDrivers'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: currentPage > 0
                          ? () {
                              setState(() {
                                currentPage--;
                              });
                            }
                          : null,
                    ),
                    Text('Page ${currentPage + 1} of $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DriversAccount> _getCurrentPageDrivers() {
    int start = currentPage * rowsPerPage;
    int end = start + rowsPerPage;
    end = end > filteredList.length ? filteredList.length : end;
    return filteredList.sublist(start, end);
  }

  void _showDriverDetailsDialog(DriversAccount driver, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: EditDriverForm(
            driverId: driver.uid,
            firstName: driver.firstName,
            lastName: driver.lastName,
            idNumber: driver.idNumber,
            bodyNumber: driver.bodyNumber,
            email: driver.email,
            birthdate: driver.birthdate,
            address: driver.address,
            phoneNumber: driver.phoneNumber,
            tag: driver.tag,
            driverPhoto: driver.driverPhoto,
          ),
        );
      },
    );
  }
}
