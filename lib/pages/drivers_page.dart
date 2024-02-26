import 'package:flutter/material.dart';

class DriversPage extends StatefulWidget
{
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  @override
  Widget build(BuildContext context)
  {
    return const Scaffold(
      body:  Center(
        child: Text(
            "DriversPage",
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24
            )
        ),
      ),
    );
  }
}
