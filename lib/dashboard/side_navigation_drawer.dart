import 'package:admin_web_panel/dashboard/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/trips_page.dart';
import 'package:admin_web_panel/pages/users_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

import '../pages/driver_managementApp.dart';

//common users
//drivers
//admins
class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({Key? key}) : super(key: key);

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = Dashboard();

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      case DriversPage.id:
        setState(() {
          chosenScreen = DriversPage();
        });
        break;

      case UsersPage.id:
        setState(() {
          chosenScreen = UsersPage();
        });
        break;

      case TripsPage.id:
        setState(() {
          chosenScreen = TripsPage();
        });
        break;
      case AddDriverUserPage.id:
        setState(() {
          chosenScreen = AddDriverUserPage();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: "Drivers",
            route: DriversPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          AdminMenuItem(
            title: "Users",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          AdminMenuItem(
            title: "Driver Management",
            route: AddDriverUserPage.id,
            icon: Icons.supervisor_account,
          ),
          AdminMenuItem( // Add logout button
            title: "Logout",
            route: '/logout',
            icon: Icons.logout,
          ),
        ],
        selectedRoute: DriversPage.id,
        onSelected: (selectedPage) {
          if (selectedPage.route == "/logout") {
            // Perform logout actions here
            // For example, navigate to the login page
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            sendAdminTo(selectedPage);
          }
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: Colors.blue.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color: Colors.blue.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.computer,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}
