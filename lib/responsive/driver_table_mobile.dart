import 'package:admin_web_panel/responsive/edit_form_mobile.dart';
import 'package:admin_web_panel/widgets/blacklist.dart';
import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:admin_web_panel/widgets/edit_drivers_form.dart';

class DriverTableMobile extends StatefulWidget {
  final List<DriversAccount> driversAccountList;
  final List<DriversAccount> selectedDrivers;
  final Function(List<DriversAccount>) onSelectedDriversChanged;

  const DriverTableMobile({
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Accounts"),
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
      body: ListView.builder(
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (driver.driverPhoto.isNotEmpty)
                        Image.network(driver.driverPhoto,
                            height: 50, width: 50),
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
                              children: _buildRatingWithStar(
                                  driver.totalRatings?.averageRating),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditDialog(context, driver),
              ),
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
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
            child: const Icon(Icons.refresh),
            label: 'Refresh',
            onTap: _fetchDriversData,
            backgroundColor: Colors.blue,
          ),
        ],
      ),
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

  List<Widget> _buildRatingWithStar(double? averageRating) {
    double rating = averageRating ?? 0.0;

    String ratingText = rating.toStringAsFixed(1);

    return [
      Text(ratingText),
      const Icon(Icons.star, color: Colors.yellow),
    ];
  }

  void _fetchDriversData() {
    // Your data fetching logic
  }
}
