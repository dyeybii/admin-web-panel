import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditLog {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds an audit log entry for the specified action.
  static Future<void> addLog(String action) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch the admin document directly using the user's UID
        final adminDoc = await _firestore.collection('admin').doc(user.uid).get();

        final data = adminDoc.data();
        final fullName = data?['fullName'] ?? 'Unknown Admin';
        final profileImage = data?['profileImage'] ?? ''; // Default empty if missing

        await LogEntry.add(
          action: action,
          adminId: user.uid,
          fullName: fullName,
          profileImage: profileImage,
        );
      } catch (e) {
        print('Error adding audit log entry: $e');
      }
    }
  }
}

class LogEntry {
  final String adminId;
  final String fullName;
  final String profileImage;
  final String action;
  final DateTime timestamp;

  LogEntry({
    required this.adminId,
    required this.fullName,
    required this.profileImage,
    required this.action,
    required this.timestamp,
  });

  /// Factory constructor to create a LogEntry from Firestore document.
  factory LogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogEntry(
      adminId: data['adminId'] ?? 'Unknown',
      fullName: data['fullName'] ?? 'Unknown',
      profileImage: data['profileImage'] ?? '',
      action: data['action'] ?? 'No Action',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Static method to add a log entry.
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
