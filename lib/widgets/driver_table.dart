import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/edit_drivers_form.dart';

class DriverTable extends StatefulWidget {
  final List<DriversAccount> driversAccountList;
  final List<DriversAccount> selectedDrivers;
  final Function(List<DriversAccount>) onSelectedDriversChanged;

  const DriverTable({
    Key? key,
    required this.driversAccountList,
    required this.selectedDrivers,
    required this.onSelectedDriversChanged,
  }) : super(key: key);

  @override
  _DriverTableState createState() => _DriverTableState();
}

class _DriverTableState extends State<DriverTable> {
  List<DriversAccount> filteredList = [];
  int rowsPerPage = 7;
  int currentPage = 0;
  bool isAllSelected = false; 

  @override
  void initState() {
    super.initState();
    filteredList = widget.driversAccountList.where((driver) => driver.firstName.isNotEmpty).toList();
    isAllSelected = widget.selectedDrivers.length == filteredList.length;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.selectedDrivers.length} driver(s) selected'),
              ],
            ),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: DataTable2(
                    columns: [
                      DataColumn2(
                        label: Row(
                          children: [
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
                            const Text('Select All'),
                          ],
                        ),
                      ),
                      const DataColumn2(label: Text('First Name')),
                      const DataColumn2(label: Text('Last Name')),
                      const DataColumn2(label: Text('ID Number')),
                      const DataColumn2(label: Text('Body Number')),
                      const DataColumn2(label: Text('Email')),
                      const DataColumn2(label: Text('Phone Number')),
                      const DataColumn2(label: Text('Tag')),
                    ],
                    rows: _getCurrentPageDrivers().map((driver) {
                      final isSelected = widget.selectedDrivers.contains(driver);
                      return DataRow2(
                        selected: isSelected,
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value!) {
                                    widget.selectedDrivers.add(driver);
                                  } else {
                                    widget.selectedDrivers.remove(driver);
                                  }
                                  widget.onSelectedDriversChanged(widget.selectedDrivers);

                                  isAllSelected = widget.selectedDrivers.length == filteredList.length;
                                });
                              },
                            ),
                          ),
                          DataCell(Text(driver.firstName)),
                          DataCell(Text(driver.lastName)),
                          DataCell(Text(driver.idNumber)),
                          DataCell(Text(driver.bodyNumber)),
                          DataCell(Text(driver.email)),
                          DataCell(Text(driver.phoneNumber)),
                          DataCell(Text(driver.tag)),
                        ],
                      );
                    }).toList(),
                    border: TableBorder(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => const Color.fromARGB(255, 145, 179, 230),
                    ),
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
}
