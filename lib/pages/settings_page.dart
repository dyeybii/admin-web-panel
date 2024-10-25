// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/admin_create.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart' as universal_io;
import 'package:cached_network_image/cached_network_image.dart';

class settingsPage extends StatefulWidget {
  @override
  _settingsPageState createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {
  String contactNumber = "";
  String email = "";
  String fullName = "";
  String profileImage = "";
  File? selectedAdminImage;
  Uint8List? selectedImageBytes;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('admin').doc(uid).get();

        if (doc.exists) {
          setState(() {
            contactNumber = doc['contactNumber'] ?? '';
            email = doc['email'] ?? '';
            fullName = doc['fullName'] ?? '';
            profileImage = doc['profileImage'] ?? '';
          });
        } else {
          print('Admin document does not exist for uid: $uid');
          setState(() {
            contactNumber = '';
            email = '';
            fullName = '';
            profileImage = '';
          });
        }
      } catch (e) {
        print('Error fetching admin data: $e');
      }
    }
  }

  Future<void> _pickAdminImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        selectedImageBytes = await pickedFile.readAsBytes();
      } else {
        setState(() {
          selectedAdminImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String> _uploadImage(String folder) async {
    try {
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('$folder$fileName');

      UploadTask uploadTask;
      if (selectedAdminImage != null) {
        uploadTask = ref.putFile(selectedAdminImage!);
      } else if (selectedImageBytes != null) {
        uploadTask = ref.putData(selectedImageBytes!);
      } else {
        return '';
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _updateProfileImage(String downloadURL) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      await FirebaseFirestore.instance.collection('admin').doc(uid).update({
        'profileImage': downloadURL,
      });

      setState(() {
        profileImage = downloadURL;
        selectedAdminImage = null;
        selectedImageBytes = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          ElevatedButton(
            style: CustomButtonStyles.elevatedButtonStyle,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Set border radius
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          15), // Ensure the content also has rounded corners
                      child: Container(
                        width: 400, // Set your desired width
                        height: 600,
                        child: AdminCreatePage(),
                      ),
                    ),
                  );
                },
              );
            },
            child: const Text('+ Create Admin'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: profileImage,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 50,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    await _pickAdminImage();
                    if (selectedAdminImage != null ||
                        selectedImageBytes != null) {
                      String downloadURL = await _uploadImage('admin_images/');
                      if (downloadURL.isNotEmpty) {
                        await _updateProfileImage(downloadURL);
                      }
                    }
                  },
                  child: const Text('Change Profile image'),
                ),
                if (selectedAdminImage != null) ...[
                  const SizedBox(height: 10),
                  Image.file(selectedAdminImage!, height: 150, width: 150),
                ] else if (selectedImageBytes != null) ...[
                  const SizedBox(height: 10),
                  Image.memory(selectedImageBytes!, height: 150, width: 150),
                ],
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : 'Full Name',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email.isNotEmpty ? email : 'Email',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      contactNumber.isNotEmpty
                          ? contactNumber
                          : 'Contact Number', maxLines: 11,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}