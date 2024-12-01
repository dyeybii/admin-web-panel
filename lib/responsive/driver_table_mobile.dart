import 'package:admin_web_panel/responsive/edit_form_desktop.dart';
import 'package:flutter/material.dart';
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
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditDialog(context, driver),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, DriversAccount driver) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: EditDriverFormDesktop(
              driverId: driver.uid,
              firstName: driver.firstName,
              lastName: driver.lastName,
              idNumber: driver.idNumber,
              bodyNumber: driver.bodyNumber,
              email: driver.email,
              birthdate: driver.birthdate.isNotEmpty ? driver.birthdate : '',
              address: driver.address.isNotEmpty ? driver.address : '',
              phoneNumber: driver.phoneNumber,
              tag: driver.tag,
              codingScheme: driver.codingScheme,
              driverPhoto:
                  driver.driverPhoto.isNotEmpty ? driver.driverPhoto : '',
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
