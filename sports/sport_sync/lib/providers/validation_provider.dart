import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class ValidationProvider with ChangeNotifier {
  // Regular expressions for validation
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s-]{10,}$',
  );
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-Z\s]{2,}$',
  );
  static final RegExp _numberRegex = RegExp(
    r'^\d*\.?\d+$',
  );

  // Form validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain letters, numbers, and special characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!_nameRegex.hasMatch(value)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateNumber(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'This field is required' : null;
    }
    if (!_numberRegex.hasMatch(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 0 || age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateUrl(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.isAbsolute) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  String? validateDate(String? value, {
    DateTime? minDate,
    DateTime? maxDate,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Date is required' : null;
    }
    try {
      final date = DateTime.parse(value);
      if (minDate != null && date.isBefore(minDate)) {
        return 'Date must be after ${minDate.toString().split(' ')[0]}';
      }
      if (maxDate != null && date.isAfter(maxDate)) {
        return 'Date must be before ${maxDate.toString().split(' ')[0]}';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  String? validateAmount(String? value, {
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Amount is required' : null;
    }
    try {
      final amount = double.parse(value);
      if (min != null && amount < min) {
        return 'Amount must be at least $min';
      }
      if (max != null && amount > max) {
        return 'Amount must be at most $max';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid amount';
    }
  }

  // Form field validation
  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  // Custom validation rules
  String? validateCustom(String? value, List<ValidationRule> rules) {
    if (value == null || value.isEmpty) {
      return rules.contains(ValidationRule.required)
          ? 'This field is required'
          : null;
    }

    for (var rule in rules) {
      switch (rule) {
        case ValidationRule.email:
          if (!EmailValidator.validate(value)) {
            return 'Please enter a valid email address';
          }
          break;
        case ValidationRule.password:
          if (!_passwordRegex.hasMatch(value)) {
            return 'Password must contain letters, numbers, and special characters';
          }
          break;
        case ValidationRule.phone:
          if (!_phoneRegex.hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
          break;
        case ValidationRule.name:
          if (!_nameRegex.hasMatch(value)) {
            return 'Please enter a valid name';
          }
          break;
        case ValidationRule.number:
          if (!_numberRegex.hasMatch(value)) {
            return 'Please enter a valid number';
          }
          break;
        default:
          break;
      }
    }
    return null;
  }

  // Helper methods
  bool isValidEmail(String email) => EmailValidator.validate(email);
  bool isValidPassword(String password) => _passwordRegex.hasMatch(password);
  bool isValidPhone(String phone) => _phoneRegex.hasMatch(phone);
  bool isValidName(String name) => _nameRegex.hasMatch(name);
  bool isValidNumber(String number) => _numberRegex.hasMatch(number);
}

enum ValidationRule {
  required,
  email,
  password,
  phone,
  name,
  number,
  url,
  date,
  amount,
}

// Extension for easy access in widgets
extension ValidationProviderExtension on BuildContext {
  ValidationProvider get validationProvider =>
      Provider.of<ValidationProvider>(this, listen: false);
}

// Mixin for form validation in widgets
mixin FormValidationHandler<T extends StatefulWidget> on State<T> {
  final _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  bool validateForm() {
    return context.validationProvider.validateForm(_formKey);
  }

  String? validateField(String? value, List<ValidationRule> rules) {
    return context.validationProvider.validateCustom(value, rules);
  }
}

// Custom form field validators
class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? minLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < minLength) {
      return 'Must be at least $minLength characters long';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return 'Must be at most $maxLength characters long';
    }
    return null;
  }

  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}