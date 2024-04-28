import 'package:cloud_firestore/cloud_firestore.dart';

class AddNote {
  static Future<void> addNote({
    required String noteTitle,
    required Timestamp creationDate,
    required String noteContent,
    required int colorIndex, // Change parameter name to colorIndex
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Notes').add({
        'note_title': noteTitle,
        'creation_date': creationDate,
        'note_content': noteContent,
        'color_id': colorIndex, 
      });
    } catch (e) {
      print('Error adding note: $e');
      throw e; // Rethrow the error to handle it in the calling code
    }
  }
}
