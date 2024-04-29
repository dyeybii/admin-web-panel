import 'package:admin_web_panel/widgets/download_excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';

class DriversPage extends StatefulWidget {
  static const String id = "/webPageDrivers";

  const DriversPage({Key? key}) : super(key: key);

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<DriversAccount> _driversAccountList = [];

  @override
  void initState() {
    super.initState();
    _fetchDriversData();
  }

  Future<void> _fetchDriversData() async {
    List<DriversAccount> driversList = await _getDriversFromFirestore();
    if (mounted) {
      setState(() {
        _driversAccountList = driversList;
      });
    }
  }

  Future<List<DriversAccount>> _getDriversFromFirestore() async {
    List<DriversAccount> driversList = [];

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('DriversAccount').get();
    for (var doc in snapshot.docs) {
      driversList
          .add(DriversAccount.fromJson(doc.data() as Map<String, dynamic>));
    }

    return driversList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Members and Operators'),
          automaticallyImplyLeading: false,
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add member action
              },
              child: const Text('Add Member'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                ExcelDownloader.downloadExcel(context, _driversAccountList);
              },
              child: const Text('Download Excel'),
            ),
          ],
        ),
        body: _driversAccountList.isNotEmpty
            ? DriverTable(driversAccountList: _driversAccountList)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
