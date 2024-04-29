import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  static const String id = "\webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Dashboard here",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}