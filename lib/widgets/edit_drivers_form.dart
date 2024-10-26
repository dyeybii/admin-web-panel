import 'package:flutter/material.dart';
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
  final String tag;
  final String driverPhoto;
  final String codingScheme; 
  final String status; 

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
    required this.codingScheme, 
    required this.status, 
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
  late TextEditingController _codingSchemeController; 
  late String _selectedTag;
  late String _driverPhotoUrl;
  String _status = '';
  bool _isLoading = false;
  bool _isEditing = false; 
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
    _selectedTag = widget.tag;
    _driverPhotoUrl = widget.driverPhoto;
    _status = widget.status; 

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
          'birthday': _birthdateController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'tag': _selectedTag,
          'driverPhoto': _driverPhotoUrl,
          'codingScheme': _codingSchemeController.text, 
          'status': _status, 
        });

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver updated successfully!')),
        );
        Navigator.pop(context); 
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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Driver Photo with Status Indicator
              Stack(
                alignment: Alignment.topRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _driverPhotoUrl.isNotEmpty
                        ? NetworkImage(_driverPhotoUrl)
                        : const AssetImage('images/default_avatar.png')
                            as ImageProvider,
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _status == 'online'
                          ? Colors.green
                          : _status == 'Offline'
                              ? Colors.grey
                              : Colors.red,
                    ),
                  ),
                ],
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                            labelText: 'Birthday',
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a birthdate';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codingSchemeController, 
                          decoration: const InputDecoration(
                            labelText: 'Coding Scheme',
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a coding scheme';
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                          ),
                          style: const TextStyle(color: Colors.black),
                          enabled: _isEditing,
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
                ),
                dropdownColor: Colors.white,
                items: ['Member', 'Operator']
                    .map((tag) => DropdownMenuItem(
                          value: tag,
                          child: Text(tag,
                              style: const TextStyle(color: Colors.black)),
                        ))
                    .toList(),
                onChanged: _isEditing
                    ? (newValue) {
                        setState(() {
                          _selectedTag = newValue!;
                        });
                      }
                    : null,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _toggleEdit,
                    child: Text(_isEditing ? 'Cancel Edit' : 'Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
