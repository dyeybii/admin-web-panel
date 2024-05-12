class FormValidation {
  static String? validateForm(String text, {
    required String firstName,
    required String lastName,
    required String idNumber,
    required String bodyNumber,
    required String email,
    required String birthdate,
    required String address,
    required String emergencyContact,
    required String codingScheme,
    required String tag,
  }) {
    if (_isEmptyField(firstName) ||
        _isEmptyField(lastName) ||
        _isEmptyField(idNumber) ||
        _isEmptyField(bodyNumber) ||
        _isEmptyField(email) ||
        !_validateEmail(email) ||
        _isEmptyField(birthdate) ||
        _isEmptyField(address) ||
        _isEmptyField(emergencyContact) ||
        _isEmptyField(codingScheme) ||
        _isEmptyField(tag)) {
      return 'Please fill in all fields and provide a valid email address.';
    }
    return null;
  }

  static bool _isEmptyField(String value) {
    return value.isEmpty;
  }

  static bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

