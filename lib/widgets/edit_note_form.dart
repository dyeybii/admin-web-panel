import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNoteForm extends StatefulWidget {
  final String noteId;
  final String noteTitle;
  final Timestamp creationDate;
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
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTitle);
    _contentController = TextEditingController(text: widget.noteContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Note'),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
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
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            String newTitle = _titleController.text;
            String newContent = _contentController.text;

            try {
              await FirebaseFirestore.instance
                  .collection("Notes")
                  .doc(widget.noteId)
                  .update({
                "note_title": newTitle,
                "note_content": newContent,
              });
              Navigator.pop(context);
            } catch (e) {
              print("Error updating data: $e");
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
