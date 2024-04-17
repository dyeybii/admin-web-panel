import 'package:flutter/material.dart';

class AddDriverUserPage extends StatefulWidget {
  static const String id = "webPageDriverManagement";

  const AddDriverUserPage({Key? key}) : super(key: key);

  @override
  _AddDriverUserPageState createState() => _AddDriverUserPageState();
}

class _AddDriverUserPageState extends State<AddDriverUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Add Driver User"),
      ),
      body: Center(),
    );
  }
}
