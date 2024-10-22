import 'dart:io';
import 'dart:typed_data';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/admin_create.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universal_io/io.dart' as universal_io;

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String contactNumber = "";
  String email = "";
  String fullName = "";
  String profileImage = "";
  File? selectedAdminImage;
  Uint8List? selectedImageBytes;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('admin').doc(uid).get();
      setState(() {
        contactNumber = doc['contactNumber'] ?? '';
        email = doc['email'] ?? '';
        fullName = doc['fullName'] ?? '';
        profileImage = doc['profileImage'] ?? '';
      });
    }
  }

  // Pick Image for Admin Profile
  Future<void> _pickAdminImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    
    if (result != null) {
      if (universal_io.Platform.isAndroid || universal_io.Platform.isIOS || universal_io.Platform.isMacOS || universal_io.Platform.isLinux || universal_io.Platform.isWindows) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            selectedAdminImage = File(filePath); // Save the selected image for preview
          });
        }
      } else if (kIsWeb) {
        setState(() {
          selectedImageBytes = result.files.single.bytes; // Save the selected image bytes for preview
        });
      }
    }
  }

  // Upload Image to Firebase Storage
  Future<String> _uploadImage(String folder) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg'; 
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage) 
                  : AssetImage('images/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _pickAdminImage,
              child: Text('Upload Profile Image'),
            ),
            if (selectedAdminImage != null) ...[
              SizedBox(height: 10),
              Image.file(selectedAdminImage!, height: 150, width: 150), // Image Preview
            ] else if (selectedImageBytes != null) ...[
              SizedBox(height: 10),
              Image.memory(selectedImageBytes!, height: 150, width: 150), // Web Image Preview
            ],
            SizedBox(height: 20),
            // Display full name and email below the upload button
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'Full Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  email.isNotEmpty ? email : 'Email',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: CustomButtonStyles.elevatedButtonStyle,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: AdminCreatePage(), // Open Admin Create Page within a Material context
                    );
                  },
                );
              },
              child: Text('Create Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
