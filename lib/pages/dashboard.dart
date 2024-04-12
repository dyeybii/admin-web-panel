import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget
{
  static const String id = "\webPageDashboard";

  const Dashboard({super.key});



  @override
  State<Dashboard> createState() => _TripsPageState();

}
class _TripsPageState extends State<Dashboard> {
  @override
  Widget build(BuildContext context)
  {
    return const Scaffold(
      body:  Center(
        
        child: Text(
        "Dashboard here",
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 24
         )
       ),
      ),
     );
  }
}
