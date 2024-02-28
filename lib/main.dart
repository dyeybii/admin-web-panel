import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: FirebaseOptions(
      authDomain: "add-users-admin.firebaseapp.com",
      projectId: "add-users-admin",
      storageBucket: "add-users-admin.appspot.com",
      messagingSenderId: "660357140183",
      appId: "1:660357140183:web:940b0b0ff28e6fc0dbea92",
      measurementId: "G-NTJ6FKBQMM",
      apiKey: ''
     ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SideNavigationDrawer(),
    );
  }
}


