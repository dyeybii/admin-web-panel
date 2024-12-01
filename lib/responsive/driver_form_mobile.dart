import 'package:flutter/material.dart';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/form_validation.dart';

class DriversFormMobile extends StatefulWidget {
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

  const DriversFormMobile({
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
  _DriversFormMobileState createState() => _DriversFormMobileState();
}

class _DriversFormMobileState extends State<DriversFormMobile> {
  String? _selectedTag;
  String? _selectedCodingScheme;

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
            "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
        widget.birthdateController.text = formattedDate;
      });
    }
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

  Widget buildDropdown<T>({
    required String labelText,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $labelText' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3192),
        title: const Text('Drivers Form - Mobile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: isWideScreen ? 500 : double.infinity,
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTextField(widget.firstNameController, 'First Name'),
                  const SizedBox(height: 10.0),
                  buildTextField(widget.lastNameController, 'Last Name'),
                  const SizedBox(height: 10.0),
                  buildTextField(widget.idNumberController, 'ID Number',
                      maxLength: 4),
                  const SizedBox(height: 10.0),
                  buildTextField(widget.bodyNumberController, 'Body Number',
                      maxLength: 4),
                  const SizedBox(height: 10.0),
                  GestureDetector(
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
                  ),
                  const SizedBox(height: 10.0),
                  buildTextField(widget.addressController, 'Address'),
                  const SizedBox(height: 10.0),
                  buildTextField(widget.phoneNumberController, 'Mobile Number',
                      maxLength: 11),
                  const SizedBox(height: 10.0),
                  buildTextField(widget.emailController, 'Email'),
                  const SizedBox(height: 10.0),
                  buildDropdown<String>(
                    labelText: 'Coding Scheme',
                    value: _selectedCodingScheme,
                    items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
                    onChanged: (value) {
                      setState(() {
                        _selectedCodingScheme = value;
                        widget.codingSchemeController.text = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10.0),
                  buildDropdown<String>(
                    labelText: 'Tag',
                    value: _selectedTag,
                    items: ['Member', 'Operator'],
                    onChanged: (value) {
                      setState(() {
                        _selectedTag = value;
                        widget.onTagSelected!(value);
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color(0xFF2E3192),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: widget.onAddPressed,
                    child: const Text('Add Toda Driver'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
