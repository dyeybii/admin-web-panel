import 'package:admin_web_panel/responsive/edit_form_desktop.dart';
import 'package:admin_web_panel/responsive/edit_form_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;


class EditDriverForm extends StatelessWidget {
  final String driverId;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String bodyNumber;
  final String email;
  final String birthdate;
  final String address;
  final String phoneNumber;
  final String codingScheme;
  final String tag;
  final String driverPhoto;

  EditDriverForm({
    required this.driverId,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.bodyNumber,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.phoneNumber,
    required this.codingScheme,
    required this.tag,
    required this.driverPhoto,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the platform is mobile or desktop and render accordingly
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      return EditDriverFormMobile(
        driverId: driverId,
        firstName: firstName,
        lastName: lastName,
        idNumber: idNumber,
        bodyNumber: bodyNumber,
        email: email,
        birthdate: birthdate,
        address: address,
        phoneNumber: phoneNumber,
        codingScheme: codingScheme,
        tag: tag,
        driverPhoto: driverPhoto,
      );
    } else {
      return EditDriverFormDesktop(
        driverId: driverId,
        firstName: firstName,
        lastName: lastName,
        idNumber: idNumber,
        bodyNumber: bodyNumber,
        email: email,
        birthdate: birthdate,
        address: address,
        phoneNumber: phoneNumber,
        codingScheme: codingScheme,
        tag: tag,
        driverPhoto: driverPhoto,
      );
    }
  }
}
