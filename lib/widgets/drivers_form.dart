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
  final TextEditingController emergencyContactController;
  final TextEditingController codingSchemeController;
  final TextEditingController tagController;
  final void Function(String?)? onRoleSelected;
  final Function()? onAddPressed;

  const DriversForm({
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
    required this.onRoleSelected,
    required this.onAddPressed,
  });

  @override
  _DriversFormState createState() => _DriversFormState();
}

class _DriversFormState extends State<DriversForm> {
  String? _selectedRole;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void resetFormFields() {
    widget.firstNameController.clear();
    widget.lastNameController.clear();
    widget.idNumberController.clear();
    widget.bodyNumberController.clear();
    widget.emailController.clear();
    widget.birthdateController.clear();
    widget.addressController.clear();
    widget.emergencyContactController.clear();
    widget.codingSchemeController.clear();
    widget.tagController.clear();
    setState(() {
      _selectedRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.all(200.0),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundImage:AssetImage('images/default_avatar.png') ,
                  )
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Implement image upload functionality
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload Profile'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: widget.firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: widget.lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                maxLength: 4,
                maxLines: null, // Allow multiple lines
                controller: widget.idNumberController,
                decoration: const InputDecoration(
                  labelText: 'ID Number',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                maxLength: 4,
                maxLines: null, // Allow multiple lines
                controller: widget.bodyNumberController,
                decoration: const InputDecoration(
                  labelText: 'Body Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: widget.birthdateController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                maxLength: 3,
                maxLines: null, // Allow multiple lines
                controller: widget.codingSchemeController,
                decoration: const InputDecoration(
                  labelText: 'Coding Scheme',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                maxLines: null, // Allow multiple lines
                controller: widget.addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                maxLength: 11,
                maxLines: null, // Allow multiple lines
                controller: widget.emergencyContactController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact #',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: widget.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Role',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile<String?>(
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
              RadioListTile<String?>(
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
              const SizedBox(height: 20.0),
              Row(
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

                          if (widget.onAddPressed != null) {
                            widget.onAddPressed!();
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                          }
                        } catch (e) {
                          print('Error: $e');
                        }
                      }
                    },
                    child: const Text('Add Driver & Create Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
