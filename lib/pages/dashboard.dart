import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart for charts
import 'package:admin_web_panel/widgets/line_chart.dart'; // Assuming you have this widget
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_database/firebase_database.dart'; // For Firebase Realtime Database

class Dashboard extends StatefulWidget {
  static const String id = "/webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Firestore collection reference for the drivers data
  final CollectionReference _driversRef =
      FirebaseFirestore.instance.collection('DriversAccount');

  // Realtime Database reference for online drivers
  final DatabaseReference _onlineDriversRef = 
    FirebaseDatabase.instance.ref().child('onlineDrivers');

  // Variables to hold the fetched data
  int _totalRegisteredDrivers = 0;
  int _totalOnlineRiders = 0; // Updated from Realtime Database
  int _totalCompletedRides = 0;

  // Default start and end dates for the date picker, showing a 30-day range
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30)); 
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data when the widget is first built
  }

  // Method to fetch data from Firestore and Realtime Database and update state
void _fetchData() async {
  try {
    final QuerySnapshot snapshot = await _driversRef.get();
    if (snapshot.docs.isEmpty) {
      print('No driver records found.');
    } else {
      setState(() {
        _totalRegisteredDrivers = snapshot.size;
        _totalOnlineRiders = snapshot.docs.where((doc) => doc['isOnline'] == true).length;
        _totalCompletedRides = snapshot.docs
            .where((doc) => doc['ridesCompleted'] != null)
            .map((doc) => doc['ridesCompleted'] as int)
            .reduce((a, b) => a + b);
        print('Total Tricycle Line: $_totalRegisteredDrivers');
        print('Total Operators: $_totalOnlineRiders');
        print('Total Total Member: $_totalCompletedRides');
      });
    }

    _onlineDriversRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final onlineData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _totalOnlineRiders = onlineData.length;
          print('Updated Total Online Riders from Realtime DB: $_totalOnlineRiders');
        });
      } else {
        print('No online drivers found in Realtime Database.');
      }
    });

  } catch (e) {
    print('Failed to fetch data: $e');
  }
}


  // Method to show a date picker for selecting the start or end date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    // If a date is picked, update the respective start or end date
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Dashboard title
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Grid displaying total drivers, online riders, and completed rides
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2, // Adjust columns based on screen size
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable scroll in grid
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3, // Adjust the height of the grid items
              children: [
                _buildStatCard(
                  'Total Registered Drivers',
                  _totalRegisteredDrivers.toString(),
                  const Color(0xFF507EA9), // Color for the card
                ),
                _buildStatCard(
                  'Total Online Riders',
                  _totalOnlineRiders.toString(),
                  const Color(0xFF5096A9), // Color for the card
                ),
                _buildStatCard(
                  'Total Completed Rides',
                  _totalCompletedRides.toString(),
                  const Color(0xFF465D7C), // Color for the card
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pie chart card displaying percentage of online and offline drivers
            _buildPieChartCard(),
            const SizedBox(height: 20),

            // Graph card for showing completed rides over time
            _buildGraphCard(),
          ],
        ),
      ),
    );
  }

  // Widget to build a stat card displaying total drivers, online riders, or completed rides
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: color, // Background color of the card
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stat title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Stat value (number)
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // Handle overflow in case of long numbers
          ),
        ],
      ),
    );
  }

  // Widget to build a pie chart card showing the percentage of online and offline drivers
Widget _buildPieChartCard() {
  final double onlinePercentage = _totalRegisteredDrivers > 0
      ? (_totalOnlineRiders / _totalRegisteredDrivers) * 100
      : 0.0;
  final double offlinePercentage = 100.0 - onlinePercentage;

  print('Online Percentage: $onlinePercentage');
  print('Offline Percentage: $offlinePercentage');

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Active Drivers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: onlinePercentage,
                    color: Colors.green,
                    title: '${onlinePercentage.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: const TextStyle(color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: offlinePercentage,
                    color: Colors.red,
                    title: '${offlinePercentage.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  // Widget to build a graph card showing the number of completed rides over time
  Widget _buildGraphCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and date pickers for the graph
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Completed Rides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    // Date picker for selecting the start date
                    InkWell(
                      onTap: () => _selectDate(context, true), // Show date picker
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(DateFormat('MM/dd/yyyy').format(_startDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('to'),
                    const SizedBox(width: 8),

                    // Date picker for selecting the end date
                    InkWell(
                      onTap: () => _selectDate(context, false), // Show date picker
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(DateFormat('MM/dd/yyyy').format(_endDate)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Line chart showing the number of completed rides over time
            const SizedBox(
              height: 200,
              child: LineChartSample2(), // Assuming you have this widget for showing the line chart
            ),
          ],
        ),
      ),
    );
  }
}
