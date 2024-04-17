import 'package:flutter/material.dart';
import 'package:admin_web_panel/pages/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/note_page.dart';
import 'package:admin_web_panel/pages/passenger_page.dart';
import 'package:admin_web_panel/pages/driver_managementApp.dart';
import 'package:admin_web_panel/login.dart'; 

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
        chosenScreen = const Dashboard();
        break;
      case DriversPage.id:
        chosenScreen = const DriversPage();
        break;
      case UsersPage.id:
        chosenScreen = const UsersPage();
        break;
      case NotePage.id:
        chosenScreen = NotePage(key: UniqueKey());
        break;
      case AddDriverUserPage.id:
        chosenScreen = const AddDriverUserPage();
        break;
      default:
        chosenScreen = const Dashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("TRI.CO",style: TextStyle(
          color: Colors.black,
          fontSize: 20
          ),),
        
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: <Widget>[
          Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Center(
                    child: Text(
                      'Menu'
                      ,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Dashboard'),
                  leading: const Icon(Icons.dashboard),
                  onTap: () {
                    setState(() {
                      selectedRoute = Dashboard.id;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Drivers'),
                  leading: const SizedBox(
  width: 24, // Specify the desired width
  height: 24, // Specify the desired height
  child: Image(
    image: AssetImage('images/tricycle_icon.png'),
  ),
),
                  onTap: () {
                    setState(() {
                      selectedRoute = DriversPage.id;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Passenger'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    setState(() {
                      selectedRoute = UsersPage.id;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Notes'),
                  leading: const Icon(Icons.edit_note),
                  onTap: () {
                    setState(() {
                      selectedRoute = NotePage.id;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Driver Management'),
                  leading: const Icon(Icons.supervisor_account),
                  onTap: () {
                    setState(() {
                      selectedRoute = AddDriverUserPage.id;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Logout'),
                  leading: const Icon(Icons.logout),
                  onTap: logout,
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: chosenScreen,
          ),
        ],
      ),
    );
  }
}
