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
  late String _selectedTag;
  late String _driverPhotoUrl;
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
    _selectedTag = widget.tag;
    _driverPhotoUrl = widget.driverPhoto;
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
    super.dispose();
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final driverRef =
            FirebaseDatabase.instance.ref('driversAccount/${widget.driverId}');
        await driverRef.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'bodyNumber': _bodyNumberController.text,
          'email': _emailController.text,
          'birthdate': _birthdateController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'tag': _selectedTag,
          'driverPhoto': _driverPhotoUrl,
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
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Directly delete user without re-authentication
        await user.delete();

        // Delete from Realtime Database
        final driverRef =
            FirebaseDatabase.instance.ref('driversAccount/${widget.driverId}');
        await driverRef.remove();

        // Delete driver photo from Firebase Storage
        if (_driverPhotoUrl.isNotEmpty) {
          final storageRef =
              FirebaseStorage.instance.refFromURL(_driverPhotoUrl);
          await storageRef.delete();
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver account deleted successfully')),
        );
      }
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

      final newImageUrl = await fileRef.getDownloadURL();
      setState(() {
        _driverPhotoUrl = newImageUrl;
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Container(
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildBackButton(),
                buildProfilePicture(),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: 300, // Set the desired width here
                  child: buildFormFields(),
                ),
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
          _driverPhotoUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_driverPhotoUrl),
                )
              : CircleAvatar(
                  radius: 50,
                  child: const Icon(Icons.person),
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

  Widget buildTextField(TextEditingController controller, String labelText,
      {int? maxLength, String? Function(String?)? validator}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.4, // Adjust width percentage as needed
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        maxLength: maxLength,
        validator: validator,
      ),
    );
  }

  Widget buildFormFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              buildTextField(_firstNameController, 'First Name',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter first name' : null),
              const SizedBox(height: 10.0),
              buildTextField(_lastNameController, 'Last Name',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter last name' : null),
              const SizedBox(height: 10.0),
              buildTextField(_idNumberController, 'ID Number',
                  maxLength: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter ID number' : null),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: _selectBirthdate,
                child: AbsorbPointer(
                  child: buildTextField(_birthdateController, 'Date of Birth'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Column(
            children: [
              buildTextField(_bodyNumberController, 'Body Number',
                  maxLength: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter body number' : null),
              const SizedBox(height: 10.0),
              buildTextField(_addressController, 'Address',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter address' : null),
              const SizedBox(height: 10.0),
              buildTextField(_phoneNumberController, 'Phone Number',
                  maxLength: 11,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter phone number' : null),
              const SizedBox(height: 10.0),
              buildTagSelection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTagSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              const SizedBox(height: 10.0),
              Radio<String>(
                value: 'Operator',
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value!;
                  });
                },
              ),
              const Text('Operator'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Radio<String>(
                value: 'Member',
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value!;
                  });
                },
              ),
              const Text('Member'),
            ],
          ),
        ),
      ],
    );
  }

  void _selectBirthdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdateController.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  Widget buildFormButtons() {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _deleteDriver,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 221, 154, 150),
            ),
            child: const Text('Delete Driver'),
          ),
          const SizedBox(height: 20.0), // Add some spacing between buttons
          ElevatedButton(
            onPressed: _updateDriver,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
