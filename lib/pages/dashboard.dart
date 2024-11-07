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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
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
                      'images/tricycle_icon.png',
                    ),
                    _buildStatCard(
                      'Total Online Riders',
                      _totalOnlineRiders.toString(),
                      const Color(0xFF5096A9),
                      'images/mobile1.png',
                    ),
                    _buildStatCard(
                      'Total Driver Members',
                      _totalMembers.toString(),
                      const Color(0xFF465D7C),
                      'images/total_members.png',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 450,
                    child: RidesChart(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 450,
                    child: _buildPieChart(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, String iconPath) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
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
          ),
          const SizedBox(width: 8),

          // Icon with Circular Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(14.0),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                iconPath,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    // Calculate the total number of users
    final int totalUsers = _totalMembers; // Assuming this is the total riders count
    final double onlinePercentage = totalUsers > 0
        ? (_totalOnlineRiders / totalUsers) * 100
        : 0.0;
    final double offlinePercentage = totalUsers > 0
        ? (1 - (_totalOnlineRiders / totalUsers)) * 100
        : 100.0; // 100% if there are no total users

    // Ensure percentages do not exceed logical bounds
    final double clampedOnlinePercentage = onlinePercentage.clamp(0.0, 100.0);
    final double clampedOfflinePercentage = offlinePercentage.clamp(0.0, 100.0);

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
            'Online Riders in Coloong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 370,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: clampedOnlinePercentage,
                        color: Colors.green,
                        title: '${clampedOnlinePercentage.toStringAsFixed(1)}%',
                        radius: 150,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: clampedOfflinePercentage,
                        color: Colors.red,
                        title: '${clampedOfflinePercentage.toStringAsFixed(1)}%',
                        radius: 150,
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
