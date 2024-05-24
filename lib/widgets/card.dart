import 'package:flutter/material.dart';

class DriverCard extends StatelessWidget {
  final String driver;

  const DriverCard(this.driver);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(driver),
      ),
    );
  }
}