import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:intl/intl.dart';

class LocalizationProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  // State
  Locale _currentLocale;
  Map<String, Map<String, String>> _translations = {};
  String? _error;

  // Constants
  static const String _localeKey = 'selected_locale';
  static const String _fallbackLocale = 'en';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('hi', 'IN'), // Hindi
  ];

  LocalizationProvider(this._prefs)
      : _currentLocale = Locale(_prefs.getString(_localeKey) ?? _fallbackLocale) {
    _loadTranslations();
  }

  // Getters
  Locale get currentLocale => _currentLocale;
  String? get error => _error;
  bool get isRTL => _currentLocale.languageCode == 'ar' || 
                    _currentLocale.languageCode == 'he';

  // Load translations
  Future<void> _loadTranslations() async {
    try {
      // Initialize translations map
      _translations = {
        'en': {
          // Common
          'app_name': 'SportSync',
          'ok': 'OK',
          'cancel': 'Cancel',
          'save': 'Save',
          'delete': 'Delete',
          'edit': 'Edit',
          'loading': 'Loading...',
          'error': 'Error',
          'success': 'Success',
          'warning': 'Warning',
          'confirm': 'Confirm',

          // Navigation
          'dashboard': 'Dashboard',
          'performance': 'Performance',
          'injuries': 'Injuries',
          'career': 'Career',
          'financial': 'Financial',
          'settings': 'Settings',

          // Auth
          'login': 'Login',
          'register': 'Register',
          'logout': 'Logout',
          'email': 'Email',
          'password': 'Password',
          'forgot_password': 'Forgot Password?',
          'confirm_password': 'Confirm Password',

          // Profile
          'profile': 'Profile',
          'name': 'Name',
          'age': 'Age',
          'gender': 'Gender',
          'sport': 'Sport',
          'update_profile': 'Update Profile',

          // Performance
          'track_performance': 'Track Performance',
          'view_stats': 'View Statistics',
          'add_record': 'Add Record',
          'personal_best': 'Personal Best',
          'recent_activity': 'Recent Activity',

          // Injuries
          'injury_log': 'Injury Log',
          'add_injury': 'Add Injury',
          'recovery_progress': 'Recovery Progress',
          'injury_type': 'Injury Type',
          'injury_date': 'Injury Date',

          // Career
          'achievements': 'Achievements',
          'goals': 'Goals',
          'add_achievement': 'Add Achievement',
          'set_goal': 'Set Goal',
          'career_progress': 'Career Progress',

          // Financial
          'transactions': 'Transactions',
          'income': 'Income',
          'expenses': 'Expenses',
          'balance': 'Balance',
          'add_transaction': 'Add Transaction',

          // Settings
          'app_settings': 'App Settings',
          'notifications': 'Notifications',
          'language': 'Language',
          'theme': 'Theme',
          'privacy': 'Privacy',
          'help': 'Help',

          // Error messages
          'network_error': 'Network error occurred',
          'unknown_error': 'An unknown error occurred',
          'required_field': 'This field is required',
          'invalid_email': 'Invalid email address',
          'invalid_password': 'Invalid password',
          'passwords_dont_match': 'Passwords do not match',
        },
        'es': {
          // Spanish translations
          'app_name': 'SportSync',
          'ok': 'Aceptar',
          'cancel': 'Cancelar',
          // Add more Spanish translations...
        },
        'fr': {
          // French translations
          'app_name': 'SportSync',
          'ok': 'OK',
          'cancel': 'Annuler',
          // Add more French translations...
        },
        // Add more languages...
      };
    } catch (e) {
      _setError('Failed to load translations: $e');
    }
  }

  // Change locale
  Future<void> setLocale(String languageCode) async {
    try {
      final newLocale = Locale(languageCode);
      if (supportedLocales.contains(newLocale)) {
        _currentLocale = newLocale;
        await _prefs.setString(_localeKey, languageCode);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to set locale: $e');
    }
  }

  // Get translation
  String translate(String key) {
    try {
      final translations = _translations[_currentLocale.languageCode];
      if (translations != null && translations.containsKey(key)) {
        return translations[key]!;
      }
      // Fallback to English
      return _translations[_fallbackLocale]?[key] ?? key;
    } catch (e) {
      _setError('Failed to translate key: $key');
      return key;
    }
  }

  // Format date
  String formatDate(DateTime date, {String? format}) {
    try {
      final formatter = DateFormat(
        format ?? 'yyyy-MM-dd',
        _currentLocale.languageCode,
      );
      return formatter.format(date);
    } catch (e) {
      _setError('Failed to format date: $e');
      return date.toString();
    }
  }

  // Format time
  String formatTime(DateTime time, {String? format}) {
    try {
      final formatter = DateFormat(
        format ?? 'HH:mm',
        _currentLocale.languageCode,
      );
      return formatter.format(time);
    } catch (e) {
      _setError('Failed to format time: $e');
      return time.toString();
    }
  }

  // Format number
  String formatNumber(num number, {int? decimalPlaces}) {
    try {
      final formatter = NumberFormat.decimalPattern(_currentLocale.languageCode);
      if (decimalPlaces != null) {
        formatter.minimumFractionDigits = decimalPlaces;
        formatter.maximumFractionDigits = decimalPlaces;
      }
      return formatter.format(number);
    } catch (e) {
      _setError('Failed to format number: $e');
      return number.toString();
    }
  }

  // Format currency
  String formatCurrency(num amount, {String? currencyCode}) {
    try {
      final formatter = NumberFormat.currency(
        locale: _currentLocale.languageCode,
        symbol: currencyCode ?? 'USD',
      );
      return formatter.format(amount);
    } catch (e) {
      _setError('Failed to format currency: $e');
      return amount.toString();
    }
  }

  // Get locale name
  String getLocaleName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'hi':
        return 'हिंदी';
      default:
        return languageCode;
    }
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Extension for easy access in widgets
extension LocalizationProviderExtension on BuildContext {
  LocalizationProvider get localizationProvider =>
      Provider.of<LocalizationProvider>(this, listen: false);
  
  String tr(String key) => localizationProvider.translate(key);
}

// Mixin for localization in widgets
mixin LocalizationHandler<T extends StatefulWidget> on State<T> {
  String tr(String key) => context.tr(key);
  
  String formatDate(DateTime date, {String? format}) =>
      context.localizationProvider.formatDate(date, format: format);
  
  String formatTime(DateTime time, {String? format}) =>
      context.localizationProvider.formatTime(time, format: format);
  
  String formatNumber(num number, {int? decimalPlaces}) =>
      context.localizationProvider.formatNumber(
        number,
        decimalPlaces: decimalPlaces,
      );
  
  String formatCurrency(num amount, {String? currencyCode}) =>
      context.localizationProvider.formatCurrency(
        amount,
        currencyCode: currencyCode,
      );
}