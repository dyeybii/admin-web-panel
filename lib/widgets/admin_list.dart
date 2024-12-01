// admin_list.dart
import 'package:flutter/material.dart';

class AdminListPage extends StatelessWidget {
  const AdminListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin List'),
      ),
      body: const Center(
        child: Text('This is admins'),
      ),
    );
  }
}
