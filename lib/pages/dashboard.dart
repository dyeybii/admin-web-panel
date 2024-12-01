import 'package:admin_web_panel/responsive/dashboard_desktop.dart';
import 'package:admin_web_panel/responsive/dashboard_mobile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Dashboard extends StatefulWidget {
  static const String id = "/webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseReference _driversRef =
      FirebaseDatabase.instance.ref().child('driversAccount');
  final DatabaseReference _onlineDriversRef =
      FirebaseDatabase.instance.ref().child('onlineDrivers');

  int _totalTricycleLine = 0;
  int _totalOnlineRiders = 0;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchOnlineRiders();
  }

  void _fetchData() async {
    try {
      _driversRef.once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final driversData = event.snapshot.value as Map<dynamic, dynamic>;
          int tricycleCount = 0;
          int memberCount = 0;

          driversData.forEach((key, value) {
            if (value['tag'] == 'Operator') {
              tricycleCount++;
            }
            if (value['email'] != null) {
              memberCount++;
            }
          });

          setState(() {
            _totalTricycleLine = tricycleCount;
            _totalMembers = memberCount;
          });
        }
      });
    } catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  void _fetchOnlineRiders() async {
    try {
      _onlineDriversRef.once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final onlineData = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _totalOnlineRiders = onlineData.length;
          });
        }
      });
    } catch (e) {
      print('Failed to fetch online riders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1100) {
            return DashboardMobileView(
              totalTricycleLine: _totalTricycleLine,
              totalOnlineRiders: _totalOnlineRiders,
              totalMembers: _totalMembers,
            );
          } else {
            return DashboardDesktopView(
              totalTricycleLine: _totalTricycleLine,
              totalOnlineRiders: _totalOnlineRiders,
              totalMembers: _totalMembers,
            );
          }
        },
      ),
    );
  }
}
