import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/batch_upload.dart';
import 'package:admin_web_panel/widgets/form_validation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      _selectedCodingScheme = null;
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
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: CustomButtonStyles.elevatedButtonStyle,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              titlePadding: EdgeInsets.zero,
                              title: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E3192),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Batch Upload',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              content: SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: BatchUpload(
                                  onUpload: (List<Map<String, dynamic>>
                                      uploadedData) {
                                    print('Uploaded Data: $uploadedData');
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Batch Upload'),
                    ),
                    const SizedBox(height: 30.0),
                    buildFormFields(),
                    const SizedBox(height: 40.0),
                    buildFormButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.toString().isEmpty) {
          return 'Please select a value';
        }
        return null;
      },
    );
  }

  Widget buildFormFields() {
    return Column(
      children: [
        buildTextField(widget.firstNameController, 'First Name'),
        const SizedBox(height: 10.0),
        buildTextField(widget.lastNameController, 'Last Name'),
        const SizedBox(height: 10.0),
        buildTextField(widget.idNumberController, 'ID Number', maxLength: 4),
        const SizedBox(height: 10.0),
        buildTextField(widget.bodyNumberController, 'Body Number',
            maxLength: 4),
        const SizedBox(height: 10.0),
        buildBirthdateField(),
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
        buildTagSelection(),
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
        const SizedBox(height: 20.0),
        DropdownButtonFormField<String>(
          value: _selectedTag,
          decoration: const InputDecoration(
            labelText: 'Select Tag',
            border: OutlineInputBorder(),
          ),
          items: ['Member', 'Operator']
              .map((tag) => DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedTag = value;
            });
            widget.onTagSelected!(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a tag';
            }
            return null;
          },
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
