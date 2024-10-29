import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

 
  DatabaseReference getDriversDatabaseReference() {
    return _databaseRef.child('driversAccount'); 
  }


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
            .toList();
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      rethrow; 
    }
    return driversList;
  }


  Stream<DatabaseEvent> getDriversStream() {
    return getDriversDatabaseReference().onValue;
  }


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

      await getDriversDatabaseReference().child(newDriver.driverId).set(newDriver.toJson());
    } catch (e) {
      print('Error adding driver: $e');
      rethrow; 
    }
  }


  Future<String?> uploadImage(Uint8List imageData, String fileName) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('driver_photos/$fileName');
      UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/${fileName.split('.').last}'),
      );
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null; 
    }
  }


  Future<void> batchUploadDrivers(List<DriversAccount> driversList) async {
    try {
      for (var driver in driversList) {
        await getDriversDatabaseReference().child(driver.driverId).set(driver.toJson());
      }
    } catch (e) {
      print('Error uploading drivers: $e');
      rethrow; 
    }
  }


  Future<DocumentSnapshot> getFareParameters() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('fareParameters')
          .doc('currentParameters')
          .get();
      return doc;
    } catch (e) {
      print('Error loading fare parameters: $e');
      rethrow;
    }
  }

  
  Future<void> saveFareParameters({
    required double baseFare,
    required double distancePerKm,
    required double durationPerMinute,
  }) async {
    try {
      await _firestore.collection('fareParameters').doc('currentParameters').update({
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