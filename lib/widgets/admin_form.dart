import 'package:flutter/material.dart';

class AdminForm extends StatefulWidget {
  final void Function(Map<String, String>) onSubmit;

  const AdminForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _bodyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue,
      title: const Text(
        'Add New Member',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                // Add other form fields similarly
              ],
            ),
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // If the form is valid, extract the form data
                final formData = {
                  'firstName': _firstNameController.text,
                  'lastName': _lastNameController.text,
                  'idNumber': _idNumberController.text,
                  'bodyNumber': _bodyNumberController.text,
                  'email': _emailController.text,
                  'birthdate': _birthdateController.text,
                  'address': _addressController.text,
                  'emergencyContact': _emergencyContactController.text,
                };
                // Call the onSubmit callback with the form data
                widget.onSubmit(formData);
                // Clear the form fields
                _firstNameController.clear();
                _lastNameController.clear();
                _idNumberController.clear();
                _bodyNumberController.clear();
                _emailController.clear();
                _birthdateController.clear();
                _addressController.clear();
                _emergencyContactController.clear();
                // Close the dialog
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Add',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Clear form fields and dismiss the dialog
            _firstNameController.clear();
            _lastNameController.clear();
            _idNumberController.clear();
            _bodyNumberController.clear();
            _emailController.clear();
            _birthdateController.clear();
            _addressController.clear();
            _emergencyContactController.clear();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
