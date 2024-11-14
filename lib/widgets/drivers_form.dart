import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'form_validation.dart';

class DriversForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController idNumberController;
  final TextEditingController bodyNumberController;
  final TextEditingController emailController;
  final TextEditingController birthdateController;
  final TextEditingController addressController;
  final TextEditingController phoneNumberController;
  final TextEditingController tagController;
  final TextEditingController driverPhotoController;
  final TextEditingController uidController;
  final TextEditingController codingSchemeController;
  final TextEditingController statusController;
  final void Function(String?)? onTagSelected;
  final Function()? onAddPressed;
  final Function()? onEditPressed;

  const DriversForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.idNumberController,
    required this.bodyNumberController,
    required this.emailController,
    required this.birthdateController,
    required this.addressController,
    required this.phoneNumberController,
    required this.tagController,
    required this.driverPhotoController,
    required this.uidController,
    required this.codingSchemeController,
    required this.statusController,
    required this.onTagSelected,
    required this.onAddPressed,
    this.onEditPressed,
  });

  @override
  _DriversFormState createState() => _DriversFormState();
}

class _DriversFormState extends State<DriversForm> {
  String? _selectedTag;
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
      widget.phoneNumberController,
      widget.codingSchemeController,
      widget.tagController,
    ];
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      _selectedTag = null;
    });
  }

Future<void> _selectBirthdate() async {
  final DateTime currentDate = DateTime.now();
  final DateTime maxSelectableDate = DateTime(
    currentDate.year - 18,
    currentDate.month,
    currentDate.day,
  );

  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: maxSelectableDate,
    firstDate: DateTime(1950),
    lastDate: maxSelectableDate,
  );

  if (picked != null) {
    setState(() {
      String formattedDate =
          "${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}${picked.year}";
      widget.birthdateController.text = formattedDate;
    });
  }
}


  Future<void> _showAlertDialog(String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(message),
              ],
            ),
          ),
          actions: [
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Container(
        height: 600.0,
        width: 800.0,
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30.0),
              buildFormFields(),
              const SizedBox(height: 40.0),
              buildFormButtons(),
            ],
          ),
        ),
      ),
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
      validator: (value) {
        if (controller == widget.idNumberController ||
            controller == widget.bodyNumberController ||
            controller == widget.phoneNumberController) {
          return FormValidation.validateNumber(value);
        }
        return FormValidation.validateRequired(value);
      },
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
              buildTextField(widget.addressController, 'Address'),
              const SizedBox(height: 10.0),
              buildTextField(widget.phoneNumberController, 'Mobile Number', maxLength: 11),
              const SizedBox(height: 10.0),
              buildTextField(widget.emailController, 'Email'),
              const SizedBox(height: 10.0),
              buildTextField(widget.codingSchemeController, 'Coding Scheme', maxLength: 4),
              buildTagSelection(),
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
          validator: (value) {
            return FormValidation.validateRequired(value);
          },
        ),
      ),
    );
  }

  Widget buildTagSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tag',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                title: const Text('Member'),
                value: 'Member',
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value as String?;
                  });
                  widget.onTagSelected!(value as String?);
                },
              ),
            ),
            Expanded(
              child: RadioListTile(
                title: const Text('Operator'),
                value: 'Operator',
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value as String?;
                  });
                  widget.onTagSelected!(value as String?);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFormButtons() {
    return Center(
      
      child: ElevatedButton(
        style: CustomButtonStyles.elevatedButtonStyle,
        onPressed: widget.onAddPressed,
        child: const Text('Add Toda Driver'),
      ),
    );
  }


}
