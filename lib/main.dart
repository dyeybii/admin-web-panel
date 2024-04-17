import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:admin_web_panel/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: const FirebaseOptions(
  apiKey: "AIzaSyC1813klIMjrdxnH_MxTgfd7bASkNcu0Ic",
  authDomain: "trico-admin-panel.firebaseapp.com",
  databaseURL: "https://trico-admin-panel-default-rtdb.firebaseio.com",
  projectId: "trico-admin-panel",
  storageBucket: "trico-admin-panel.appspot.com",
  messagingSenderId: "925740452995",
  appId: "1:925740452995:web:96401cc26c6fd09842dfb6",
  measurementId: "G-JYX1EM4G93"
     ));
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

