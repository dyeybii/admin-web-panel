import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/edit_note_form.dart';
import 'package:admin_web_panel/widgets/note_reader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class NotePage extends StatefulWidget {
  static const String id = "\webPageTrips";

  const NotePage({required Key key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  void _addNote(String title, Timestamp creationDate, String content) async {
    try {
      if (title.isEmpty || content.isEmpty) {
        throw Exception('Title and content cannot be empty');
      }

      // Generate a random color_id between 1 and 7
      final random = Random();
      final colorId = random.nextInt(7) + 1;

      await FirebaseFirestore.instance.collection('Notes').add({
        'note_title': title,
        'creation_date': creationDate,
        'note_content': content,
        'color_id': colorId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding note: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget noteCard(
      BuildContext context, Function()? onTap, QueryDocumentSnapshot? doc) {
    final data = doc?.data() as Map<String, dynamic>?;

    if (data != null) {
      final colorId = data['color_id'] as int?;
      final color = colorId != null &&
              colorId >= 0 &&
              colorId < Appstyle.cardsColor.length
          ? Appstyle.cardsColor[colorId]
          : Colors.grey;

      final noteId = doc?.id ?? "";
      return InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data["note_title"],
                      style: Appstyle.mainTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: "Edit",
                          onPressed: () {
                            if (doc != null) {
                              showDialog(
                                context: context,
                                builder: (context) => EditNoteForm(
                                  noteId: noteId,
                                  noteTitle: data["note_title"],
                                  creationDate: data["creation_date"],
                                  noteContent: data["note_content"],
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: "Delete",
                          onPressed: () async {
                            if (doc != null) {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Confirm Delete"),
                                  content: Text(
                                      "Are you sure you want to delete this note?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("Notes")
                                      .doc(doc.id)
                                      .delete();
                                } catch (e) {
                                  print("Error deleting document: $e");
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  DateFormat.yMMMd().format(data["creation_date"].toDate()),
                  style: Appstyle.dateTitle,
                ),
                const SizedBox(height: 4.0),
                Text(
                  data["note_content"] ?? '',
                  style: Appstyle.mainContent,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Admin notes"),
          actions: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddNoteForm(
                    onSubmit: _addNote,
                  ),
                );
              },
              child: const Text(
                'Add Note',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your recent Notes",
                style: GoogleFonts.roboto(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.normal,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20.0),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("Notes").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final note = snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NoteReaderScreen(note),
                                  ),
                                );
                              },
                              child: noteCard(
                                context,
                                null,
                                note,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        "There are no Notes",
                        style:
                            GoogleFonts.nunito(color: const Color(0xFFFFFFFF)),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNoteForm extends StatefulWidget {
  final void Function(String, Timestamp, String) onSubmit;

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
            height: 350,
            width: 1000,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration (labelText: 'Title' , border: OutlineInputBorder()),
                  maxLines: 1,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10.0,),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content' , border: OutlineInputBorder()),
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
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final content = _contentController.text.trim();
            final creationDate = Timestamp.fromDate(DateTime.now());

            if (title.isNotEmpty && content.isNotEmpty) {
              widget.onSubmit(title, creationDate, content);
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Title and content cannot be empty'),
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
