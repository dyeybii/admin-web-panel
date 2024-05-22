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
    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();

    if (newTitle.isEmpty || newContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and content cannot be empty'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection("Notes").doc(widget.noteId).update({
        "note_title": newTitle,
        "note_content": newContent,
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating note: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Note'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: SizedBox(
            height: 350,
            width: 1000,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  maxLines: 1,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10.0,),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                  maxLines: 10,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
