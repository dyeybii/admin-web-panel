import 'package:flutter/material.dart';
import 'package:admin_web_panel/pages/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/note_page.dart';
import 'package:admin_web_panel/pages/passenger_page.dart';
import 'package:admin_web_panel/pages/driver_managementApp.dart';
import 'package:admin_web_panel/login.dart';

class WebAdminPanel extends StatefulWidget {
  const WebAdminPanel({Key? key}) : super(key: key);

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
      case UsersPage.id:
        return const UsersPage();
      case NotePage.id:
        return NotePage(key: UniqueKey());
      case AddDriverUserPage.id:
        return const AddDriverUserPage();
      default:
        return const Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TRI.CO Admin Panel",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 240,
            color: const Color(0xFF3B3F9E),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const SizedBox(height: 20.0),
                _buildListTile('Dashboard', Icons.dashboard, Dashboard.id),
                _buildListTile('Drivers', 'images/tricycle_icon.png', DriversPage.id),
                _buildListTile('Passenger', Icons.person, UsersPage.id),
                _buildListTile('Notes', Icons.edit_note, NotePage.id),
                _buildListTile('Driver Management', Icons.supervisor_account, AddDriverUserPage.id),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: _getSelectedScreen(),
          ),
        ],
      ),
    );
  }

  ListTile _buildListTile(String title, dynamic leadingIcon, String? routeId, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      leading: leadingIcon is IconData ? Icon(leadingIcon, color: Colors.white) : Image.asset(leadingIcon, width: 24, height: 24, color: Colors.white),
      onTap: () {
        if (routeId != null) {
          setState(() {
            selectedRoute = routeId;
          });
        }
        if (onTap != null) onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    );
  }
}
