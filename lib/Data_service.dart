import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for fare matrix
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore reference

  // Method to get the database reference for drivers
  DatabaseReference getDriversDatabaseReference() {
    return _databaseRef.child('driversAccount'); // Returns the reference to driversAccount
  }

  // Realtime Database: Fetch drivers from Firebase Realtime Database
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
      rethrow; // Rethrow to let the calling function handle the error
    }
    return driversList;
  }

  // Realtime Database: Stream for driver data
  Stream<DatabaseEvent> getDriversStream() {
    return getDriversDatabaseReference().onValue;
  }

  // Realtime Database: Add a new driver
  Future<void> addDriverToRealtimeDatabase(
      DriversAccount newDriver, Uint8List? imageBytes, String? imageFileName) async {
    try {
      String? driverPhotoUrl;
      // Upload image if provided
      if (imageBytes != null && imageFileName != null) {
        driverPhotoUrl = await uploadImage(imageBytes, imageFileName);
      }

      // Set the driver photo URL to the driver object
      if (driverPhotoUrl != null) {
        newDriver.driverPhoto = driverPhotoUrl; // Use driverPhoto directly
      }

      await getDriversDatabaseReference().child(newDriver.driverId).set(newDriver.toJson());
    } catch (e) {
      print('Error adding driver: $e');
      rethrow; // Ensure the error is propagated
    }
  }

  // Upload image to Firebase Storage
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
      return null; // Return null in case of an error
    }
  }

  // Realtime Database: Batch upload multiple drivers
  Future<void> batchUploadDrivers(List<DriversAccount> driversList) async {
    try {
      for (var driver in driversList) {
        await getDriversDatabaseReference().child(driver.driverId).set(driver.toJson());
      }
    } catch (e) {
      print('Error uploading drivers: $e');
      rethrow; // Propagate the error
    }
  }

  // Firestore: Load current fare parameters
  Future<DocumentSnapshot> getFareParameters() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('fareParameters')
          .doc('currentParameters')
          .get();
      return doc;
    } catch (e) {
      print('Error loading fare parameters: $e');
      rethrow; // Propagate the error
    }
  }

  // Firestore: Save updated fare parameters
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
      rethrow; // Propagate the error
    }
  }

  // Firestore: Add a new note
  Future<void> addNote(String title, Timestamp creationDate, String content, int colorId) async {
    try {
      await _firestore.collection('notes').add({
        'note_title': title,
        'creation_date': creationDate,
        'note_content': content,
        'color_id': colorId, // Add color ID to Firestore document
      });
    } catch (e) {
      print('Error adding note: $e');
      rethrow; // Propagate the error
    }
  }

  // Firestore: Stream for notes
  Stream<QuerySnapshot> getNotesStream() {
    return _firestore.collection('notes').snapshots(); // Stream notes from Firestore
  }

  // Firestore: Fetch all notes
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('notes').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching notes: $e');
      rethrow; // Propagate the error
    }
  }
}
