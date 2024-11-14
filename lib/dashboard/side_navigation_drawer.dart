import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_web_panel/pages/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/fare_matrix_page.dart';
import 'package:admin_web_panel/pages/profile_page.dart';
import 'package:admin_web_panel/pages/audit_log_page.dart';
import 'package:admin_web_panel/login.dart';

class WebAdminPanel extends StatefulWidget {
  const WebAdminPanel({Key? key}) : super(key: key);

  @override
  State<WebAdminPanel> createState() => _WebAdminPanelState();
}

class _WebAdminPanelState extends State<WebAdminPanel> {
  int _selectedIndex = 0;
  String? _profileImageUrl;
  String? _fullName;

  final List<Widget> _pages = [
    const Dashboard(),
    const DriversPage(),
    const FareMatrixPage(),
    const ProfilePage(),
    const AuditlogPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('admin').doc(uid).get();
        String? imageUrl = doc['profileImage'] ?? null;
        String? name = doc['fullName'] ?? 'Admin';

        setState(() {
          _profileImageUrl = imageUrl;
          _fullName = name;
        });
      }
    } catch (e) {
      print('Error fetching admin data: $e');
      setState(() {
        _profileImageUrl = null;
        _fullName = 'Admin';
      });
    }
  }

  Future<void> _confirmLogout() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 400,
              color: const Color(0xFF2E3192),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E3192),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: const Text(
                      'Confirm Logout',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Are you sure you want to log out?',
                          style: TextStyle(color: Color(0xFF2E3192)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF505050)),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0000)),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildDrawerItem(String title, Widget icon, int index) {
    bool isSelected = _selectedIndex == index;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Color(0xFF2E3192) : Colors.black,
          fontSize: 16.0,
        ),
      ),
      leading: icon,
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
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
                color: Color(0xFF2E3192),
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
            DrawerHeader(
              
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'images/background.jpg'), 
                  fit: BoxFit.cover, 
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _profileImageUrl!,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 30, // Adjust the size here
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _fullName ?? 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Dashboard', const Icon(Icons.dashboard), 0),
            _buildDrawerItem(
                'Member Management', const Icon(Icons.person_add), 1),
            _buildDrawerItem(
              'Fare Matrix',
              Image.asset(
                'images/Peso_sign.png',
                height: 20,
                width: 20,
                color: _selectedIndex == 2
                    ? Color(0xFF2E3192)
                    : const Color.fromARGB(255, 56, 56, 56),
              ),
              2,
            ),
            _buildDrawerItem('Profile', const Icon(Icons.person), 3),
            _buildDrawerItem('Audit Log', const Icon(Icons.history), 4),
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
