import 'package:admin_web_panel/widgets/note_card.dart';
import 'package:admin_web_panel/widgets/note_reader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotePage extends StatefulWidget {
  static const String id = "\webPageTrips";

  const NotePage({required Key key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
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
                // Add your functionality here
              },
              child: const Text(
                "Add Notes",
                style: TextStyle(
                    color: Color.fromARGB(
                        255, 0, 0, 0)), // Adjust text color as needed
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
                                () {}, // Placeholder onTap function
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
