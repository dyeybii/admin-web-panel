import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RidesChart extends StatefulWidget {
  @override
  _RidesChartState createState() => _RidesChartState();
}

class _RidesChartState extends State<RidesChart> {
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
      setState(() {
        tripsData.clear(); // Clear the old data
      });

      // Fetch data from Firebase
      DatabaseEvent snapshot = await tripRef.once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          Map<DateTime, int> tripsCount = {}; // Map to count trips per day
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              String? publishDateTimeStr = value['publishDateTime'] as String?;
              if (publishDateTimeStr != null) {
                try {
                  DateTime publishDateTime = DateTime.parse(publishDateTimeStr);
                  if (publishDateTime.isAfter(_startDate.subtract(Duration(days: 1))) &&
                      publishDateTime.isBefore(_endDate.add(Duration(days: 1)))) {
                    DateTime tripDate = DateTime(publishDateTime.year, publishDateTime.month, publishDateTime.day);
                    tripsCount[tripDate] = (tripsCount[tripDate] ?? 0) + 1;
                  }
                } catch (e) {
                  print('Error parsing publishDateTime: $e');
                }
              }
            }
          });

          List<Map<String, dynamic>> formattedTripsData = tripsCount.entries.map((entry) {
            return {
              'tripDate': entry.key,
              'count': entry.value,
            };
          }).toList();

          setState(() {
            tripsData = formattedTripsData;
          });
        }
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  BarChart buildBarChart() {
    Map<DateTime, int> chartData = {};
    tripsData.forEach((trip) {
      DateTime tripDate = trip['tripDate'];
      int count = trip['count'];
      chartData[tripDate] = count;
    });

    var sortedEntries = chartData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    int maxYValue = sortedEntries.isNotEmpty
        ? sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0;

    List<DateTime> xAxisDates = sortedEntries.map((entry) => entry.key).toList();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: (maxYValue / 5).ceilToDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.5), strokeWidth: 1);
          },
          drawVerticalLine: false,
        ),
        barGroups: sortedEntries.map((entry) {
          return BarChartGroupData(
            x: xAxisDates.indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Colors.blueAccent,
                width: 20, // Adjusted for better spacing
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }).toList(),
        alignment: BarChartAlignment.spaceBetween,
        groupsSpace: 8,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final DateTime date = xAxisDates[value.toInt()];
                final formattedDate = DateFormat('MM/dd').format(date);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(formattedDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value % 1 == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  );
                }
                return Container();
              },
              interval: (maxYValue / 5).ceilToDouble(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        getTripData();
      });
    }
  }

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
            SizedBox(height: 300, child: buildBarChart()), // Limit chart height for responsiveness
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildGraphCard(),
    );
  }
}
