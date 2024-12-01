import 'package:admin_web_panel/responsive/edit_form_desktop.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/edit_drivers_form.dart';

class DriverTableDesktop extends StatefulWidget {
  final List<DriversAccount> driversAccountList;
  final List<DriversAccount> selectedDrivers;
  final Function(List<DriversAccount>) onSelectedDriversChanged;

  const DriverTableDesktop({
    Key? key,
    required this.driversAccountList,
    required this.selectedDrivers,
    required this.onSelectedDriversChanged,
  }) : super(key: key);

  @override
  _DriverTableDesktopState createState() => _DriverTableDesktopState();
}

class _DriverTableDesktopState extends State<DriverTableDesktop> {
  List<DriversAccount> filteredList = [];
  int rowsPerPage = 8;
  int currentPage = 0;
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    filteredList = widget.driversAccountList
        .where((driver) => driver.firstName.isNotEmpty)
        .toList();
    isAllSelected = widget.selectedDrivers.length == filteredList.length;
  }

  @override
  Widget build(BuildContext context) {
    int totalDrivers = filteredList.length;
    int totalOperators =
        filteredList.where((driver) => driver.tag == 'Operator').length;
    int totalMembers = totalDrivers - totalOperators;
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
                                widget.onSelectedDriversChanged(
                                    widget.selectedDrivers);
                              });
                            },
                          ),
                          const Text('Select All'),
                        ],
                      ),
                    ),
                    const DataColumn2(
                        label: Text(
                      'ID NO.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataColumn2(
                        label: Text(
                      'Full Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataColumn2(
                        label: Text(
                      'Body NO.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataColumn2(
                        label: Text(
                      'Tag',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataColumn2(
                        label: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataColumn2(
                        label: Text(
                      'Ratings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                  rows: _getCurrentPageDrivers().map((driver) {
                    final isSelected = widget.selectedDrivers.contains(driver);
                    final textColor =
                        driver.tag == 'Operator' ? Colors.red : Colors.blue;

                    return DataRow2(
                      selected: isSelected,
                      onTap: () {
                        _showEditDialog(context, driver);
                      },
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
                                widget.onSelectedDriversChanged(
                                    widget.selectedDrivers);
                                isAllSelected = widget.selectedDrivers.length ==
                                    filteredList.length;
                              });
                            },
                          ),
                        ),
                        DataCell(Text(driver.idNumber)),
                        DataCell(
                            Text(driver.firstName + ' ' + driver.lastName)),
                        DataCell(Text(driver.bodyNumber)),
                        DataCell(Text(
                          driver.tag,
                          style: TextStyle(color: textColor),
                        )),
                        DataCell(Text(driver.status)),
                        DataCell(
                          Row(
                            children: _buildRatingWithStar(
                                driver.totalRatings?.averageRating),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => const Color.fromARGB(255, 145, 179, 230),
                  ),
                  headingRowDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  dataRowHeight: 50,
                ),
              ),
            ),
            const Divider(thickness: 2),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Total Members: $totalMembers'),
                    const SizedBox(width: 20),
                    Text('Total Operators: $totalOperators'),
                  ],
                ),
                const SizedBox(width: 900),
                Flexible(
                  fit: FlexFit.loose,
                  child: NumberPagination(
                    totalPages: totalPages,
                    currentPage: currentPage + 1,
                    onPageChanged: (int pageNumber) {
                      setState(() {
                        currentPage = pageNumber - 1;
                      });
                    },
                    controlButtonSize: const Size(25, 25),
                    numberButtonSize: const Size(25, 25),
                    selectedButtonColor: const Color(0xFF2E3192),
                    selectedNumberColor: Colors.white,
                    unSelectedButtonColor: Colors.white,
                    unSelectedNumberColor: Colors.black,
                  ),
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
            width: screenSize.width * 0.6,
            height: screenSize.height * 0.9,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  child: EditDriverFormDesktop(
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
                    driverPhoto:
                        driver.driverPhoto.isNotEmpty ? driver.driverPhoto : '',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildRatingWithStar(double? averageRating) {
    double rating = averageRating ?? 0.0;

    String ratingText = rating.toStringAsFixed(1);

    return [
      Text(ratingText),
      const Icon(Icons.star, color: Colors.yellow),
    ];
  }
}
