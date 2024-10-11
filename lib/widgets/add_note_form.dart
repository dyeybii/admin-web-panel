import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoteForm extends StatefulWidget {
  final void Function(String, String) onSubmit; // Accept title and content

  const AddNoteForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _AddNoteFormState createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: SizedBox(
            height: 200,
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  maxLines: 1,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                  maxLines: 4,
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
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final content = _contentController.text.trim();

            if (title.isNotEmpty && content.isNotEmpty) {
              final creationDate = Timestamp.fromDate(DateTime.now());
              widget.onSubmit(title, content); // Call the onSubmit function
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Name and content cannot be empty'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
