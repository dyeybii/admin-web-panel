import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:admin_web_panel/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      authDomain: "add-users-admin.firebaseapp.com",
      projectId: "add-users-admin",
      storageBucket: "add-users-admin.appspot.com",
      messagingSenderId: "660357140183",
      appId: "1:660357140183:web:940b0b0ff28e6fc0dbea92",
      measurementId: "G-NTJ6FKBQMM",
      apiKey: ''
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/dashboard': (context) => SideNavigationDrawer(),
        '/login': (context) => LoginPage(), // Add route for login page
        '/logout': (context) => LoginPage(), // Add route for logout page
      },
    );
  }
}

