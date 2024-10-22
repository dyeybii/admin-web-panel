import 'dart:io';
import 'dart:typed_data';
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
  double _uploadProgress = 0.0; // For progress indicator
  bool _isUploading = false; // To indicate upload state
  String? _imageSize;

  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _newPasswordAdminController = TextEditingController();

  // Pick Image for Admin Profile
  Future<void> _pickAdminImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _selectedImageBytes = result.files.single.bytes;
          _imageSize = _formatFileSize(result.files.single.size);
        });
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            _selectedAdminImage = File(filePath);
            _imageSize = _formatFileSize(_selectedAdminImage!.lengthSync());
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
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
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
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _newPasswordAdminController.text,
      );

      // Upload the admin image to Firebase Storage if selected
      String newAdminImageUrl = _selectedAdminImage != null || _selectedImageBytes != null
          ? await _uploadImage('adminProfile/')
          : '';

      // Save the admin details to Firestore
      await FirebaseFirestore.instance.collection('admin').doc(userCredential.user?.uid).set({
        'contactNumber': _contactNumberController.text,
        'email': _emailController.text,
        'fullName': _fullNameController.text,
        'profileImage': newAdminImageUrl,
      });

      _clearForm();
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
      _uploadProgress = 0.0;
      _imageSize = null;
    });
  }

  // Display Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
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
        title: Text("Create Admin"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
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
              Text(
                "Create Admin",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildTextField(_fullNameController, 'Full Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_contactNumberController, 'Contact Number'),
              _buildTextField(_newPasswordAdminController, 'Password', obscureText: true),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickAdminImage,
                child: Text(_selectedAdminImage == null && _selectedImageBytes == null 
                    ? 'Upload Admin Image' 
                    : 'Change Admin Image'),
              ),
              if (_selectedAdminImage != null || _selectedImageBytes != null) ...[
                SizedBox(height: 10),
                Text('Selected Image Size: $_imageSize'),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _isUploading ? _uploadProgress : null, // Show progress if uploading
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                  minHeight: 5,
                ),
                SizedBox(height: 10),
                _isUploading 
                    ? CircularProgressIndicator() // Show loading indicator while uploading
                    : (_selectedAdminImage != null
                        ? Image.file(_selectedAdminImage!, height: 150, width: 150)
                        : Image.memory(_selectedImageBytes!, height: 150, width: 150)),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAdmin,
                child: Text("Create Admin"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
    );
  }
}
