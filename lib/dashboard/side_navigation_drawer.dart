import 'package:flutter/material.dart';
import 'package:admin_web_panel/pages/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/fund_collection.dart'; 
import 'package:admin_web_panel/pages/fare_matrix_page.dart';
import 'package:admin_web_panel/login.dart';

class WebAdminPanel extends StatefulWidget {
  const WebAdminPanel({super.key});

  @override
  State<WebAdminPanel> createState() => _WebAdminPanelState();
}

class _WebAdminPanelState extends State<WebAdminPanel> {
  String? selectedRoute = Dashboard.id;

  Future<void> _confirmLogout() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _logout();
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

  Widget _getSelectedScreen() {
    switch (selectedRoute) {
      case Dashboard.id:
        return const Dashboard();
      case DriversPage.id:
        return const DriversPage();
      case FundCollection.id:
        return const FundCollection();
      case FareMatrixPage.id:
        return const FareMatrixPage();
      default:
        return const Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "TRI.CO",
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20),
           
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'COTODA Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Dashboard', Icons.dashboard, Dashboard.id),
            _buildDrawerItem('Drivers', Icons.directions_car, DriversPage.id),
            _buildDrawerItem('Fund Collection', Icons.money, FundCollection.id),
            _buildDrawerItem('Fare Matrix', Icons.monetization_on, FareMatrixPage.id),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
      body: _getSelectedScreen(),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, String? routeId) {
    bool isSelected = selectedRoute == routeId;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.indigo : Colors.black,
          fontSize: 16.0,
        ),
      ),
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.black),
      selected: isSelected,
      onTap: () {
        setState(() {
          selectedRoute = routeId;
        });
        Navigator.pop(context); // Close the drawer after selection
      },
    );
  }
}


