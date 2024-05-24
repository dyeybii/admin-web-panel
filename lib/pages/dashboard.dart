import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  static const String id = "\webPageDashboard";

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // List of online drivers
  final List<String> _online = [
    'Driver 1', 'Driver 2', 'Driver 3', 'Driver 4', 'Driver 5', 'Driver 6', 'Driver 7', 'Driver 8', 'Driver 9', 'Driver 10',
    'Driver 11', 'Driver 12', 'Driver 13', 'Driver 14', 'Driver 15', 'Driver 16', 'Driver 17', 'Driver 18', 'Driver 19', 'Driver 20',
    'Driver 21', 'Driver 22', 'Driver 23', 'Driver 24', 'Driver 25', 'Driver 26', 'Driver 27', 'Driver 28', 'Driver 29', 'Driver 30',
    'Driver 31', 'Driver 32', 'Driver 33', 'Driver 34', 'Driver 35', 'Driver 36', 'Driver 37', 'Driver 38', 'Driver 39', 'Driver 40',
  ];

  int _currentIndex = 9; // Start with driver 30
  int _pageSize = 10; // Display 10 drivers per page

  @override
  Widget build(BuildContext context) {
    // Splitting _online list into two separate lists
    final List<String> drivers30to39 = _online.sublist(_currentIndex, _currentIndex + _pageSize);
    final List<String> drivers40to49 = _online.sublist(_currentIndex + _pageSize, _currentIndex + 2 * _pageSize);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                  borderRadius: BorderRadius.circular(60.0),
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
                      const SizedBox(height: 10), // Add space before the ListView
                      // Centering the rows of drivers 30 to 39 and drivers 40 to 49
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                        children: [
                          // Displaying drivers 30 to 39 in the first row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: drivers30to39.map((driver) => DriverCard(driver)).toList(),
                          ),
                          // Previous and Next buttons
                          
                          // Displaying drivers 40 to 49 in the second row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: drivers40to49.map((driver) => DriverCard(driver)).toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _currentIndex = (_currentIndex - _pageSize).clamp(0, _online.length - 2 * _pageSize);
                                  });
                                },
                                icon: const Icon(Icons.arrow_back),
                              ),
                              Text('Drivers ${_currentIndex + 1} to ${_currentIndex + 2 * _pageSize}'),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _currentIndex = (_currentIndex + _pageSize).clamp(0, _online.length - 2 * _pageSize);
                                  });
                                },
                                icon: const Icon(Icons.arrow_forward),
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
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[300],
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0), // Adding space between columns
                  Expanded(
                    flex: 7,
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[400],
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
