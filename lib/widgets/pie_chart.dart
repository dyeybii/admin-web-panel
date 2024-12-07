import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResponsivePieChart extends StatefulWidget {
  final int totalUsers;
  final int onlineUsers;

  const ResponsivePieChart({
    Key? key,
    required this.totalUsers,
    required this.onlineUsers,
  }) : super(key: key);

  @override
  _ResponsivePieChartState createState() => _ResponsivePieChartState();
}

class _ResponsivePieChartState extends State<ResponsivePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final double onlinePercentage = widget.totalUsers > 0
        ? (widget.onlineUsers / widget.totalUsers) * 100
        : 0.0;
    final double offlinePercentage = widget.totalUsers > 0
        ? (1 - (widget.onlineUsers / widget.totalUsers)) * 100
        : 100.0;

    final double clampedOnlinePercentage = onlinePercentage.clamp(0.0, 100.0);
    final double clampedOfflinePercentage = offlinePercentage.clamp(0.0, 100.0);

    // Dynamically calculate the radius based on screen size
    final double screenWidth = MediaQuery.of(context).size.width;
    final double radius = screenWidth < 600 ? screenWidth * 0.1 : screenWidth * 0.07;

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
            height: screenWidth < 600 ? 300 : 379, // Adjust height based on screen width
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 50, // Add this line to create the donut shape
                        sections: showingSections(
                          clampedOnlinePercentage * value,
                          clampedOfflinePercentage * value,
                          radius,
                        ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
    double onlinePercentage,
    double offlinePercentage,
    double radius,
  ) {
    final isOnlineTouched = touchedIndex == 0;
    final isOfflineTouched = touchedIndex == 1;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: onlinePercentage,
        title: '${onlinePercentage.toStringAsFixed(1)}%',
        radius: isOnlineTouched ? radius + 10 : radius,
        titleStyle: TextStyle(
          fontSize: isOnlineTouched ? 25.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: offlinePercentage,
        title: '${offlinePercentage.toStringAsFixed(1)}%',
        radius: isOfflineTouched ? radius + 10 : radius,
        titleStyle: TextStyle(
          fontSize: isOfflineTouched ? 25.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}
