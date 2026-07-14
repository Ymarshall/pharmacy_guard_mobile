class Validators {
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (French format)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Validate postal code (French format)
  static bool isValidPostalCode(String postalCode) {
    final postalCodeRegex = RegExp(r'^\d{5}$');
    return postalCodeRegex.hasMatch(postalCode);
  }

  /// Validate that string is not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  /// Validate that value is a positive number
  static bool isPositiveNumber(double value) {
    return value > 0;
  }

  /// Validate latitude (-90 to 90)
  static bool isValidLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  /// Validate longitude (-180 to 180)
  static bool isValidLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }
}

