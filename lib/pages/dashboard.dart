import 'package:admin_web_panel/widgets/rides_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 20),
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),

        // Grid view with stats
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3,
          children: [
            _buildStatCard(
              'Total Tricycle Line',
              _totalTricycleLine.toString(),
              const Color(0xFF507EA9),
            ),
            _buildStatCard(
              'Total Online Riders',
              _totalOnlineRiders.toString(),
              const Color(0xFF5096A9),
            ),
            _buildStatCard(
              'Total Members',
              _totalMembers.toString(),
              const Color(0xFF465D7C),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Pie Chart and Rides Chart in two columns
        Row(
          children: [
            // Driver Online Status (Pie Chart)

            const SizedBox(width: 16), // Space between columns

            // Rides Chart
            Expanded(
              child: SizedBox(
                height: 500, // Set a fixed height for the chart
                child: RidesChart(),
              ),
            ),            Expanded(
              child: _buildPieChart(),
            ),
          ]
        ),
      ],
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

  Widget _buildPieChart() {
    final double onlinePercentage = _totalTricycleLine > 0
        ? (_totalOnlineRiders / _totalTricycleLine) * 100
        : 0.0;
    final double offlinePercentage = 100.0 - onlinePercentage;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Driver Online Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 400,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: onlinePercentage,
                        color: Colors.green,
                        title: '${onlinePercentage.toStringAsFixed(1)}%',
                        radius: 150,
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
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 0,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Online',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Offline',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
