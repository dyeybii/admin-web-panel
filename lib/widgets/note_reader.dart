import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteReaderScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const NoteReaderScreen(this.doc, {Key? key}) : super(key: key);

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  @override
  Widget build(BuildContext context) {
    int colorId = widget.doc['color_id'];
    Timestamp creationDate = widget.doc['creation_date'];
    DateTime date = creationDate.toDate();
    String formattedDate = DateFormat.yMMMd().format(date);
    String noteTitle = widget.doc['note_title'];
    String noteContent = widget.doc['note_content'];

    return Scaffold(
      backgroundColor: Appstyle.cardsColor[colorId],
      appBar: AppBar(
        backgroundColor: Appstyle.cardsColor[colorId],
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              noteTitle,
              style: Appstyle.mainTitle,
            ),
            const SizedBox(height: 4.0),
            Text(
              formattedDate,
              style: Appstyle.dateTitle,
            ),
            const SizedBox(height: 8.0),
            Text(
              noteContent,
              style: Appstyle.mainContent,
            ),
          ],
        ),
      ),
    );
  }
}
