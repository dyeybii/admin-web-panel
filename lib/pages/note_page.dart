import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/edit_note_form.dart';
import 'package:admin_web_panel/widgets/note_reader.dart';
import 'package:admin_web_panel/widgets/add_note_form.dart';
import 'package:google_fonts/google_fonts.dart';
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

      await FirebaseFirestore.instance.collection('Notes').add({
        'note_title': title,
        'creation_date': creationDate,
        'note_content': content,
        'color_id': 0, // Set a default color_id if needed
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

  Widget noteCard(BuildContext context, Function()? onTap, QueryDocumentSnapshot? doc) {
    final data = doc?.data() as Map<String, dynamic>?;

    if (data != null) {
      final colorId = data['color_id'] as int?;
      final color = colorId != null && colorId >= 0 && colorId < Appstyle.cardsColor.length
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
                    Text(data["note_title"], style: Appstyle.mainTitle),
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
                              try {
                                await FirebaseFirestore.instance.collection("Notes").doc(doc.id).delete();
                              } catch (e) {
                                print("Error deleting document: $e");
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(DateFormat.yMMMd().format(data["creation_date"].toDate()), style: Appstyle.dateTitle),
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
                    onSubmit: (noteTitle, creationDate, noteContent) {
                      _addNote(noteTitle, creationDate, noteContent);
                    },
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
                stream: FirebaseFirestore.instance.collection("Notes").snapshots(),
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
                                    builder: (context) => NoteReaderScreen(note),
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
                        style: GoogleFonts.nunito(color: const Color(0xFFFFFFFF)),
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
