import 'package:cloud_firestore/cloud_firestore.dart';

class LogEntry {
  static Future<void> add({
    required String action,
    required String adminId,
    required String fullName,
    required String profileImage,
  }) async {
    final logEntry = {
      'adminId': adminId,
      'fullName': fullName,
      'profileImage': profileImage,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('audit_logs').add(logEntry);
  }
}
