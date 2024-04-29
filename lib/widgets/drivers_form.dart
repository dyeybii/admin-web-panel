import 'package:flutter/material.dart';

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
  final Function(String)? onRoleSelected;
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
  String? _selectedRole = '';

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
          RadioListTile<String>(
            title: const Text('Member', style: TextStyle(color: Colors.black)),
            value: 'member',
            groupValue: _selectedRole,
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
                widget.onRoleSelected?.call(value!);
              });
            },
          ),
          RadioListTile<String>(
            title:
                const Text('Operator', style: TextStyle(color: Colors.black)),
            value: 'operator',
            groupValue: _selectedRole,
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
                widget.onRoleSelected?.call(value!);
              });
            },
          ),
        ],
      ),
    );
  }
}
