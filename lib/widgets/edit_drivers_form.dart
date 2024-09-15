import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart'; // Ensure the correct path

class EditDriverForm extends StatefulWidget {
  final DriversAccount driver;

  const EditDriverForm({Key? key, required this.driver}) : super(key: key);

  @override
  _EditDriverFormState createState() => _EditDriverFormState();
}

class _EditDriverFormState extends State<EditDriverForm> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController idNumberController;
  late TextEditingController bodyNumberController;
  late TextEditingController emailController;
  late TextEditingController birthdateController;
  late TextEditingController addressController;
  late TextEditingController phoneNumberController;
  late TextEditingController codingSchemeController;
  late TextEditingController tagController;
  late TextEditingController driverPhotosController;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    firstNameController = TextEditingController(text: driver.firstName);
    lastNameController = TextEditingController(text: driver.lastName);
    idNumberController = TextEditingController(text: driver.idNumber);
    bodyNumberController = TextEditingController(text: driver.bodyNumber);
    emailController = TextEditingController(text: driver.email);
    birthdateController = TextEditingController(text: driver.birthdate);
    addressController = TextEditingController(text: driver.address);
    phoneNumberController = TextEditingController(text: driver.phoneNumber);
    codingSchemeController = TextEditingController(text: driver.codingScheme);
    tagController = TextEditingController(text: driver.tag);
    driverPhotosController = TextEditingController(text: driver.driverPhotos);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        driverPhotosController.text = pickedFile.path;
      });
    }
  }

  void _updateDriverData() async {
    try {

      await _databaseRef.child('driversAccount').update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'idNumber': idNumberController.text,
        'bodyNumber': bodyNumberController.text,
        'email': emailController.text,
        'birthdate': birthdateController.text,
        'address': addressController.text,
        'phoneNumber': phoneNumberController.text,
        'codingScheme': codingSchemeController.text,
        'tag': tagController.text,
        'driver_photos': driverPhotosController.text,
        'role': widget.driver.role,
        'deviceToken': widget.driver.deviceToken,
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating data: $e')),
      );
    }
  }

  void _deleteDriverData() async {
    try {


      await _databaseRef.child('driversAccount')..remove();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteDriverData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileImage(driverPhotosController.text, _pickImage),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    _buildEditableTextField('First Name', firstNameController),
                    _buildEditableTextField('Last Name', lastNameController),
                    _buildEditableTextField('ID Number', idNumberController),
                    _buildEditableTextField('Body Number', bodyNumberController),
                    _buildEditableTextField('Email', emailController),
                    _buildEditableTextField('Date of Birth', birthdateController),
                    _buildEditableTextField('Address', addressController),
                    _buildEditableTextField('Phone Number', phoneNumberController),
                    _buildEditableTextField('Coding Scheme', codingSchemeController),
                    _buildEditableTextField('Tag', tagController),
                    ElevatedButton(
                      onPressed: _updateDriverData,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, Future<void> Function() _pickImage) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset('images/default_avatar.png'),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  )
                : Image.asset(
                    'images/default_avatar.png',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _pickImage,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
