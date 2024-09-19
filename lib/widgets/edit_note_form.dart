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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  Future<void> _updateNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

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
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating data: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _updateNote,
                child: const Text('Save'),
              ),
      ],
    );
  }
}