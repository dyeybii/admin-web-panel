import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _formKey = GlobalKey<FormState>();
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

    if (_driverPhotoUrl.isEmpty) {
      _driverPhotoUrl = 'images/default_avatar.png';
    }

    _fetchDriverByUID();
  }

  Future<String?> _fetchDriverByUID() async {
    final driverRef = FirebaseDatabase.instance.ref('driversAccount');
    final query = driverRef.orderByChild('uid').equalTo(widget.driverId);

    try {
      DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        String? driverKey;
        // Fetch the correct driver key
        Map data = snapshot.value as Map;
        data.forEach((key, value) {
          if (value['uid'] == widget.driverId) {
            driverKey = key;
          }
        });
        return driverKey;
      } else {
        print('No driver found with UID: ${widget.driverId}');
        return null;
      }
    } catch (e) {
      print('Error fetching driver data: $e');
      return null;
    }
  }

  // Method to update the driver details
  Future<void> _updateDriver(String driverKey) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final driverRef =
            FirebaseDatabase.instance.ref('driversAccount/$driverKey');

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
          'driverPhoto': _driverPhotoUrl, // Update photo if it exists
        });

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver updated successfully!')),
        );
        Navigator.pop(context); // Close dialog after update
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error updating driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating driver: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Driver Photo
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _driverPhotoUrl.isNotEmpty
                      ? NetworkImage(_driverPhotoUrl)
                      : const AssetImage('images/default_avatar.png')
                          as ImageProvider,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a first name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _idNumberController,
                          decoration: const InputDecoration(
                            labelText: 'ID Number',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an ID number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _birthdateController,
                          decoration: const InputDecoration(
                            labelText: 'Birthdate',
                            labelStyle: const TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a birthdate';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a last name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _bodyNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Body Number',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a body number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an address';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                                color: Colors
                                    .black), // Change label color to black
                          ),
                          style: const TextStyle(
                              color: Colors
                                  .black), // Change input text color to black
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length != 11) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedTag.isNotEmpty ? _selectedTag : null,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 0, 0, 0)), // Change label color to black
                ),
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                items: ['Member', 'Operator']
                    .map((tag) => DropdownMenuItem(
                          value: tag,
                          child: Text(tag,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0,
                                      0))), // Change text color to black
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTag = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a tag';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        String? driverKey = await _fetchDriverByUID();

                        if (driverKey != null) {
                          await _updateDriver(driverKey);
                        } else {
                          print('Driver not found, cannot update');
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Driver'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
