import 'package:flutter/material.dart';

class AppColors {
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color accent = Color(0xFF00BCD4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
}

class ApiEndpoints {
  static const String baseUrl = 'https://api.sportsync.com';
  static const String wearableApi = '$baseUrl/wearable';
  static const String vertexAi = '$baseUrl/ai/vertex';
  static const String gemini = '$baseUrl/ai/gemini';
}

class AppConstants {
  static const String appName = 'SportSync';
  static const String appVersion = '1.0.0';
  
  // Validation Constants
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int phoneLength = 10;
  
  // Storage Keys
  static const String userPrefsKey = 'user_prefs';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // Error Messages
  static const String networkError = 'Network connection error. Please try again.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String generalError = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String loginSuccess = 'Successfully logged in!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String dataUpdateSuccess = 'Data updated successfully!';
}

class ValidationMessages {
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword = 'Password must be at least 8 characters long';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidName = 'Name must be at least 2 characters long';
}