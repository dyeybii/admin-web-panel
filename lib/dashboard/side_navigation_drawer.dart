import 'package:flutter/material.dart';
import 'package:admin_web_panel/pages/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/trips_page.dart';
import 'package:admin_web_panel/pages/users_page.dart';
import 'package:admin_web_panel/pages/driver_managementApp.dart';
import 'package:admin_web_panel/login.dart'; // Import your login page

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({Key? key}) : super(key: key);

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  String selectedRoute = Dashboard.id;

  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Widget chosenScreen;
    switch (selectedRoute) {
      case Dashboard.id:
        chosenScreen = Dashboard();
        break;
      case DriversPage.id:
        chosenScreen = DriversPage();
        break;
      case UsersPage.id:
        chosenScreen = UsersPage();
        break;
      case TripsPage.id:
        chosenScreen = TripsPage();
        break;
      case AddDriverUserPage.id:
        chosenScreen = AddDriverUserPage();
        break;
      default:
        chosenScreen = Dashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("TRI.CO"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Dashboard'),
              leading: Icon(Icons.dashboard),
              onTap: () {
                setState(() {
                  selectedRoute = Dashboard.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Drivers'),
              leading: Icon(Icons.directions_car),
              onTap: () {
                setState(() {
                  selectedRoute = DriversPage.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Users'),
              leading: Icon(Icons.person),
              onTap: () {
                setState(() {
                  selectedRoute = UsersPage.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Trips'),
              leading: Icon(Icons.location_on),
              onTap: () {
                setState(() {
                  selectedRoute = TripsPage.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Driver Management'),
              leading: Icon(Icons.supervisor_account),
              onTap: () {
                setState(() {
                  selectedRoute = AddDriverUserPage.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: chosenScreen,
    );
  }
}
