import 'package:admin_web_panel/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Dashboard extends StatefulWidget {
  static const String id = "\webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // List of online drivers
  final List<String> _online =
      List.generate(500, (index) => 'Driver ${index + 1}');

  int _currentIndex = 20; // Start with driver 21
  int _pageSize = 10; // Display 10 drivers per page

  void _nextRange() {
    setState(() {
      _currentIndex =
          (_currentIndex + _pageSize).clamp(0, _online.length - _pageSize);
    });
  }

  void _previousRange() {
    setState(() {
      _currentIndex =
          (_currentIndex - _pageSize).clamp(0, _online.length - _pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Splitting _online list into two separate lists
    final List<String> driversrange1 =
        _online.sublist(_currentIndex, _currentIndex + _pageSize);
    final List<String> driversrange2 = _online.sublist(
        _currentIndex + _pageSize, _currentIndex + 2 * _pageSize);

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
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(60.0),
                    border: Border.all(
                      color: Colors.black,
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
                            color: Colors.black,
                          ),
                        ),
                        Divider(
                          color: Colors.black,
                          thickness: 2,
                          indent: 100,
                          endIndent: 100,
                        ),
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
                        height: 500,
                        width: 600,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 173, 0, 0),
                          borderRadius: BorderRadius.circular(60.0),
                          border: Border.all(
                            color: Colors.black,
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
                                  color: Colors.white,
                                ),
                              ),
                              Divider(
                                color: Colors.white,
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
                        height: 500,
                        width: 600,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 173, 0, 0),
                          borderRadius: BorderRadius.circular(60.0),
                          border: Border.all(
                            color: Colors.black,
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
                                  color: Colors.white,
                                ),
                              ),
                              Divider(
                                color: Colors.white,
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
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(60.0),
                    border: Border.all(
                      color: Colors.black,
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
                          'Online Drivers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2,
                          indent: 100,
                          endIndent: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Add space before the ListView
                        // Centering the rows of drivers 30 to 39 and drivers 40 to 49
                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Center vertically
                          children: [
                            // Displaying drivers 30 to 39 in the first row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: driversrange1
                                  .map((driver) => DriverCard(driver))
                                  .toList(),
                            ),
                            // Displaying drivers 40 to 49 in the second row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: driversrange2
                                  .map((driver) => DriverCard(driver))
                                  .toList(),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
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
