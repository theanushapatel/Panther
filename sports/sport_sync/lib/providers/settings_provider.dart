import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricsKey = 'biometrics_enabled';
  static const String _syncIntervalKey = 'sync_interval';
  static const String _dataPrivacyKey = 'data_privacy_level';
  static const String _measurementUnitKey = 'measurement_unit';
  static const String _currencyKey = 'currency';
  static const String _timeFormatKey = 'time_format';
  static const String _dateFormatKey = 'date_format';

  final SharedPreferences _prefs;

  // Settings state
  String _languageCode;
  bool _notificationsEnabled;
  bool _biometricsEnabled;
  int _syncInterval; // in minutes
  String _dataPrivacyLevel;
  String _measurementUnit;
  String _currency;
  String _timeFormat;
  String _dateFormat;

  SettingsProvider(this._prefs)
      : _languageCode = _prefs.getString(_languageKey) ?? 'en',
        _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true,
        _biometricsEnabled = _prefs.getBool(_biometricsKey) ?? false,
        _syncInterval = _prefs.getInt(_syncIntervalKey) ?? 30,
        _dataPrivacyLevel = _prefs.getString(_dataPrivacyKey) ?? 'standard',
        _measurementUnit = _prefs.getString(_measurementUnitKey) ?? 'metric',
        _currency = _prefs.getString(_currencyKey) ?? 'USD',
        _timeFormat = _prefs.getString(_timeFormatKey) ?? '24h',
        _dateFormat = _prefs.getString(_dateFormatKey) ?? 'dd/MM/yyyy';

  // Getters
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  int get syncInterval => _syncInterval;
  String get dataPrivacyLevel => _dataPrivacyLevel;
  String get measurementUnit => _measurementUnit;
  String get currency => _currency;
  String get timeFormat => _timeFormat;
  String get dateFormat => _dateFormat;

  // Language settings
  Future<void> setLanguage(String languageCode) async {
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }

  // Notification settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      await _prefs.setBool(_notificationsKey, enabled);
      notifyListeners();
    }
  }

  // Biometric authentication settings
  Future<void> setBiometricsEnabled(bool enabled) async {
    if (_biometricsEnabled != enabled) {
      _biometricsEnabled = enabled;
      await _prefs.setBool(_biometricsKey, enabled);
      notifyListeners();
    }
  }

  // Sync interval settings
  Future<void> setSyncInterval(int minutes) async {
    if (_syncInterval != minutes) {
      _syncInterval = minutes;
      await _prefs.setInt(_syncIntervalKey, minutes);
      notifyListeners();
    }
  }

  // Data privacy level settings
  Future<void> setDataPrivacyLevel(String level) async {
    if (_dataPrivacyLevel != level) {
      _dataPrivacyLevel = level;
      await _prefs.setString(_dataPrivacyKey, level);
      notifyListeners();
    }
  }

  // Measurement unit settings
  Future<void> setMeasurementUnit(String unit) async {
    if (_measurementUnit != unit) {
      _measurementUnit = unit;
      await _prefs.setString(_measurementUnitKey, unit);
      notifyListeners();
    }
  }

  // Currency settings
  Future<void> setCurrency(String currency) async {
    if (_currency != currency) {
      _currency = currency;
      await _prefs.setString(_currencyKey, currency);
      notifyListeners();
    }
  }

  // Time format settings
  Future<void> setTimeFormat(String format) async {
    if (_timeFormat != format) {
      _timeFormat = format;
      await _prefs.setString(_timeFormatKey, format);
      notifyListeners();
    }
  }

  // Date format settings
  Future<void> setDateFormat(String format) async {
    if (_dateFormat != format) {
      _dateFormat = format;
      await _prefs.setString(_dateFormatKey, format);
      notifyListeners();
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await Future.wait([
      _prefs.setString(_languageKey, 'en'),
      _prefs.setBool(_notificationsKey, true),
      _prefs.setBool(_biometricsKey, false),
      _prefs.setInt(_syncIntervalKey, 30),
      _prefs.setString(_dataPrivacyKey, 'standard'),
      _prefs.setString(_measurementUnitKey, 'metric'),
      _prefs.setString(_currencyKey, 'USD'),
      _prefs.setString(_timeFormatKey, '24h'),
      _prefs.setString(_dateFormatKey, 'dd/MM/yyyy'),
    ]);

    _languageCode = 'en';
    _notificationsEnabled = true;
    _biometricsEnabled = false;
    _syncInterval = 30;
    _dataPrivacyLevel = 'standard';
    _measurementUnit = 'metric';
    _currency = 'USD';
    _timeFormat = '24h';
    _dateFormat = 'dd/MM/yyyy';

    notifyListeners();
  }

  // Format values according to settings
  String formatMeasurement(double value, String unit) {
    if (_measurementUnit == 'imperial') {
      switch (unit) {
        case 'km':
          return '${(value * 0.621371).toStringAsFixed(2)} mi';
        case 'kg':
          return '${(value * 2.20462).toStringAsFixed(2)} lb';
        case 'cm':
          return '${(value * 0.393701).toStringAsFixed(2)} in';
        default:
          return '$value $unit';
      }
    }
    return '$value $unit';
  }

  String formatCurrency(double amount) {
    return '$_currency ${amount.toStringAsFixed(2)}';
  }

  String formatTime(DateTime time) {
    if (_timeFormat == '12h') {
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    switch (_dateFormat) {
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      default:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // Get supported options
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'de', 'hi'];
  static const List<String> supportedPrivacyLevels = ['basic', 'standard', 'strict'];
  static const List<String> supportedMeasurementUnits = ['metric', 'imperial'];
  static const List<String> supportedCurrencies = ['USD', 'EUR', 'GBP', 'INR'];
  static const List<String> supportedTimeFormats = ['12h', '24h'];
  static const List<String> supportedDateFormats = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd'
  ];
  static const List<int> supportedSyncIntervals = [15, 30, 60, 120, 240];
}