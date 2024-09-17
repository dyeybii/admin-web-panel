import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class EditDriverForm extends StatefulWidget {
  final String driverId;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String bodyNumber;
  final String email;
  final String birthdate;
  final String address;
  final String phoneNumber;
  final String tag;
  final String driverPhoto;

  const EditDriverForm({
    Key? key,
    required this.driverId,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.bodyNumber,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.phoneNumber,
    required this.tag,
    required this.driverPhoto,
  }) : super(key: key);

  @override
  _EditDriverFormState createState() => _EditDriverFormState();
}

class _EditDriverFormState extends State<EditDriverForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _bodyNumberController;
  late TextEditingController _emailController;
  late TextEditingController _birthdateController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _tagController;
  late TextEditingController _driverPhotoController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _idNumberController = TextEditingController(text: widget.idNumber);
    _bodyNumberController = TextEditingController(text: widget.bodyNumber);
    _emailController = TextEditingController(text: widget.email);
    _birthdateController = TextEditingController(text: widget.birthdate);
    _addressController = TextEditingController(text: widget.address);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
    _tagController = TextEditingController(text: widget.tag);
    _driverPhotoController = TextEditingController(text: widget.driverPhoto);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _bodyNumberController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _tagController.dispose();
    _driverPhotoController.dispose();
    super.dispose();
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final driverRef = FirebaseDatabase.instance.ref('driversAccount/${widget.driverId}');
        await driverRef.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'bodyNumber': _bodyNumberController.text,
          'email': _emailController.text,
          'birthdate': _birthdateController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'tag': _tagController.text,
          'driverPhoto': _driverPhotoController.text,
        });

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $e')),
        );
      }
    }
  }

  Future<void> _deleteDriver() async {
    try {
      // Delete from Authentication
      await FirebaseAuth.instance.currentUser?.delete();

      // Delete from Realtime Database
      final driverRef = FirebaseDatabase.instance.ref('driversAccount/${widget.driverId}');
      await driverRef.remove();

      // Delete driver photo from Firebase Storage
      if (widget.driverPhoto.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(widget.driverPhoto);
        await storageRef.delete();
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver account deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  Future<void> selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload the image to Firebase Storage
      await uploadImageToFirebase(image);
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadImageToFirebase(XFile image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('driver_photos');
      final fileRef = storageRef.child(image.name);
      await fileRef.putFile(File(image.path));

      // Get the new image URL and update the controller
      final newImageUrl = await fileRef.getDownloadURL();
      setState(() {
        _driverPhotoController.text = newImageUrl;
      });

      print('Image uploaded successfully: ${image.name}');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 20.0),
        child: Container(
          width: 800.0,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildBackButton(),
                buildProfilePicture(),
                const SizedBox(height: 30.0),
                buildFormFields(),
                const SizedBox(height: 20.0),
                buildFormButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          _driverPhotoController.text.isNotEmpty
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_driverPhotoController.text),
                )
              : const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/default_avatar.png'),
                ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                selectImage();
              },
              icon: const Icon(Icons.add_a_photo),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText, {int? maxLength}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      maxLength: maxLength,
      maxLines: null,
    );
  }

  Widget buildFormFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 10.0),
              buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 10.0),
              buildTextField(_idNumberController, 'ID Number', maxLength: 4),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: _selectBirthdate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _birthdateController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Column(
            children: [
              buildTextField(_bodyNumberController, 'Body Number', maxLength: 4),
              const SizedBox(height: 10.0),
              buildTextField(_addressController, 'Address'),
              const SizedBox(height: 10.0),
              buildTextField(_phoneNumberController, 'Phone Number', maxLength: 15),
              const SizedBox(height: 10.0),
              buildTextField(_emailController, 'Email'),
              const SizedBox(height: 10.0),
              buildTagSelection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTagSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tag',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                title: const Text('Operator'),
                value: 'Operator',
                groupValue: _tagController.text,
                onChanged: (value) {
                  setState(() {
                    _tagController.text = value.toString();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile(
                title: const Text('Member'),
                value: 'Member',
                groupValue: _tagController.text,
                onChanged: (value) {
                  setState(() {
                    _tagController.text = value.toString();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectBirthdate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = selectedDate.toString().substring(0, 10);
      setState(() {
        _birthdateController.text = formattedDate;
      });
    }
  }

  Widget buildFormButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _updateDriver,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Update'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _deleteDriver,
          child: const Text(
            'Delete Driver',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
