import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

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
  final String codingScheme;
  final String tag;
  final String driverPhoto;
  final String role;

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
    required this.codingScheme,
    required this.tag,
    required this.driverPhoto,
    required this.role,
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
  late TextEditingController _codingSchemeController;
  late TextEditingController _tagController;
  late TextEditingController _driverPhotoController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedRole;

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
    _codingSchemeController = TextEditingController(text: widget.codingScheme);
    _tagController = TextEditingController(text: widget.tag);
    _driverPhotoController = TextEditingController(text: widget.driverPhoto);
    _selectedRole = widget.role;
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
    _codingSchemeController.dispose();
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
        await FirebaseFirestore.instance
            .collection('driversAccount')
            .doc(widget.driverId)
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'bodyNumber': _bodyNumberController.text,
          'email': _emailController.text,
          'birthdate': _birthdateController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'codingScheme': _codingSchemeController.text,
          'tag': _tagController.text,
          'driverPhoto': _driverPhotoController.text,
          'role': _selectedRole,
        });

        await FirebaseDatabase.instance
            .ref('driversAccount/${widget.driverId}')
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'bodyNumber': _bodyNumberController.text,
          'email': _emailController.text,
          'birthdate': _birthdateController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'codingScheme': _codingSchemeController.text,
          'tag': _tagController.text,
          'driverPhoto': _driverPhotoController.text,
          'role': _selectedRole,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
     
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildProfilePicture(),
              const SizedBox(height: 30.0),
              buildFormFields(),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _updateDriver,
                          child: const Text('Save'),
                        ),
                ],
              ),
            ],
          ),
        ),
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

  Future<void> selectImage() async {
    // Your implementation for selecting image
  }

  Widget buildTextField(TextEditingController controller, String labelText,
      {int? maxLength}) {
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
    return Column(
      children: [
        buildTextField(_firstNameController, 'First Name'),
        const SizedBox(height: 10.0),
        buildTextField(_lastNameController, 'Last Name'),
        const SizedBox(height: 10.0),
        buildTextField(_idNumberController, 'ID Number', maxLength: 4),
        const SizedBox(height: 10.0),
        buildTextField(_bodyNumberController, 'Body Number', maxLength: 4),
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
        const SizedBox(height: 10.0),
        buildTextField(_codingSchemeController, 'Coding Scheme', maxLength: 3),
        const SizedBox(height: 10.0),
        buildTextField(_addressController, 'Address'),
        const SizedBox(height: 10.0),
        buildTextField(_phoneNumberController, 'Phone Number', maxLength: 11),
        const SizedBox(height: 10.0),
        buildTextField(_emailController, 'Email'),
        const SizedBox(height: 10.0),
        buildRoleSelection(),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Future<void> _selectBirthdate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        // Format the date as MMDDYYYY
        String formattedDate = "${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}${picked.year}";
        _birthdateController.text = formattedDate;
      });
    }
  }

  Widget buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String?>(
                title: const Text('Member'),
                value: 'member',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String?>(
                title: const Text('Operator'),
                value: 'operator',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
