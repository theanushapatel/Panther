import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences.dart';

enum NotificationType {
  performance,
  injury,
  career,
  financial,
  wearable,
  system,
}

class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _messaging;
  final SharedPreferences _prefs;

  // State
  bool _isInitialized = false;
  String? _fcmToken;
  Map<NotificationType, bool> _notificationSettings = {};
  List<NotificationMessage> _notifications = [];
  int _unreadCount = 0;
  String? _error;

  // Constants
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _notificationsKey = 'notifications';
  static const int _maxStoredNotifications = 100;

  NotificationProvider(this._messaging, this._prefs) {
    _initialize();
  }

  // Getters
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;
  Map<NotificationType, bool> get notificationSettings => _notificationSettings;
  List<NotificationMessage> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get error => _error;

  // Initialize notifications
  Future<void> _initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();

        // Load saved settings
        _loadNotificationSettings();
        _loadStoredNotifications();

        // Set up message handlers
        _messaging.onMessage.listen(_handleForegroundMessage);
        _messaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
        _messaging.onBackgroundMessage(_handleBackgroundMessage);

        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
    }
  }

  // Load saved notification settings
  void _loadNotificationSettings() {
    try {
      final savedSettings = _prefs.getString(_notificationSettingsKey);
      if (savedSettings != null) {
        final Map<String, dynamic> settings = Map<String, dynamic>.from(
          Map<String, dynamic>.from(savedSettings as Map),
        );
        _notificationSettings = settings.map(
          (key, value) => MapEntry(
            NotificationType.values.firstWhere(
              (type) => type.toString() == key,
            ),
            value as bool,
          ),
        );
      } else {
        // Set default settings
        for (var type in NotificationType.values) {
          _notificationSettings[type] = true;
        }
      }
    } catch (e) {
      _setError('Failed to load notification settings: $e');
    }
  }

  // Load stored notifications
  void _loadStoredNotifications() {
    try {
      final savedNotifications = _prefs.getStringList(_notificationsKey);
      if (savedNotifications != null) {
        _notifications = savedNotifications
            .map((json) => NotificationMessage.fromJson(json))
            .toList();
        _updateUnreadCount();
      }
    } catch (e) {
      _setError('Failed to load stored notifications: $e');
    }
  }

  // Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = NotificationMessage.fromRemoteMessage(message);
    if (_shouldShowNotification(notification.type)) {
      _addNotification(notification);
    }
  }

  // Handle message opened app
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    final notification = NotificationMessage.fromRemoteMessage(message);
    if (_shouldShowNotification(notification.type)) {
      _addNotification(notification);
      // Handle navigation or other actions based on notification type
    }
  }

  // Handle background message
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
    // Note: This method must be static and can't access instance variables
  }

  // Add notification
  Future<void> _addNotification(NotificationMessage notification) async {
    _notifications.insert(0, notification);
    if (_notifications.length > _maxStoredNotifications) {
      _notifications.removeLast();
    }
    _updateUnreadCount();
    await _saveNotifications();
    notifyListeners();
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final notificationStrings =
          _notifications.map((n) => n.toJson()).toList();
      await _prefs.setStringList(_notificationsKey, notificationStrings);
    } catch (e) {
      _setError('Failed to save notifications: $e');
    }
  }

  // Update notification settings
  Future<void> updateNotificationSetting(
    NotificationType type,
    bool enabled,
  ) async {
    _notificationSettings[type] = enabled;
    await _saveNotificationSettings();
    notifyListeners();
  }

  // Save notification settings
  Future<void> _saveNotificationSettings() async {
    try {
      final settings = _notificationSettings.map(
        (type, enabled) => MapEntry(type.toString(), enabled),
      );
      await _prefs.setString(_notificationSettingsKey, settings.toString());
    } catch (e) {
      _setError('Failed to save notification settings: $e');
    }
  }

  // Check if notification should be shown
  bool _shouldShowNotification(NotificationType type) {
    return _notificationSettings[type] ?? true;
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _updateUnreadCount();
    await _saveNotifications();
    notifyListeners();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    await _saveNotifications();
    notifyListeners();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    _updateUnreadCount();
    await _saveNotifications();
    notifyListeners();
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
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

  @override
  void dispose() {
    super.dispose();
  }
}

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationMessage.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      id: message.messageId ?? DateTime.now().toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.toString() == message.data['type'],
        orElse: () => NotificationType.system,
      ),
      timestamp: message.sentTime ?? DateTime.now(),
      data: message.data,
    );
  }

  factory NotificationMessage.fromJson(String json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      Map<String, dynamic>.from(json as Map),
    );
    return NotificationMessage(
      id: data['id'] as String,
      title: data['title'] as String,
      body: data['body'] as String,
      type: NotificationType.values.firstWhere(
        (type) => type.toString() == data['type'],
      ),
      timestamp: DateTime.parse(data['timestamp'] as String),
      isRead: data['isRead'] as bool,
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  String toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    }.toString();
  }

  NotificationMessage copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

// Extension for easy access in widgets
extension NotificationProviderExtension on BuildContext {
  NotificationProvider get notificationProvider =>
      Provider.of<NotificationProvider>(this, listen: false);
}