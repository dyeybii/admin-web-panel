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
    final controllers = [
      widget.firstNameController,
      widget.lastNameController,
      widget.idNumberController,
      widget.bodyNumberController,
      widget.emailController,
      widget.birthdateController,
      widget.addressController,
      widget.emergencyContactController,
      widget.codingSchemeController,
      widget.tagController,
    ];

    for (var controller in controllers) {
      controller.clear();
    }

    setState(() {
      _selectedRole = null;
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
        widget.birthdateController.text =
            picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button
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
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildProfilePicture(),
              const SizedBox(height: 30.0),
              buildUploadButton(),
              const SizedBox(height: 20.0),
              buildFormFields(),
              const SizedBox(height: 20.0),
              buildFormButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('images/default_avatar.png'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                // Add your onPressed logic here
              },
              icon: const Icon(Icons.add_a_photo),
            ),
          ),
        ],
      ),
    );
  }

Widget buildUploadButton() {
  return ElevatedButton.icon(
    onPressed: () {
      // Implement image upload functionality
    },
    icon: const Icon(Icons.upload),
    label: const Text('Upload Profile'),
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
            buildTextField(widget.emergencyContactController, 'Emergency Contact #', maxLength: 11),
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

                if (widget.onAddPressed != null) {
                  widget.onAddPressed!();
                }
              } on FirebaseAuthException catch (e) {
                _showAlertDialog(e.message ?? 'An error occurred');
              } catch (e) {
                print('Error: $e');
              }
            }
          },
          child: const Text('Add Driver & Create Account'),
        ),
      ],
    );
  }
}
