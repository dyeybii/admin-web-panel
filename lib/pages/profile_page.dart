import 'dart:io';
import 'dart:typed_data';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/admin_create.dart';
import 'package:admin_web_panel/widgets/admin_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<ProfilePage> {
  String contactNumber = "";
  String email = "";
  String fullName = "";
  String profileImage = "";
  File? selectedAdminImage;
  Uint8List? selectedImageBytes;
  String role = "";
  List<Map<String, dynamic>> adminList = [];

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
            role = doc['role'] ?? ''; // Initialize the role
          });
        }
      } catch (e) {
        print('Error fetching admin data: $e');
      }
    }
  }

  Future<void> _addAuditLog({
    required String action,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'fullName': fullName,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding audit log: $e');
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

      await _addAuditLog(action: 'Updated profile image');
    }
  }

  Future<void> _showPasswordChangeDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 400,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E3192),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Old Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                              style: CustomButtonStyles.elevatedButtonStyle,
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                await _changePassword();
                                Navigator.pop(context);
                              },
                              child: Text('Change Password'),
                              style: CustomButtonStyles.elevatedButtonStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _changePassword() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPasswordController.text);

        // Success SnackBar with custom style
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBarStyles.success('Password changed successfully'),
        );

        oldPasswordController.clear();
        newPasswordController.clear();

        await _addAuditLog(action: 'Changed password');
      } catch (e) {
        // Error SnackBar with custom style
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBarStyles.error('Password change failed: $e'),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Color(0xFF2E3192),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteAccount();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String uid = user.uid;
        await FirebaseFirestore.instance.collection('admin').doc(uid).delete();
        await user.delete();

        // Success SnackBar with custom style
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBarStyles.success('Account deleted successfully'),
        );

        await _addAuditLog(action: 'Deleted account');

        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        // Error SnackBar with custom style
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBarStyles.error('Account deletion failed: $e'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role.isEmpty) {
      return const Center(child: CircularProgressIndicator()); // Loading state
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (role == 'Super Admin')
            ElevatedButton(
              style: CustomButtonStyles.elevatedButtonStyle,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: 400,
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
          // Show View Admin List button only for Super Admin
          if (role == 'Super Admin')
            ElevatedButton(
              style: CustomButtonStyles
                  .elevatedButtonStyle, // Apply your custom button style
              onPressed: () {
                // Show the AdminListDialog as a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdminListDialog();
                  },
                );
              },
              child: const Text('Admin List'), // Text for Admin List
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(50.0),
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
                ElevatedButton(
                  style: CustomButtonStyles.elevatedButtonStyle,
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
                  child: const Text('Change Profile Image'),
                ),
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
                          : 'Contact Number',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showPasswordChangeDialog,
                  child: const Text('Change Password'),
                  style: CustomButtonStyles.elevatedButtonStyle,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showDeleteAccountDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 0, 0),
                  ),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
