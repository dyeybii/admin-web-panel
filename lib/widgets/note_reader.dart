import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteReaderScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const NoteReaderScreen(this.doc, {Key? key}) : super(key: key);

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  @override
  Widget build(BuildContext context) {
    int color_id = widget.doc['color_id'];
    return Scaffold(
      backgroundColor: Appstyle.cardsColor[color_id],
      appBar: AppBar(
        backgroundColor: Appstyle.cardsColor[color_id],
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.doc["note_title"],
            style: Appstyle.mainTitle,
          ),
          const SizedBox(
            height: 4.0,
          ),
          Text(
            widget.doc["creation_date"],
            style: Appstyle.dateTitle,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
            widget.doc["note_content"],
            style: Appstyle.mainContent,
          ),
        ],
      ),
    );
  }
}
