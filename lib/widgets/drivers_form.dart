import 'package:admin_web_panel/responsive/driver_form_desktop.dart';
import 'package:admin_web_panel/responsive/driver_form_mobile.dart';
import 'package:flutter/material.dart';


class DriversFormPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController bodyNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController driverPhotoController = TextEditingController();
  final TextEditingController uidController = TextEditingController();
  final TextEditingController codingSchemeController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Form'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
           
            return DriversFormMobile(
              formKey: formKey,
              firstNameController: firstNameController,
              lastNameController: lastNameController,
              idNumberController: idNumberController,
              bodyNumberController: bodyNumberController,
              emailController: emailController,
              birthdateController: birthdateController,
              addressController: addressController,
              phoneNumberController: phoneNumberController,
              tagController: tagController,
              driverPhotoController: driverPhotoController,
              uidController: uidController,
              codingSchemeController: codingSchemeController,
              statusController: statusController,
              onTagSelected: (tag) {
                print('Selected Tag: $tag');
              },
              onAddPressed: () {
                if (formKey.currentState!.validate()) {
                  print('Form Validated! Add logic here.');
                }
              },
            );
          } else {
            // Use the desktop version for larger screens
            return DriversFormDesktop(
              formKey: formKey,
              firstNameController: firstNameController,
              lastNameController: lastNameController,
              idNumberController: idNumberController,
              bodyNumberController: bodyNumberController,
              emailController: emailController,
              birthdateController: birthdateController,
              addressController: addressController,
              phoneNumberController: phoneNumberController,
              tagController: tagController,
              driverPhotoController: driverPhotoController,
              uidController: uidController,
              codingSchemeController: codingSchemeController,
              statusController: statusController,
              onTagSelected: (tag) {
                print('Selected Tag: $tag');
              },
              onAddPressed: () {
                if (formKey.currentState!.validate()) {
                  print('Form Validated! Add logic here.');
                }
              },
            );
          }
        },
      ),
    );
  }
}
