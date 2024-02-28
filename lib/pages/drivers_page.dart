import 'package:flutter/material.dart';

class DriversPage extends StatefulWidget
{
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  Widget header(int headerflexValue, String headerTitle)
  {
    return Expanded(
      flex: headerflexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color:Colors.black),
          color: Colors.blueAccent,
        ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          headerTitle,
          style:const TextStyle(
            color:Colors.white),
        ),
      ),
      ),
    );
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manage Drivers",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(
              height: 18,
            ),
            Row(
              children: [
                header(2, "DRIVER ID"),
                header(1, "PICTURE"),
                header(1, "NAME"),
                header(1, "DETAILS"),
                header(1, "PHONE NUMBER"),
                header(1, "BODY NUMBER"),
                header(1, "ACCOUNT STATUS")
              ],
            )

          //DISPLAY ALL DATA HERE 

            ],
          ),
        ),
      ),
    );
  }
}
