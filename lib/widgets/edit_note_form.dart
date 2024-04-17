import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNoteForm extends StatefulWidget {
  final String noteId;
  final String noteTitle;
  final String creationDate;
  final String noteContent;

  const EditNoteForm({
    Key? key,
    required this.noteId,
    required this.noteTitle,
    required this.creationDate,
    required this.noteContent,
  }) : super(key: key);

  @override
  _EditNoteFormState createState() => _EditNoteFormState();
}

class _EditNoteFormState extends State<EditNoteForm> {
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTitle);
    _dateController = TextEditingController(text: widget.creationDate);
    _contentController = TextEditingController(text: widget.noteContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Note'),
      content: Form(
        // Your form fields here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Handle save functionality
            String newTitle = _titleController.text;
            String newDate = _dateController.text;
            String newContent = _contentController.text;

            // Update data in Firestore
            try {
              await FirebaseFirestore.instance
                  .collection("Notes")
                  .doc(widget.noteId)
                  .update({
                "note_title": newTitle,
                "creation_date": newDate,
                "note_content": newContent,
              });
              // Data successfully updated
              Navigator.pop(context); // Close the dialog
            } catch (e) {
              // Error updating data
              print("Error updating data: $e");
              // You can display an error message to the user if needed
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
