// firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drivers_account.dart';

Future<List<DriversAccount>> fetchDriversAccounts() async {
  final snapshot = await FirebaseFirestore.instance.collection('driversAccount').get();
  
  return snapshot.docs.map((doc) {
    return DriversAccount.fromJson(doc.data() as Map<String, dynamic>);
  }).toList();
}