import 'dart:io';
import 'dart:typed_data';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _newPasswordAdminController = TextEditingController();

  String _selectedRole = 'Admin'; // Default role

  Future<void> _pickAdminImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

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

  Future<String> _uploadImage(String folder) async {
    if (_selectedAdminImage == null && _selectedImageBytes == null) {
      return '';
    }

    setState(() => _isUploading = true);

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('$folder$fileName');

      UploadTask uploadTask = _selectedAdminImage != null
          ? ref.putFile(_selectedAdminImage!)
          : ref.putData(_selectedImageBytes!);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _createAdmin() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _newPasswordAdminController.text,
        );

        String newAdminImageUrl = _selectedAdminImage != null || _selectedImageBytes != null
            ? await _uploadImage('adminProfile/')
            : '';

        await FirebaseFirestore.instance
            .collection('admin')
            .doc(userCredential.user?.uid)
            .set({
          'contactNumber': _contactNumberController.text,
          'email': _emailController.text,
          'fullName': _fullNameController.text,
          'role': _selectedRole,
          'profileImage': newAdminImageUrl,
        });

        _clearForm();
        _showSuccessDialog();
      } catch (e) {
        print('Error creating admin: $e');
      }
    }
  }

  void _clearForm() {
    _contactNumberController.clear();
    _emailController.clear();
    _fullNameController.clear();
    _newPasswordAdminController.clear();
    setState(() {
      _selectedAdminImage = null;
      _selectedImageBytes = null;
      _selectedRole = 'Admin';
    });
  }

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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
        automaticallyImplyLeading: false,
        title: const Text("Create Admin", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E3192),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_selectedAdminImage != null || _selectedImageBytes != null) ...[
                const SizedBox(height: 10),
                _selectedAdminImage != null
                    ? Image.file(_selectedAdminImage!, height: 150, width: 150)
                    : Image.memory(_selectedImageBytes!, height: 150, width: 150),
                const SizedBox(height: 10),
                _isUploading ? const CircularProgressIndicator() : const SizedBox.shrink(),
              ],
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
              _buildTextField(_fullNameController, 'Full Name', (value) {
                if (value == null || value.isEmpty) return 'Full Name is required';
                return null;
              }),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email', (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              }),
              const SizedBox(height: 10),
              _buildTextField(_contactNumberController, 'Contact Number', (value) {
                if (value == null || value.isEmpty) return 'Contact Number is required';
                if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                  return 'Enter a valid 11-digit number';
                }
                return null;
              }),
              const SizedBox(height: 10),
              _buildTextField(_newPasswordAdminController, 'Password', (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              }, obscureText: true),
              const SizedBox(height: 10),
              _buildRoleDropdown(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: CustomButtonStyles.elevatedButtonStyle,
                onPressed: _createAdmin,
                child: const Text("Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? Function(String?) validator,
      {bool obscureText = false}) {
    return Center(
      child: SizedBox(
        width: 250,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          obscureText: obscureText,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Center(
      child: SizedBox(
        width: 250,
        child: DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(
            labelText: 'Role',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          items: ['Admin', 'Super Admin'].map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'Role is required';
            return null;
          },
        ),
      ),
    );
  }
}
