class FormValidation {
  static String? validateForm(
    String firstName,
    String lastName,
    String idNumber,
    String bodyNumber,
    String email,
    String birthdate,
    String address,
    String emergencyContact,
    String codingScheme,
    String tag,
  ) {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        idNumber.isEmpty ||
        bodyNumber.isEmpty ||
        email.isEmpty ||
        !validateEmail(email) || 
        birthdate.isEmpty ||
        address.isEmpty ||
        emergencyContact.isEmpty ||
        codingScheme.isEmpty ||
        tag.isEmpty) {
      return 'Please fill in all fields and provide a valid email address.';
    }
    return null;
  }

  static bool validateEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
