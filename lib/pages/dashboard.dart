import 'package:admin_web_panel/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  static const String id = "/webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CollectionReference _driversRef =
      FirebaseFirestore.instance.collection('DriversAccount');
  int _totalRegisteredDrivers = 0;
  int _totalOnlineRiders = 0;
  int _totalCompletedRides = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final QuerySnapshot snapshot = await _driversRef.get();
      setState(() {
        _totalRegisteredDrivers = snapshot.size;
        _totalOnlineRiders =
            snapshot.docs.where((doc) => doc['isOnline'] == true).length;
        _totalCompletedRides = snapshot.docs
            .where((doc) => doc['ridesCompleted'] != null)
            .map((doc) => doc['ridesCompleted'] as int)
            .reduce((a, b) => a + b);
      });
    } catch (e) {
      print('Failed to fetch data: $e');
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
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // Use a responsive GridView
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2, 
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3, // Adjust aspect ratio for better card size
              children: [
                _buildStatCard(
                  'Total Registered Drivers in App',
                  _totalRegisteredDrivers.toString(),
                  const Color(0xBF0863B7),
                ),
                _buildStatCard(
                  'Total Online Riders',
                  _totalOnlineRiders.toString(),
                  const Color(0xBF207C00),
                ),
                _buildStatCard(
                  'Total Completed Rides',
                  _totalCompletedRides.toString(),
                  const Color(0xBF525252),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGraphCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Active Drivers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            LineChartSample2(),
          ],
        ),
      ),
    );
  }
}