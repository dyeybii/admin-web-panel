import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RidesChart extends StatefulWidget {
  @override
  _RidesChartState createState() => _RidesChartState();
}

class _RidesChartState extends State<RidesChart> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  late Future<List<Map<String, dynamic>>> tripsDataFuture;

  @override
  void initState() {
    super.initState();
    tripsDataFuture = getTripData();
  }

  Future<List<Map<String, dynamic>>> getTripData() async {
    DatabaseReference tripRef = FirebaseDatabase.instance.ref().child("tripRequests");
    Map<DateTime, int> tripsCount = {};

    try {
      DatabaseEvent snapshot = await tripRef.once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              String? publishDateTimeStr = value['publishDateTime'] as String?;
              if (publishDateTimeStr != null) {
                try {
                  DateTime publishDateTime = DateTime.parse(publishDateTimeStr);
                  if (publishDateTime.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                      publishDateTime.isBefore(_endDate.add(const Duration(days: 1)))) {
                    DateTime tripDate = DateTime(publishDateTime.year, publishDateTime.month, publishDateTime.day);
                    tripsCount[tripDate] = (tripsCount[tripDate] ?? 0) + 1;
                  }
                } catch (e) {
                  print('Error parsing publishDateTime: $e');
                }
              }
            }
          });
        }
      }

      return tripsCount.entries.map((entry) {
        return {
          'tripDate': entry.key,
          'count': entry.value,
        };
      }).toList();
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
        tripsDataFuture = getTripData();
      });
    }
  }

  BarChart buildBarChart(List<Map<String, dynamic>> tripsData) {
    if (tripsData.isEmpty) {
      return BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [],
        ),
      );
    }

    Map<DateTime, int> chartData = {for (var trip in tripsData) trip['tripDate']: trip['count']};
    List<DateTime> xAxisDates = chartData.keys.toList()..sort();

    return BarChart(
      BarChartData(
        maxY: chartData.values.reduce((a, b) => a > b ? a : b).toDouble(),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        barGroups: xAxisDates.map((date) {
          return BarChartGroupData(
            x: xAxisDates.indexOf(date),
            barRods: [
              BarChartRodData(
                toY: chartData[date]!.toDouble(),
                color: Colors.blueAccent,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final DateTime date = xAxisDates[value.toInt()];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 1 == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphCard(List<Map<String, dynamic>> tripsData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(16),
          color: const Color.fromARGB(255, 255, 255, 255), // White background color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300, // Grey box shadow
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Completed Rides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildDateSelector(context, 'From', _startDate, true),
                    const SizedBox(width: 8),
                    _buildDateSelector(context, 'To', _endDate, false),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Month: ${DateFormat('MMMM yyyy').format(_startDate)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: tripsData.isEmpty
                  ? Center(child: Text('No data available', style: TextStyle(fontSize: 16, color: Colors.redAccent)))
                  : buildBarChart(tripsData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, String label, DateTime date, bool isStartDate) {
    return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(DateFormat('MM/dd/yyyy').format(date)),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: tripsDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else {
          return _buildGraphCard(snapshot.data ?? []);
        }
      },
    );
  }
}
