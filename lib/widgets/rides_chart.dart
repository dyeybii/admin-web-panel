import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _linecharState createState() => _linecharState();
}

class _linecharState extends State<Dashboard> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> tripsData = []; // List to hold trip data

  @override
  void initState() {
    super.initState();
    getTripData();
  }

Future<void> getTripData() async {
  DatabaseReference tripRef = FirebaseDatabase.instance.ref().child("tripRequests");

  try {
    // Clear tripsData before fetching new data
    setState(() {
      tripsData.clear(); // Clear the old data
    });

    // Fetch data from Firebase
    DatabaseEvent snapshot = await tripRef.once();

    // Check if snapshot has value
    if (snapshot.snapshot.value != null) {
      print('Raw data from Firebase: ${snapshot.snapshot.value}');

      // Parse the data
      Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        Map<DateTime, int> tripsCount = {}; // Map to count trips per day
        data.forEach((key, value) {
          // Print each value to debug
          print('Key: $key');
          print('Value: $value');

          // Ensure value is a Map and contains 'publishDateTime'
          if (value is Map<dynamic, dynamic>) {
            String? publishDateTimeStr = value['publishDateTime'] as String?;

            if (publishDateTimeStr != null) {
              try {
                // Parse the date string to DateTime
                DateTime publishDateTime = DateTime.parse(publishDateTimeStr);

                // Strictly filter data based on the selected date range
                if (publishDateTime.isAfter(_startDate.subtract(Duration(days: 1))) &&
                    publishDateTime.isBefore(_endDate.add(Duration(days: 1)))) {
                  
                  // Count trips per day
                  DateTime tripDate = DateTime(publishDateTime.year, publishDateTime.month, publishDateTime.day);
                  tripsCount[tripDate] = (tripsCount[tripDate] ?? 0) + 1;
                }
              } catch (e) {
                print('Error parsing publishDateTime: $e');
              }
            } else {
              print('publishDateTime is null or not in expected format');
            }
          } else {
            print('Value is not a Map');
          }
        });

        // Convert the map to a list of trips data for the chart
        List<Map<String, dynamic>> formattedTripsData = tripsCount.entries.map((entry) {
          return {
            'tripDate': entry.key,
            'count': entry.value,
          };
        }).toList();

        setState(() {
          tripsData = formattedTripsData; // Update state with filtered data
        });
      } else {
        print('Data is null');
      }
    } else {
      print('No data found at the specified path');
    }
  } catch (error) {
    // Handle any errors during the data fetch
    print('Error fetching data: $error');
  }
}

// Function to build the Bar Chart using fl_chart
BarChart buildBarChart() {
  // Prepare chart data
  Map<DateTime, int> chartData = {}; // Use int for whole numbers

  // Convert tripsData to chartData
  tripsData.forEach((trip) {
    DateTime tripDate = trip['tripDate'];
    int count = trip['count']; // Ensure count is int
    chartData[tripDate] = count;
  });

  // Sort chartData by date
  var sortedEntries = chartData.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  // Calculate max Y value for the left axis titles
  int maxYValue = sortedEntries.isNotEmpty
      ? sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
      : 0;

  // Create a list of DateTime objects for x-axis titles
  List<DateTime> xAxisDates = sortedEntries.map((entry) => entry.key).toList();

  return BarChart(
    BarChartData(
      borderData: FlBorderData(show: false), // No border
      gridData: FlGridData(
        show: true,
        horizontalInterval: 1, // Horizontal lines every 1 unit
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.5), // Line color
            strokeWidth: 1,
          );
        },
        drawVerticalLine: false, // No vertical lines
      ),
      barGroups: sortedEntries.map((entry) {
        return BarChartGroupData(
          x: xAxisDates.indexOf(entry.key), // Use correct index for x
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(), // Convert to double for y
              color: Colors.blueAccent, // Bar color
              width: 25, // Bar width
              borderRadius: BorderRadius.circular(8), // Rounded corners
              backDrawRodData: BackgroundBarChartRodData(
                toY: 0,
                color: Colors.transparent, // Background bar color
              ),
              rodStackItems: [], // No stack items
            ),
          ],
          showingTooltipIndicators: [], // No tooltips
        );
      }).toList(),
      alignment: BarChartAlignment.spaceEvenly, // Flexible spacing between bars
      groupsSpace: 5, // Custom gap between bars; adjust this value as needed
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final DateTime date = xAxisDates[value.toInt()]; // Convert index to date
              final formattedDate = DateFormat('MM/dd').format(date); // Format date
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              );
            },
            interval: 1, // Interval for x-axis titles
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int intValue = value.toInt();
              if (intValue % 1 == 0) {
                // Show only integer values on the left titles
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    intValue.toString(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return Container(); // Hide non-integer values
              }
            },
            interval: 1, // Interval between titles
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int intValue = value.toInt();
              if (intValue % 1 == 0) {
                // Show only integer values on the right titles
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    intValue.toString(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return Container(); // Hide non-integer values
              }
            },
            interval: 1, // Interval between titles
          ),
        ),
      ),
    ),
  );
}




  // Function to show date picker and update selected date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getTripData(); // Refresh data based on selected dates
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildGraphCard(),
      ),
    );
  }

  // Graph card widget
  Widget _buildGraphCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Completed Rides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(DateFormat('MM/dd/yyyy').format(_startDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('to'),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(DateFormat('MM/dd/yyyy').format(_endDate)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: buildBarChart()),
          ],
        ),
      ),
    );
  }
}

