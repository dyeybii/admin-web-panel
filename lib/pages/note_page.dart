import 'package:flutter/material.dart';

class NotePage extends StatefulWidget
{
  static const String id = "\webPageTrips";

  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context)
  {
    return const Scaffold(
      body:  Center(
        child: Text(
        "Notes for admin",
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 24
         )
       ),
      ),
     );
  }
}
