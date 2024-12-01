import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:admin_web_panel/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDgJoaa0IeP_UgGyiy5y-hRYgDD7RfS154",
          authDomain: "capstone-ca5d5.firebaseapp.com",
          databaseURL:
              "https://capstone-ca5d5-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "capstone-ca5d5",
          storageBucket: "capstone-ca5d5.firebasestorage.app",
          messagingSenderId: "499691183216",
          appId: "1:499691183216:web:93392b331aab6a776828b5",
          measurementId: "G-MF3YD1PZY9"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRI.CO',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: customColor,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => WebAdminPanel(),
        '/logout': (context) => LoginPage(),
      },
    );
  }
}
