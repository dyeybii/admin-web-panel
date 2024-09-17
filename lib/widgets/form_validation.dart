class FormValidation {
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (int.tryParse(value) == null) {
      return 'Must be a number';
    }
    return null;
  }

  static String? validateTag(String? value) {
    if (value == null) {
      return 'Please select a role';
    }
    return null;
  }
}