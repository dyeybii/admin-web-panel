import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController codingSchemeController;
  final TextEditingController tagController;
  final TextEditingController driver_photosController;

  final TextEditingController uidController;
  final void Function(String?)? onRoleSelected;
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
    required this.codingSchemeController,
    required this.tagController,
    required this.driver_photosController,
    required this.uidController,
    required this.onRoleSelected,
    required this.onAddPressed,
    this.onEditPressed,
  });

  @override
  _DriversFormState createState() => _DriversFormState();
}

class _DriversFormState extends State<DriversForm> {
  Uint8List? _image;
  String? _imageFileName;
  String? _selectedRole;
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
      Reference ref = FirebaseStorage.instance.ref().child('driverPhotos/$fileName');
      UploadTask uploadTask = ref.putData(imageData, SettableMetadata(contentType: 'image/${fileName.split('.').last}'));
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
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
      widget.codingSchemeController,
      widget.tagController,
    ];

    for (var controller in controllers) {
      controller.clear();
    }

    setState(() {
      _selectedRole = null;
      _image = null;
      _imageFileName = null;
    });
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
        String formattedDate =
            "${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}${picked.year}";
        widget.birthdateController.text = formattedDate;
      });
    }
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
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
              buildTextField(widget.codingSchemeController, 'Coding Scheme', maxLength: 3),
              const SizedBox(height: 10.0),
              buildTextField(widget.addressController, 'Address'),
              const SizedBox(height: 10.0),
              buildTextField(widget.phoneNumberController, 'Cellphone Number', maxLength: 11),
              const SizedBox(height: 10.0),
              buildTextField(widget.emailController, 'Email'),
              const SizedBox(height: 10.0),
              buildRoleSelection(),
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
        ),
      ),
    );
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
                    widget.onRoleSelected?.call(value);
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
          onPressed: () {
            resetFormFields();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10.0),
        ElevatedButton(
          onPressed: () async {
            if (widget.formKey.currentState!.validate()) {
              try {
                UserCredential userCredential =
                    await _auth.createUserWithEmailAndPassword(
                  email: widget.emailController.text,
                  password: widget.birthdateController.text,
                );

                print('User created: ${userCredential.user?.email}');

                if (_image != null) {
                  String? downloadURL = await uploadImage(
                      _image!, 'driverPhoto_${userCredential.user?.uid}.${_imageFileName!.split('.').last}');
                  if (downloadURL != null) {
                    widget.driver_photosController.text = downloadURL;
                  } else {
                    _showAlertDialog('Image upload failed. Please try again.');
                    return;
                  }
                }

                if (widget.onAddPressed != null) {
                  widget.onAddPressed!();
                }

                await _addMemberToRealtimeDatabase(
                  context: context,
                  birthdate: widget.birthdateController.text,
                  bodyNumber: widget.bodyNumberController.text,
                  driverPhoto: widget.driver_photosController.text,
                  email: widget.emailController.text,
                  firstName: widget.firstNameController.text,
                  idNumber: widget.idNumberController.text,
                  lastName: widget.lastNameController.text,
                  phoneNumber: widget.phoneNumberController.text,
                  uid: userCredential.user?.uid,
                );
              } on FirebaseAuthException catch (e) {
                _showAlertDialog(e.message ?? 'An error occurred');
              } catch (e) {
                print('Error: $e');
              }
            }
          },
          child: const Text('Add Driver & Create Account'),
        ),
        const SizedBox(width: 10.0),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            if (widget.onEditPressed != null) {
              widget.onEditPressed!();
            }
          },
        ),
      ],
    );
  }
}

Future<void> _addMemberToRealtimeDatabase({
  required BuildContext context,
  required String? birthdate,
  required String? bodyNumber,
  required String? driverPhoto,
  required String? email,
  required String? firstName,
  required String? idNumber,
  required String? lastName,
  required String? phoneNumber,
  required String? uid,
}) async {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  databaseReference.child('driversAccount').push().set({
    'birthdate': birthdate,
    'bodyNumber': bodyNumber,
    'driverPhoto': driverPhoto,
    'email': email,
    'firstName': firstName,
    'idNumber': idNumber,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'uid': uid,
  }).then((_) {
    print('Member added to Realtime Database');
    
  }).catchError((error) {
    print('Error adding member to Realtime Database: $error');
  });
}
