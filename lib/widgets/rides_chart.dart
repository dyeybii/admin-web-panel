import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RidesChart extends StatefulWidget {
  @override
  _RidesChartState createState() => _RidesChartState();
}

class _RidesChartState extends State<RidesChart> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  late Future<List<Map<String, dynamic>>> tripsDataFuture;

  @override
  void initState() {
    super.initState();
    tripsDataFuture = getTripData();
  }

  Future<List<Map<String, dynamic>>> getTripData() async {
    DatabaseReference tripRef =
        FirebaseDatabase.instance.ref().child("tripRequests");
    Map<DateTime, int> tripsCount = {};

    try {
      DatabaseEvent snapshot = await tripRef.once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              String? publishDateTimeStr = value['publishDateTime'] as String?;
              if (publishDateTimeStr != null) {
                try {
                  DateTime publishDateTime = DateTime.parse(publishDateTimeStr);
                  if (publishDateTime.isAfter(
                          _startDate.subtract(const Duration(days: 1))) &&
                      publishDateTime
                          .isBefore(_endDate.add(const Duration(days: 1)))) {
                    DateTime tripDate = DateTime(publishDateTime.year,
                        publishDateTime.month, publishDateTime.day);
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

  void _showDateRangePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF2E3192),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                const Text(
                  'Select Date Range',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Spacer(), // Pushes close button to the right
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          content: Container(
            color: Colors.white,
            child: SizedBox(
              width: 300,
              height: 400,
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                maxDate: DateTime.now(),
                selectionColor: const Color(0xFF2E3192),
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    if (args.value is PickerDateRange) {
                      DateTime startDate = args.value.startDate!;
                      DateTime endDate = args.value.endDate ?? startDate;

                      // Limit end date to a maximum of 7 days from start date
                      if (endDate.difference(startDate).inDays > 7) {
                        endDate = startDate.add(const Duration(days: 7));
                      }

                      _startDate = startDate;
                      _endDate = endDate;
                      tripsDataFuture = getTripData();
                    }
                  });
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF2E3192))),
            ),
          ],
        );
      },
    );
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

    Map<DateTime, int> chartData = {
      for (var trip in tripsData) trip['tripDate']: trip['count']
    };
    List<DateTime> xAxisDates = chartData.keys.toList()..sort();

    return BarChart(
      BarChartData(
        maxY: chartData.values.reduce((a, b) => a > b ? a : b).toDouble(),
        gridData: FlGridData(
          show: true,
        ),
        barGroups: xAxisDates.map((date) {
          return BarChartGroupData(
            x: xAxisDates.indexOf(date),
            barRods: [
              BarChartRodData(
                toY: chartData[date]!.toDouble(),
                color: const Color(0xFF2E3192),
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
                  child: Text(DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 10)),
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
                    child: Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 10)),
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
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Completed Rides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display selected date range
            Text(
              'Selected Range: ${DateFormat('MM/dd/yyyy').format(_startDate)} - ${DateFormat('MM/dd/yyyy').format(_endDate)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: tripsData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(fontSize: 16, color: Colors.redAccent),
                      ),
                    )
                  : buildBarChart(tripsData),
            ),
            const Spacer(), // Pushes the button to the bottom
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showDateRangePicker(context),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF2E3192)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  'Select Date Range',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
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
