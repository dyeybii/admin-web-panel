import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {
  static const String id = 'account_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Page'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: AdminAccountPage(),
        ),
      ),
    );
  }
}

class AdminAccountPage extends StatefulWidget {
  @override
  _AdminAccountPageState createState() => _AdminAccountPageState();
}

class _AdminAccountPageState extends State<AdminAccountPage> {
  String contactNumber = "";
  String email = "";
  String fullName = "";
  String password = "";
  String profileImage = "";
  File? selectedAdminImage;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController reenterPasswordController = TextEditingController();

  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController newPasswordAdminController = TextEditingController();

  String newAdminImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('admin').doc('adminId').get();
    setState(() {
      contactNumber = doc['contactNumber'];
      email = doc['email'];
      fullName = doc['fullName'];
      password = doc['password'];
      profileImage = doc['profileImage'];
    });
  }

  Future<void> _pickAdminImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        setState(() {
          selectedAdminImage = File(filePath); // Save the selected image for preview
        });
      }
    }
  }

  Future<String> _uploadImage(String filePath, String folder) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg'; 
      Reference ref = FirebaseStorage.instance.ref().child('$folder$fileName');

      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;

      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; 
    }
  }

  Future<void> _createAdmin() async {
    try {
      // Create an admin in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: newPasswordAdminController.text,
      );

      // If the user selected an image, upload it to Firebase Storage
      if (selectedAdminImage != null) {
        newAdminImageUrl = await _uploadImage(selectedAdminImage!.path, 'admin_photos/');
      }

      // Add the admin's details to Firestore
      await FirebaseFirestore.instance.collection('admin').doc(userCredential.user?.uid).set({
        'contactNumber': contactNumberController.text,
        'email': emailController.text,
        'fullName': fullNameController.text,
        'profileImage': newAdminImageUrl.isNotEmpty ? newAdminImageUrl : '',
      });

      // Clear the form and image preview
      contactNumberController.clear();
      emailController.clear();
      fullNameController.clear();
      newPasswordAdminController.clear();
      setState(() {
        selectedAdminImage = null;
        newAdminImageUrl = '';
      });
    } catch (e) {
      print('Error creating admin: $e');
      _showErrorDialog(e.toString());
    }
  }

  void _resetPassword() async {
    if (oldPasswordController.text == password && newPasswordController.text == reenterPasswordController.text) {
      await FirebaseFirestore.instance.collection('admin').doc('adminId').update({
        'password': newPasswordController.text,
      });
      setState(() {
        password = newPasswordController.text;
      });
    } else {
      _showErrorDialog("Passwords do not match or incorrect old password.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
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
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage) as ImageProvider
                    : AssetImage('images/default_avatar.png'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _pickAdminImage,
                child: Text('Upload Profile Image'),
              ),
            ),
            if (selectedAdminImage != null) ...[
              SizedBox(height: 10),
              Image.file(selectedAdminImage!, height: 150, width: 150), // Preview the selected image
            ],
            SizedBox(height: 20),
            Text(
              fullName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Change Password"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: oldPasswordController,
                            decoration: InputDecoration(labelText: 'Old Password'),
                            obscureText: true,
                          ),
                          TextField(
                            controller: newPasswordController,
                            decoration: InputDecoration(labelText: 'New Password'),
                            obscureText: true,
                          ),
                          TextField(
                            controller: reenterPasswordController,
                            decoration: InputDecoration(labelText: 'Re-enter New Password'),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _resetPassword();
                            Navigator.of(context).pop();
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Change Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Create Admin"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: fullNameController,
                            decoration: InputDecoration(labelText: 'Full Name'),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: 'Email'),
                          ),
                          TextField(
                            controller: contactNumberController,
                            decoration: InputDecoration(labelText: 'Contact Number'),
                          ),
                          TextField(
                            controller: newPasswordAdminController,
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _pickAdminImage,
                            child: Text(selectedAdminImage == null ? 'Upload Admin Image' : 'Change Admin Image'),
                          ),
                          if (selectedAdminImage != null) 
                            Image.file(selectedAdminImage!, height: 100, width: 100), // Preview the selected image
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _createAdmin();
                            Navigator.of(context).pop();
                          },
                          child: Text('Create'),
                        ),
                      ],
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
