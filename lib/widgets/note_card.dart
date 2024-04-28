import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_note_form.dart';
import 'package:intl/intl.dart';


Widget noteCard(
    BuildContext context, Function()? onTap, QueryDocumentSnapshot? doc) {
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
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Confirm Delete"),
                                content: Text("Are you sure you want to delete this note?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirmDelete == true) {
                              try {
                                await FirebaseFirestore.instance.collection("Notes").doc(doc.id).delete();
                                // Document successfully deleted
                              } catch (e) {
                                // Error deleting document
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
