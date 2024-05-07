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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: widget.firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            controller: widget.lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            maxLength: 4,
            controller: widget.idNumberController,
            decoration: const InputDecoration(
              labelText: 'ID Number',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            maxLength: 4,
            controller: widget.bodyNumberController,
            decoration: const InputDecoration(
              labelText: 'Body Number',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            controller: widget.birthdateController,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            maxLength: 3,
            controller: widget.codingSchemeController,
            decoration: const InputDecoration(
              labelText: 'Coding Scheme',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            controller: widget.addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            maxLength: 11,
            controller: widget.emergencyContactController,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact #',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Role',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          RadioListTile<String?>(
            title: const Text('Member', style: TextStyle(color: Colors.black)),
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
            title:
                const Text('Operator', style: TextStyle(color: Colors.black)),
            value: 'operator',
            groupValue: _selectedRole,
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
                widget.onRoleSelected?.call(value);
              });
            },
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () async {
                  if (widget.formKey.currentState!.validate()) {
                    try {
                      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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
    );
  }
}