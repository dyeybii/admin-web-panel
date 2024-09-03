import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';


class AdminForms {
  static Future<void> showDriverDetailsDialog(
    DriversAccount driver,
    BuildContext context,
    DatabaseReference databaseReference,
    Function setState,
  ) async {
    TextEditingController firstNameController =
        TextEditingController(text: driver.firstName);
    TextEditingController lastNameController =
        TextEditingController(text: driver.lastName);
    TextEditingController idNumberController =
        TextEditingController(text: driver.idNumber);
    TextEditingController bodyNumberController =
        TextEditingController(text: driver.bodyNumber);
    TextEditingController emailController =
        TextEditingController(text: driver.email);
    TextEditingController birthdateController =
        TextEditingController(text: driver.birthdate);
    TextEditingController addressController =
        TextEditingController(text: driver.address);
    TextEditingController phoneNumberController =
        TextEditingController(text: driver.phoneNumber);
    TextEditingController codingSchemeController =
        TextEditingController(text: driver.codingScheme);
    TextEditingController tagController =
        TextEditingController(text: driver.tag);
    TextEditingController driver_photosController =
        TextEditingController(text: driver.driver_photos);

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          driver_photosController.text = pickedFile.path;
        });
      }
    }

    void _updateDriverData() async {
      try {
        await databaseReference.child(driver.driverId).update({
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
          'driver_photos': driver_photosController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $e')),
        );
      }
    }

    void _deleteDriverData() async {
      try {
        await databaseReference.child(driver.driverId).remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Personal Information'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: driver.driver_photos.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: driver.driver_photos,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Image.asset('images/default_avatar.png'),
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
                ),
                const SizedBox(height: 20),
                Form(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'First Name', firstNameController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Last Name', lastNameController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'ID Number', idNumberController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Body Number', bodyNumberController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'Email', emailController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Date of Birth', birthdateController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'Address', addressController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Tag', tagController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'Phone Number', phoneNumberController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Coding Scheme', codingSchemeController),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _deleteDriverData,
              child: const Text('Delete Account'),
            ),
            ElevatedButton(
              onPressed: _updateDriverData,
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildEditableTextField(
      String label, TextEditingController controller) {
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
