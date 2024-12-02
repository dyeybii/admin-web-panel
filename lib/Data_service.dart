import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to driversAccount node in Realtime Database
  DatabaseReference getDriversDatabaseReference() {
    return _databaseRef.child('driversAccount');
  }

  // Fetch drivers from Realtime Database and filter based on required fields
  Future<List<DriversAccount>> getDriversFromRealtimeDatabase() async {
    List<DriversAccount> driversList = [];
    try {
      final snapshot = await getDriversDatabaseReference().get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        driversList = data.entries
            .map((entry) => DriversAccount.fromJson(Map<String, dynamic>.from(entry.value)))
            .where((driver) => driver != null)
            .cast<DriversAccount>()
            .where((driver) =>
                driver.firstName.isNotEmpty &&
                driver.lastName.isNotEmpty &&
                driver.status.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      rethrow;
    }
    return driversList;
  }

  // New method to fetch drivers from Realtime Database
  Future<List<DriversAccount>> fetchDrivers() async {
    return await getDriversFromRealtimeDatabase();
  }

  // Stream for real-time updates on driver data
  Stream<DatabaseEvent> getDriversStream() {
    return getDriversDatabaseReference().onValue;
  }

  // Update driver status in Realtime Database
  Future<void> updateDriverStatus(String driverId, String newStatus) async {
    try {
      print('Updating driver status for $driverId to $newStatus');
      final driverRef = _databaseRef.child('driversAccount/$driverId');
      await driverRef.update({'status': newStatus});
      print('Driver status updated successfully');
    } catch (e) {
      print('Error updating driver status for driverId $driverId: $e');
      rethrow;
    }
  }

  // Add a driver to Realtime Database, with optional photo upload to Firebase Storage
  Future<void> addDriverToRealtimeDatabase(
      DriversAccount newDriver, Uint8List? imageBytes, String? imageFileName) async {
    try {
      String? driverPhotoUrl;

      if (imageBytes != null && imageFileName != null) {
        driverPhotoUrl = await uploadImage(imageBytes, imageFileName);
      }

      if (driverPhotoUrl != null) {
        newDriver.driverPhoto = driverPhotoUrl;
      }

      await getDriversDatabaseReference()
          .child(newDriver.driverId)
          .set(newDriver.toJson());
    } catch (e) {
      print('Error adding driver: $e');
      rethrow;
    }
  }

  // Helper function to upload driver image to Firebase Storage
  Future<String?> uploadImage(Uint8List imageData, String fileName) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('driver_photos/$fileName');
      UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/${fileName.split('.').last}'),
      );
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Batch upload multiple drivers to Realtime Database
  Future<void> batchUploadDrivers(List<DriversAccount> driversList) async {
    try {
      for (var driver in driversList) {
        await getDriversDatabaseReference()
            .child(driver.driverId)
            .set(driver.toJson());
      }
    } catch (e) {
      print('Error uploading drivers: $e');
      rethrow;
    }
  }

  // Retrieve fare parameters from Firestore
  Future<DocumentSnapshot> getFareParameters() async {
    try {
      return await _firestore
          .collection('fareParameters')
          .doc('currentParameters')
          .get();
    } catch (e) {
      print('Error loading fare parameters: $e');
      rethrow;
    }
  }

  // Update fare parameters in Firestore
  Future<void> saveFareParameters({
    required double baseFare,
    required double distancePerKm,
    required double durationPerMinute,
  }) async {
    try {
      await _firestore
          .collection('fareParameters')
          .doc('currentParameters')
          .update({
        'baseFareAmount': baseFare,
        'distancePerKmAmount': distancePerKm,
        'durationPerMinuteAmount': durationPerMinute,
      });
    } catch (e) {
      print('Error saving fare parameters: $e');
      rethrow;
    }
  }
}
