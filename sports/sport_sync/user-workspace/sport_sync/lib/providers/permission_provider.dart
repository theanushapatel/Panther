import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences.dart';

enum AppPermission {
  camera,
  location,
  storage,
  notifications,
  sensors,
  bluetooth,
  microphone,
  healthKit, // iOS only
  googleFit, // Android only
}

class PermissionProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  // State
  Map<AppPermission, PermissionStatus> _permissionStatus = {};
  Map<AppPermission, bool> _permanentlyDenied = {};
  String? _error;

  // Constants
  static const String _permissionDeniedKey = 'permanently_denied_permissions';

  PermissionProvider(this._prefs) {
    _loadPermanentlyDeniedPermissions();
  }

  // Getters
  Map<AppPermission, PermissionStatus> get permissionStatus => _permissionStatus;
  Map<AppPermission, bool> get permanentlyDenied => _permanentlyDenied;
  String? get error => _error;

  // Load permanently denied permissions
  void _loadPermanentlyDeniedPermissions() {
    try {
      final deniedPermissions = _prefs.getStringList(_permissionDeniedKey);
      if (deniedPermissions != null) {
        for (var permission in deniedPermissions) {
          _permanentlyDenied[AppPermission.values.firstWhere(
            (p) => p.toString() == permission,
          )] = true;
        }
      }
    } catch (e) {
      _setError('Failed to load permission settings: $e');
    }
  }

  // Save permanently denied permissions
  Future<void> _savePermanentlyDeniedPermissions() async {
    try {
      final deniedPermissions = _permanentlyDenied.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.toString())
          .toList();
      await _prefs.setStringList(_permissionDeniedKey, deniedPermissions);
    } catch (e) {
      _setError('Failed to save permission settings: $e');
    }
  }

  // Request permission
  Future<bool> requestPermission(AppPermission permission) async {
    try {
      final status = await _getPermission(permission).request();
      _permissionStatus[permission] = status;
      
      if (status.isPermanentlyDenied) {
        _permanentlyDenied[permission] = true;
        await _savePermanentlyDeniedPermissions();
      }

      notifyListeners();
      return status.isGranted;
    } catch (e) {
      _setError('Failed to request permission: $e');
      return false;
    }
  }

  // Check permission status
  Future<bool> checkPermission(AppPermission permission) async {
    try {
      final status = await _getPermission(permission).status;
      _permissionStatus[permission] = status;
      notifyListeners();
      return status.isGranted;
    } catch (e) {
      _setError('Failed to check permission status: $e');
      return false;
    }
  }

  // Check if permission is permanently denied
  bool isPermanentlyDenied(AppPermission permission) {
    return _permanentlyDenied[permission] ?? false;
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      _setError('Failed to open app settings: $e');
      return false;
    }
  }

  // Request multiple permissions
  Future<Map<AppPermission, bool>> requestMultiplePermissions(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, bool>{};
    
    for (var permission in permissions) {
      results[permission] = await requestPermission(permission);
    }
    
    return results;
  }

  // Get Permission object from AppPermission enum
  Permission _getPermission(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.location:
        return Permission.location;
      case AppPermission.storage:
        return Permission.storage;
      case AppPermission.notifications:
        return Permission.notification;
      case AppPermission.sensors:
        return Permission.sensors;
      case AppPermission.bluetooth:
        return Permission.bluetooth;
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.healthKit:
        return Permission.health;
      case AppPermission.googleFit:
        return Permission.activityRecognition;
    }
  }

  // Check if all required permissions are granted
  Future<bool> checkRequiredPermissions() async {
    final requiredPermissions = [
      AppPermission.location,
      AppPermission.sensors,
      AppPermission.bluetooth,
    ];

    for (var permission in requiredPermissions) {
      if (!await checkPermission(permission)) {
        return false;
      }
    }

    return true;
  }

  // Handle permission result
  Future<void> handlePermissionResult(
    AppPermission permission,
    PermissionStatus status,
  ) async {
    _permissionStatus[permission] = status;

    if (status.isPermanentlyDenied) {
      _permanentlyDenied[permission] = true;
      await _savePermanentlyDeniedPermissions();
    }

    notifyListeners();
  }

  // Reset permanently denied status
  Future<void> resetPermanentlyDenied(AppPermission permission) async {
    _permanentlyDenied.remove(permission);
    await _savePermanentlyDeniedPermissions();
    notifyListeners();
  }

  // Get permission description
  String getPermissionDescription(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return 'Required for capturing photos and video analysis';
      case AppPermission.location:
        return 'Required for tracking outdoor activities and route mapping';
      case AppPermission.storage:
        return 'Required for storing workout data and media files';
      case AppPermission.notifications:
        return 'Required for receiving important updates and reminders';
      case AppPermission.sensors:
        return 'Required for tracking movement and activity data';
      case AppPermission.bluetooth:
        return 'Required for connecting to wearable devices';
      case AppPermission.microphone:
        return 'Required for voice commands and audio feedback';
      case AppPermission.healthKit:
        return 'Required for accessing health and fitness data on iOS devices';
      case AppPermission.googleFit:
        return 'Required for accessing fitness data on Android devices';
    }
  }

  // Get permission icon
  IconData getPermissionIcon(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Icons.camera_alt;
      case AppPermission.location:
        return Icons.location_on;
      case AppPermission.storage:
        return Icons.storage;
      case AppPermission.notifications:
        return Icons.notifications;
      case AppPermission.sensors:
        return Icons.sensors;
      case AppPermission.bluetooth:
        return Icons.bluetooth;
      case AppPermission.microphone:
        return Icons.mic;
      case AppPermission.healthKit:
        return Icons.health_and_safety;
      case AppPermission.googleFit:
        return Icons.fitness_center;
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
extension PermissionProviderExtension on BuildContext {
  PermissionProvider get permissionProvider =>
      Provider.of<PermissionProvider>(this, listen: false);
}

// Mixin for handling permissions in widgets
mixin PermissionHandler<T extends StatefulWidget> on State<T> {
  Future<bool> checkAndRequestPermission(AppPermission permission) async {
    final provider = context.permissionProvider;
    
    if (await provider.checkPermission(permission)) {
      return true;
    }

    if (provider.isPermanentlyDenied(permission)) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
            '${provider.getPermissionDescription(permission)}\n\n'
            'Please enable this permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        return provider.openAppSettings();
      }
      return false;
    }

    return provider.requestPermission(permission);
  }
}