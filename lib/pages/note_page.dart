import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/widgets/note_reader.dart';
import 'package:admin_web_panel/widgets/add_note_form.dart';  // Import the AddNoteForm
import 'package:admin_web_panel/widgets/note_card.dart';  // Import the noteCard
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';


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
                  color: const Color.fromARGB(255, 0, 0, 0),
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
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFFFFFFF),
                        ),
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
