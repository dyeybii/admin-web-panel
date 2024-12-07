import 'dart:convert';
import 'dart:html' as html;
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_pagination/number_pagination.dart';

class AuditLogPageDesktop extends StatefulWidget {
  const AuditLogPageDesktop({super.key});

  @override
  _AuditLogPageDesktopState createState() => _AuditLogPageDesktopState();
}

class _AuditLogPageDesktopState extends State<AuditLogPageDesktop> {
  final TextEditingController searchController = TextEditingController();
  final List<AuditLogEntry> _auditLogs = [];
  List<AuditLogEntry> _filteredLogs = [];
  final List<AuditLogEntry> _selectedLogs = [];
  bool isLoading = false;
  int rowsPerPage = 10;
  int currentPage = 0;
  String? sortColumn;
  bool isAscending = true;
  String selectedTimeRange = 'All Time';

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
    searchController.addListener(_filterLogs);
  }

  Future<void> _fetchAuditLogs() async {
    setState(() => isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .get();

      final logs = querySnapshot.docs.map((doc) {
        return AuditLogEntry.fromFirestore(doc.data(), doc.id);
      }).toList();

      setState(() {
        _auditLogs.clear(); // Clear existing logs before adding new ones
        _auditLogs.addAll(logs);
        _filteredLogs = List.from(logs);
      });

      _applyTimeFilter(); // Apply the selected time range filter
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBarStyles.error('Error fetching logs: $e'),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyTimeFilter() {
    DateTime now = DateTime.now();
    List<AuditLogEntry> logsToFilter = List.from(_auditLogs);

    setState(() {
      if (selectedTimeRange == 'Current') {
        _filteredLogs = logsToFilter.where((log) {
          DateTime logDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(log.timestamp);
          return logDate.isAfter(now.subtract(Duration(days: now.weekday - 1)));
        }).toList();
      } else if (selectedTimeRange == 'Last Week') {
        _filteredLogs = logsToFilter.where((log) {
          DateTime logDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(log.timestamp);
          return logDate.isAfter(now.subtract(Duration(days: 7)));
        }).toList();
      } else if (selectedTimeRange == 'Last Month') {
        _filteredLogs = logsToFilter.where((log) {
          DateTime logDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(log.timestamp);
          return logDate.isAfter(now.subtract(Duration(days: 30)));
        }).toList();
      } else {
        _filteredLogs = List.from(_auditLogs);
      }
    });
  }

  void _filterLogs() {
    setState(() {
      final query = searchController.text.toLowerCase();
      _filteredLogs = _auditLogs.where((log) {
        return log.fullName.toLowerCase().contains(query) ||
            log.action.toLowerCase().contains(query) ||
            log.timestamp.toLowerCase().contains(query);
      }).toList();
      _applyTimeFilter(); // Reapply time filter after search
    });
  }

  void _sort<T>(String column, Comparable<T> Function(AuditLogEntry log) getField) {
    setState(() {
      isAscending = sortColumn == column ? !isAscending : true;
      sortColumn = column;

      _filteredLogs.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return isAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  void _exportToCSV() {
    final logsToExport =
        _selectedLogs.isNotEmpty ? _selectedLogs : _filteredLogs;
    final csvData = [
      ['Name', 'Action', 'Timestamp'],
      ...logsToExport.map((log) => [log.fullName, log.action, log.timestamp]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'audit_logs.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
  title: Row(
    children: [
      const Expanded(child: Text('Audit Logs')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 600
              ? 250
              : 180,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color(0xFF2E3192), width: 2.0),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color(0xFF2E3192), width: 2.0),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color(0xFF2E3192), width: 2.0),
                borderRadius: BorderRadius.circular(5),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    ],
  ),
  actions: [
    // Refresh Button
    Container(
      decoration: BoxDecoration(
        color: Color(0xFF2E3192),  // Purple background
        borderRadius: BorderRadius.circular(15),  // Border radius of 15
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white),
        onPressed: _fetchAuditLogs,  // Refresh button functionality
      ),
    ),
    // Add space between the refresh button and download button
    SizedBox(width: 16), // Adjust width for desired spacing
    
    // Download Button
    Container(
      decoration: BoxDecoration(
        color: Color(0xFF2E3192),  // Purple background
        borderRadius: BorderRadius.circular(15),  // Rounded corners
      ),
      child: IconButton(
        icon: const Icon(Icons.download, color: Colors.white),  // White icon
        onPressed: _exportToCSV,
      ),
    ),
    // Add space between the download button and the dropdown
    SizedBox(width: 16), // Adjust width for desired spacing
    
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
        value: selectedTimeRange,
        onChanged: (newValue) {
          setState(() {
            selectedTimeRange = newValue!;
            _applyTimeFilter();
          });
        },
        items: <String>['All Time', 'Current', 'Last Week', 'Last Month']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    ),
  ],
),



        body: Stack(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredLogs.isEmpty)
              const Center(child: Text('No audit logs found.'))
            else
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: const Text('Name'),
                            onSort: (index, _) => _sort('Name', (log) => log.fullName),
                          ),
                          DataColumn(
                            label: const Text('Action'),
                            onSort: (index, _) => _sort('Action', (log) => log.action),
                          ),
                          DataColumn(
                            label: const Text('Timestamp'),
                            onSort: (index, _) => _sort('Timestamp', (log) => log.timestamp),
                          ),
                        ],
                        rows: _filteredLogs
                            .skip(currentPage * rowsPerPage)
                            .take(rowsPerPage)
                            .map(
                              (log) => DataRow(
                                selected: _selectedLogs.contains(log),
                                onSelectChanged: (isSelected) {
                                  setState(() {
                                    if (isSelected == true) {
                                      _selectedLogs.add(log);
                                    } else {
                                      _selectedLogs.remove(log);
                                    }
                                  });
                                },
                                cells: [
                                  DataCell(Text(log.fullName)),
                                  DataCell(Text(log.action)),
                                  DataCell(Text(log.timestamp)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: NumberPagination(
                        totalPages: (_filteredLogs.length / rowsPerPage).ceil(),
                        currentPage: currentPage + 1,
                        onPageChanged: (pageNumber) {
                          setState(() {
                            currentPage = pageNumber - 1;
                          });
                        },
                        controlButtonSize: const Size(25, 25),
                        numberButtonSize: const Size(25, 25),
                        selectedButtonColor: const Color(0xFF2E3192),
                        selectedNumberColor: Colors.white,
                        unSelectedButtonColor: Colors.white,
                        unSelectedNumberColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class AuditLogEntry {
  final String id;
  final String fullName;
  final String action;
  final String timestamp;

  AuditLogEntry({
    required this.id,
    required this.fullName,
    required this.action,
    required this.timestamp,
  });

  factory AuditLogEntry.fromFirestore(Map<String, dynamic> data, String id) {
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    final formattedTimestamp = timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
        : 'Unknown';

    return AuditLogEntry(
      id: id,
      fullName: data['fullName'] ?? 'Unknown',
      action: data['action'] ?? 'Unknown',
      timestamp: formattedTimestamp,
    );
  }
}
