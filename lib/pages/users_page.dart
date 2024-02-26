import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget
{
  static const String id = "\webPageUsers";

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context)
  {
    return const Scaffold(
      body:  Center(
        child: Text(
            "UsersPage",
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24
            )
        ),
      ),
    );
  }
}
