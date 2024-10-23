import 'dart:io';
import 'dart:typed_data';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminCreatePage extends StatefulWidget {
  @override
  _AdminCreatePageState createState() => _AdminCreatePageState();
}

class _AdminCreatePageState extends State<AdminCreatePage> {
  File? _selectedAdminImage;
  Uint8List? _selectedImageBytes;

  bool _isUploading = false;

  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _newPasswordAdminController =
      TextEditingController();

  // Pick Image for Admin Profile
  Future<void> _pickAdminImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _selectedImageBytes = result.files.single.bytes;
        });
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            _selectedAdminImage = File(filePath);
          });
        }
      }
    }
  }

  String _formatFileSize(int bytes) {
    return bytes >= 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
        : '${(bytes / 1024).toStringAsFixed(2)} KB';
  }

  // Upload Image to Firebase Storage with Progress Indicator
  Future<String> _uploadImage(String folder) async {
    if (_selectedAdminImage == null && _selectedImageBytes == null) {
      return '';
    }

    setState(() {
      _isUploading = true; // Start the upload process
    });

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('$folder$fileName');

      UploadTask uploadTask = _selectedAdminImage != null
          ? ref.putFile(_selectedAdminImage!)
          : ref.putData(_selectedImageBytes!);

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {});
      });

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    } finally {
      setState(() {
        _isUploading = false; // End the upload process
      });
    }
  }

  // Create Admin Profile and Upload Image to Firebase Storage
  Future<void> _createAdmin() async {
    try {
      // Create an admin in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _newPasswordAdminController.text,
      );

      // Upload the admin image to Firebase Storage if selected
      String newAdminImageUrl =
          _selectedAdminImage != null || _selectedImageBytes != null
              ? await _uploadImage('adminProfile/')
              : '';

      // Save the admin details to Firestore
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user?.uid)
          .set({
        'contactNumber': _contactNumberController.text,
        'email': _emailController.text,
        'fullName': _fullNameController.text,
        'profileImage': newAdminImageUrl,
      });

      _clearForm();
      _showSuccessDialog(); // Show success dialog after creation
    } catch (e) {
      print('Error creating admin: $e');
      _showErrorDialog(e.toString());
    }
  }

  // Clear form fields after creation
  void _clearForm() {
    _contactNumberController.clear();
    _emailController.clear();
    _fullNameController.clear();
    _newPasswordAdminController.clear();
    setState(() {
      _selectedAdminImage = null;
      _selectedImageBytes = null;
    });
  }

  // Display Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Display Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Admin account created successfully!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the form page
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: const Text(
            "Create Admin",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF2E3192),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display the selected image at the top
              if (_selectedAdminImage != null ||
                  _selectedImageBytes != null) ...[
                const SizedBox(height: 10),
                _selectedAdminImage != null
                    ? Image.file(_selectedAdminImage!, height: 150, width: 150)
                    : Image.memory(_selectedImageBytes!,
                        height: 150, width: 150),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                _isUploading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ],
              // Upload Image Button
              ElevatedButton(
                style: CustomButtonStyles.elevatedButtonStyle,
                onPressed: _pickAdminImage,
                child: Text(
                  _selectedAdminImage == null && _selectedImageBytes == null
                      ? 'Upload Admin Image'
                      : 'Change Admin Image',
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_fullNameController, 'Full Name'),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 10),
              _buildTextField(_contactNumberController, 'Contact Number'),
              const SizedBox(height: 10),
              _buildTextField(_newPasswordAdminController, 'Password',
                  obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                style: CustomButtonStyles.elevatedButtonStyle,
                onPressed: _createAdmin,
                child: const Text("Create Admin"),
              ),
            ],
          )),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Center(
      child: SizedBox(
        width: 250,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          obscureText: obscureText,
        ),
      ),
    );
  }
}
