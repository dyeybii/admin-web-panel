import 'package:admin_web_panel/widgets/card.dart';
import 'package:admin_web_panel/widgets/line_chart_sample2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  static const String id = "/webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CollectionReference _driversRef =
      FirebaseFirestore.instance.collection('DriversAccount');
  List<Map<String, dynamic>> _drivers = [];
  int _currentIndex = 0;
  int _pageSize = 10;

  void _nextRange() {
    setState(() {
      _currentIndex =
          (_currentIndex + _pageSize).clamp(0, _drivers.length - _pageSize);
    });
  }

  void _previousRange() {
    setState(() {
      _currentIndex =
          (_currentIndex - _pageSize).clamp(0, _drivers.length - _pageSize);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  void _fetchDrivers() async {
    try {
      final QuerySnapshot snapshot = await _driversRef.get();
      final List<Map<String, dynamic>> driversList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'driverPhoto': data['driverPhoto'],
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'isOnline': data['isOnline'] ?? false,
        };
      }).toList();

      setState(() {
        _drivers = driversList;
      });
    } catch (e) {
      print('Failed to fetch drivers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> driversRange1 = _drivers.sublist(
        _currentIndex, (_currentIndex + _pageSize).clamp(0, _drivers.length));
    final List<Map<String, dynamic>> driversRange2 = _drivers.sublist(
        (_currentIndex + _pageSize).clamp(0, _drivers.length),
        (_currentIndex + 2 * _pageSize).clamp(0, _drivers.length));

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(60.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 65, 65, 65),
                      width: 2.0,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Daily Active Drivers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 2,
                          indent: 400,
                          endIndent: 400,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LineChartSample2(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(60.0),
                          border: Border.all(
                            color: const Color.fromARGB(255, 65, 65, 65),
                            width: 2.0,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Daily Rides',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: 2,
                                indent: 100,
                                endIndent: 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(60.0),
                          border: Border.all(
                            color: const Color.fromARGB(255, 65, 65, 65),
                            width: 2.0,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Riders Rating',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: 2,
                                indent: 100,
                                endIndent: 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(60.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 65, 65, 65),
                      width: 2.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Online Tricycle Drivers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 2,
                          indent: 400,
                          endIndent: 400,
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: driversRange1
                                      .map((driver) => DriverCard(
                                            driverPhoto: driver[
                                                    'driverPhoto'] ??
                                                'https://via.placeholder.com/100',
                                            firstName:
                                                driver['firstName'] ?? '',
                                            lastName: driver['lastName'] ?? '',
                                            isOnline:
                                                driver['isOnline'] ?? false,
                                          ))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: driversRange2
                                      .map((driver) => DriverCard(
                                            driverPhoto: driver[
                                                    'driverPhoto'] ??
                                                'https://via.placeholder.com/100',
                                            firstName:
                                                driver['firstName'] ?? '',
                                            lastName: driver['lastName'] ?? '',
                                            isOnline:
                                                driver['isOnline'] ?? false,
                                          ))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _previousRange,
                                    icon: const Icon(Icons.arrow_back),
                                    color: Colors.black,
                                  ),
                                  IconButton(
                                    onPressed: _nextRange,
                                    icon: const Icon(Icons.arrow_forward),
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
