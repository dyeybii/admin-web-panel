import 'package:flutter/material.dart';
import 'package:admin_web_panel/pages/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/fund_page.dart';
import 'package:admin_web_panel/pages/fare_matrix_page.dart';
import 'package:admin_web_panel/pages/account_page.dart';
import 'package:admin_web_panel/login.dart';

class WebAdminPanel extends StatefulWidget {
  const WebAdminPanel({super.key});

  @override
  State<WebAdminPanel> createState() => _WebAdminPanelState();
}

class _WebAdminPanelState extends State<WebAdminPanel> {
  int _selectedIndex = 0;

  // Pages for navigation (kept alive with IndexedStack)
  final List<Widget> _pages = [
    const Dashboard(),
    const DriversPage(),
    const FundPage(),
    const FareMatrixPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  // Confirm Logout dialog
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

  // Logout functionality
  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

  // Drawer items with navigation
  Widget _buildDrawerItem(String title, IconData icon, int index) {
    bool isSelected = _selectedIndex == index;

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
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              "TRI.CO",
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ],
              ),
            ),
            _buildDrawerItem('Dashboard', Icons.dashboard, 0),
            _buildDrawerItem('Member Management', Icons.person_add, 1),
            //_buildDrawerItem('Fund Collection', Icons.money, 2),
            _buildDrawerItem('Fare Matrix', Icons.monetization_on, 3),
            _buildDrawerItem('My Account', Icons.account_circle, 4),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
