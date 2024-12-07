import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CSVExporter {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static void exportToCSV(
      BuildContext context, List<AuditLogEntry> logsToExport) async {
    final csvData = [
      ['Name', 'Action', 'Timestamp'],
      ...logsToExport.map((log) => [
            log.fullName,
            log.action,
            log.timestamp,
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes]);
   final url = html.Url.createObjectUrlFromBlob(blob);
html.AnchorElement(href: url)
  ..setAttribute('download', 'audit_logs.csv')
  ..click();
html.Url.revokeObjectUrl(url); 

ScaffoldMessenger.of(context).showSnackBar(
  CustomSnackBarStyles.info('CSV file downloaded.'),
);


    // Log the action
    await _addAuditLogEntry("Exported audit logs to CSV");
  }

  static Future<void> _addAuditLogEntry(String action) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Query Firestore to fetch the admin document
        final querySnapshot = await _firestore
            .collection('admin')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final adminDoc = querySnapshot.docs.first;

          // Log the action
          await FirebaseFirestore.instance.collection('audit_logs').add({
            'action': action,
            'adminId': adminDoc.id,
            'fullName': adminDoc.data()['fullName'] ?? 'Unknown',
            'profileImage': adminDoc.data()['profileImage'] ?? '',
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          // Handle the case where admin data isn't found
          await FirebaseFirestore.instance.collection('audit_logs').add({
            'action': action,
            'adminId': user.uid,
            'fullName': 'Unknown Admin',
            'profileImage': '',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Error adding audit log entry: $e');
      }
    }
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
    final Timestamp? ts = data['timestamp'] as Timestamp?;
    final formattedTimestamp = ts != null
        ? ts.toDate().toIso8601String()
        : 'Unknown';

    return AuditLogEntry(
      id: id,
      fullName: data['fullName'] ?? 'Unknown',
      action: data['action'] ?? 'Unknown',
      timestamp: formattedTimestamp,
    );
  }
}
