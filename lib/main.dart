import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:admin_web_panel/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBOgKFFQrKMhW9pBiexDyM_D9hXeE2775s",
          authDomain: "passenger-signuplogin.firebaseapp.com",
          databaseURL:
              "https://passenger-signuplogin-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "passenger-signuplogin",
          storageBucket: "passenger-signuplogin.appspot.com",
          messagingSenderId: "755339267599",
          appId: "1:755339267599:web:9b9ae57201f3e945e01d7a",
          measurementId: "G-V6S05YXR5D"));
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
        primarySwatch: Colors.blue,
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
