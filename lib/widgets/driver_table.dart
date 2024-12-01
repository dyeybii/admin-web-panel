
import 'package:admin_web_panel/responsive/driver_table_desktop.dart';
import 'package:admin_web_panel/responsive/driver_table_mobile.dart';
import 'package:flutter/material.dart';
import 'drivers_account.dart'; 


class DriverTable extends StatelessWidget {
  final List<DriversAccount> driversAccountList;
  final List<DriversAccount> selectedDrivers;
  final ValueChanged<List<DriversAccount>> onSelectedDriversChanged;

  DriverTable({
    required this.driversAccountList,
    required this.selectedDrivers,
    required this.onSelectedDriversChanged,
  });

  @override
  Widget build(BuildContext context) {
 
    if (MediaQuery.of(context).size.width > 800) {
   
      return DriverTableDesktop(
        driversAccountList: driversAccountList,
        selectedDrivers: selectedDrivers,
        onSelectedDriversChanged: onSelectedDriversChanged,
      );
    } else {
      // For smaller screens, show the mobile version
      return DriverTableMobile(
        driversAccountList: driversAccountList,
        selectedDrivers: selectedDrivers,
        onSelectedDriversChanged: onSelectedDriversChanged,
      );
    }
  }
}
