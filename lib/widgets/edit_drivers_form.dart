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

    _fetchDriverByUID();
  }

  Future<String?> _fetchDriverByUID() async {
    final driverRef = FirebaseDatabase.instance.ref('driversAccount');
    final query = driverRef.orderByChild('uid').equalTo(widget.driverId);

    try {
      DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        Map data = snapshot.value as Map;
        String? driverKey;

        data.forEach((key, value) {
          driverKey = key;
          print('Driver Key: $key');
          print('Driver Data: $value');
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

  Future<void> _updateDriver(String driverKey) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final driverRef =
            FirebaseDatabase.instance.ref('driversAccount/$driverKey');

        Map<String, dynamic> updates = {};

        if (_firstNameController.text != widget.firstName) {
          updates['firstName'] = _firstNameController.text;
        }
        if (_lastNameController.text != widget.lastName) {
          updates['lastName'] = _lastNameController.text;
        }
        if (_idNumberController.text != widget.idNumber) {
          updates['idNumber'] = _idNumberController.text;
        }
        if (_bodyNumberController.text != widget.bodyNumber) {
          updates['bodyNumber'] = _bodyNumberController.text;
        }
        if (_emailController.text != widget.email) {
          updates['email'] = _emailController.text;
        }
        if (_birthdateController.text != widget.birthdate) {
          updates['birthdate'] = _birthdateController.text;
        }
        if (_addressController.text != widget.address) {
          updates['address'] = _addressController.text;
        }
        if (_phoneNumberController.text != widget.phoneNumber) {
          updates['phoneNumber'] = _phoneNumberController.text;
        }
        if (_selectedTag != widget.tag) {
          updates['tag'] = _selectedTag;
        }
        if (_driverPhotoUrl != widget.driverPhoto) {
          updates['driverPhoto'] = _driverPhotoUrl;
        }

        if (updates.isNotEmpty) {
          await driverRef.update(updates);
          print('Driver information updated successfully.');
        } else {
          print('No changes to update.');
        }

        setState(() {
          _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Driver'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(labelText: 'ID Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ID number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bodyNumberController,
                decoration: InputDecoration(labelText: 'Body Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a body number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthdateController,
                decoration: InputDecoration(labelText: 'Birthdate'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a birthdate';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 11) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTag.isNotEmpty ? _selectedTag : null,
                decoration: InputDecoration(labelText: 'Tag'),
                items: ['Member', 'Operator']
                    .map((tag) => DropdownMenuItem(
                          value: tag,
                          child: Text(tag),
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
              SizedBox(height: 20),
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
                    ? CircularProgressIndicator()
                    : Text('Update Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
