import 'package:admin_web_panel/widgets/pie_chart_mobile.dart';
import 'package:flutter/material.dart';
import 'package:admin_web_panel/widgets/rides_chart.dart';
import 'package:admin_web_panel/widgets/pie_chart.dart';

class DashboardMobileView extends StatelessWidget {
  final int totalTricycleLine;
  final int totalOnlineRiders;
  final int totalMembers;

  const DashboardMobileView({
    Key? key,
    required this.totalTricycleLine,
    required this.totalOnlineRiders,
    required this.totalMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = [
      _buildStatCard(
        'Total Tricycle Line',
        totalTricycleLine.toString(),
        const Color(0xFF507EA9),
        'images/tricycle_icon.png',
      ),
      _buildStatCard(
        'Total Online Riders',
        totalOnlineRiders.toString(),
        const Color(0xFF5096A9),
        'images/mobile1.png',
      ),
      _buildStatCard(
        'Total Driver Members',
        totalMembers.toString(),
        const Color(0xFF465D7C),
        'images/total_members.png',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 20),
        
        const Divider(thickness: 2),
        const SizedBox(height: 20),
        Column(
          children: stats.map((stat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: stat,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            SizedBox(
              height: 450,
              child: RidesChart(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 450,
              child: ResponsivePieChartMobile(
                totalUsers: totalMembers,
                onlineUsers: totalOnlineRiders,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    String iconPath,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
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
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8.0),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFF676768), // Apply the specified color
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
}
