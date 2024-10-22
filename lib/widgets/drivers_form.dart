import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'form_validation.dart'; 

class DriversForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController idNumberController;
  final TextEditingController bodyNumberController;
  final TextEditingController emailController;
  final TextEditingController birthdateController;
  final TextEditingController addressController;
  final TextEditingController phoneNumberController;
  final TextEditingController tagController;
  final TextEditingController driverPhotoController;
  final TextEditingController uidController;
  final void Function(String?)? ontagSelected;
  final Function()? onAddPressed;
  final Function()? onEditPressed;

  const DriversForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.idNumberController,
    required this.bodyNumberController,
    required this.emailController,
    required this.birthdateController,
    required this.addressController,
    required this.phoneNumberController,
    required this.tagController,
    required this.driverPhotoController,
    required this.uidController,
    required this.ontagSelected,
    required this.onAddPressed,
    this.onEditPressed,
  });

  @override
  _DriversFormState createState() => _DriversFormState();
}

class _DriversFormState extends State<DriversForm> {
  Uint8List? _image;
  String? _imageFileName;
  String? _selectedTag;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      if (result.files.single.extension == 'png' || result.files.single.extension == 'jpg') {
        setState(() {
          _image = result.files.single.bytes;
          _imageFileName = result.files.single.name;
        });
      } else {
        _showAlertDialog('Only PNG and JPG files are supported.');
      }
    } else {
      print('User canceled image selection.');
    }
  }

  Future<String?> uploadImage(Uint8List imageData, String fileName) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('driver_photos/$fileName');
      UploadTask uploadTask = ref.putData(imageData, SettableMetadata(contentType: 'image/${fileName.split('.').last}'));
      TaskSnapshot snapshot = await uploadTask;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );

      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image. Please try again.')),
      );
      return null;
    }
  }

  void resetFormFields() {
    final controllers = [
      widget.firstNameController,
      widget.lastNameController,
      widget.idNumberController,
      widget.bodyNumberController,
      widget.emailController,
      widget.birthdateController,
      widget.addressController,
      widget.phoneNumberController,
      widget.tagController,
    ];
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      _selectedTag = null;
      _image = null;
      _imageFileName = null;
    });
  }

  Future<void> _selectBirthdate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        String formattedDate =
            "${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}${picked.year}";
        widget.birthdateController.text = formattedDate;
      });
    }
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(message),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
      validator: (value) {
        if (controller == widget.idNumberController || controller == widget.bodyNumberController || controller == widget.phoneNumberController) {
          return FormValidation.validateNumber(value);
        }
        return FormValidation.validateRequired(value);
      },
    );
  }

  Widget buildFormFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              buildTextField(widget.firstNameController, 'First Name'),
              const SizedBox(height: 10.0),
              buildTextField(widget.lastNameController, 'Last Name'),
              const SizedBox(height: 10.0),
              buildTextField(widget.idNumberController, 'ID Number', maxLength: 4),
              const SizedBox(height: 10.0),
              buildTextField(widget.bodyNumberController, 'Body Number', maxLength: 4),
              const SizedBox(height: 10.0),
              buildBirthdateField(),
            ],
          ),
        ),
        const SizedBox(width: 20.0),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: Colors.grey,
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Column(
            children: [
              buildTextField(widget.addressController, 'Address'),
              const SizedBox(height: 10.0),
              buildTextField(widget.phoneNumberController, 'Mobile Number', maxLength: 11),
              const SizedBox(height: 10.0),
              buildTextField(widget.emailController, 'Email'),
              const SizedBox(height: 10.0),
              buildTagSelection(),
            ],
          ),
        ),
      ],
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
            return FormValidation.validateRequired(value);
          },
        ),
      ),
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
                title: const Text('Member'),
                value: 'Member',
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value as String?;
                  });
                  widget.ontagSelected!(value as String?);
                },
              ),
            ),
            Expanded(
              child: RadioListTile(
                title: const Text('Operator'),
                value: 'Operator',
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value as String?;
                  });
                  widget.ontagSelected!(value as String?);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFormButtons() {
    return Center(
      child: ElevatedButton(
        onPressed: widget.onAddPressed,
        child: const Text('Add Driver'),
      ),
    );
  }

  @override
  void dispose() {

    super.dispose();
  }
}
