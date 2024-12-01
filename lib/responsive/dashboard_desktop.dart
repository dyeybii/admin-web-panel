import 'package:flutter/material.dart';
import 'package:admin_web_panel/widgets/rides_chart.dart';
import 'package:admin_web_panel/widgets/pie_chart.dart';

class DashboardDesktopView extends StatelessWidget {
  final int totalTricycleLine;
  final int totalOnlineRiders;
  final int totalMembers;

  const DashboardDesktopView({
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
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3,
          children: stats,
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
              child: ResponsivePieChart(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust sizes based on card width
        final isSmallScreen = constraints.maxWidth < 200;
        final padding = EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: isSmallScreen ? 12.0 : 20.0,
        );
        final titleFontSize = isSmallScreen ? 14.0 : 18.0;
        final valueFontSize = isSmallScreen ? 18.0 : 24.0;
        final iconSize = isSmallScreen ? 30.0 : 40.0;

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Flexible content for text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Icon with flexible size
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF676768), // Apply the specified color
                    BlendMode
                        .srcIn, // Ensures the color is applied to the image
                  ),
                  child: Image.asset(
                    iconPath,
                    height: iconSize,
                    width: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
