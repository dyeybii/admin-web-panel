import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditDriverForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController idNumberController;
  final TextEditingController bodyNumberController;
  final TextEditingController emailController;
  final TextEditingController birthdateController;
  final TextEditingController addressController;
  final TextEditingController emergencyContactController;
  final TextEditingController codingSchemeController;
  final TextEditingController tagController;
  final TextEditingController driverPhotoController;
  final void Function(String?)? onRoleSelected;
  final Function()? onSavePressed;
  final Function()? onCancelPressed;

  const EditDriverForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.idNumberController,
    required this.bodyNumberController,
    required this.emailController,
    required this.birthdateController,
    required this.addressController,
    required this.emergencyContactController,
    required this.codingSchemeController,
    required this.tagController,
    required this.driverPhotoController,
    required this.onRoleSelected,
    required this.onSavePressed,
    required this.onCancelPressed,
  });

  @override
  _EditDriverFormState createState() => _EditDriverFormState();
}

class _EditDriverFormState extends State<EditDriverForm> {
  Uint8List? _image;

  Future<void> selectImage() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 20.0),
        child: Container(
          height: 600.0,
          width: 800.0,
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

  Widget buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          _image != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: MemoryImage(_image!),
                )
              : const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/default_avatar.png'),
                ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: selectImage,
              icon: const Icon(Icons.add_a_photo),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextField(widget.firstNameController, 'First Name'),
        const SizedBox(height: 10.0),
        buildTextField(widget.lastNameController, 'Last Name'),
        const SizedBox(height: 10.0),
        buildTextField(widget.idNumberController, 'ID Number', maxLength: 4),
        const SizedBox(height: 10.0),
        buildTextField(widget.bodyNumberController, 'Body Number', maxLength: 4),
        const SizedBox(height: 10.0),
        buildTextField(widget.codingSchemeController, 'Coding Scheme', maxLength: 3),
        const SizedBox(height: 10.0),
        buildTextField(widget.addressController, 'Address'),
        const SizedBox(height: 10.0),
        buildTextField(widget.emergencyContactController, 'Emergency Contact #', maxLength: 11),
        const SizedBox(height: 10.0),
        buildTextField(widget.emailController, 'Email'),
        const SizedBox(height: 10.0),
        buildBirthdateField(),
        const SizedBox(height: 10.0),
        buildRoleSelection(),
      ],
    );
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
      validator: (value) {
        if (value!.isEmpty) {
          return '$labelText is required';
        }
        return null;
      },
    );
  }

  Widget buildBirthdateField() {
    return GestureDetector(
      onTap: _selectBirthdate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.birthdateController,
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Date of Birth is required';
            }
            return null;
          },
        ),
      ),
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
        widget.birthdateController.text =
            picked.toIso8601String().split('T').first;
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
                groupValue: widget.tagController.text,
                onChanged: (value) {
                  setState(() {
                    widget.onRoleSelected?.call(value);
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String?>(
                title: const Text('Operator'),
                value: 'operator',
                groupValue: widget.tagController.text,
                onChanged: (value) {
                  setState(() {
                    widget.onRoleSelected?.call(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFormButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onCancelPressed,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10.0),
        ElevatedButton(
          onPressed: widget.onSavePressed,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

