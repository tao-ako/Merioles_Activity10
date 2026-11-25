String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required.';
  }
  return null;
}

String? validateEmail(String? value) {
  final requiredError = validateRequired(value);
  if (requiredError != null) {
    return requiredError;
  }
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validateRegistrationPassword(String? value) {
  final requiredError = validateRequired(value);
  if (requiredError != null) {
    return requiredError;
  }
  if (value!.length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}
