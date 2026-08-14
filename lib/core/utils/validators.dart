import '../constants/app_strings.dart';

/// Pure validation functions shared across auth BLoCs and forms.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (value!.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? confirmPassword(String? password, String? confirm) {
    final requiredError = required(confirm);
    if (requiredError != null) return requiredError;
    if (password != confirm) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
