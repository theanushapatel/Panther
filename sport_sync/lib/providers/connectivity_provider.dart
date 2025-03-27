import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences.dart';

enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
}

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  
  // Stream subscriptions
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;

  // State
  bool _isOnline = true;
  bool _isSyncEnabled = true;
  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  List<Map<String, dynamic>> _pendingOperations = [];
  String? _error;

  // Constants
  static const String _lastSyncKey = 'last_sync_time';
  static const String _pendingOperationsKey = 'pending_operations';
  static const String _isSyncEnabledKey = 'is_sync_enabled';

  ConnectivityProvider(this._connectivity, this._prefs) {
    _initializeConnectivity();
    _loadStoredData();
    _startSyncTimer();
  }

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncEnabled => _isSyncEnabled;
  SyncStatus get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<Map<String, dynamic>> get pendingOperations => _pendingOperations;
  String? get error => _error;

  // Initialize connectivity monitoring
  Future<void> _initializeConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
        _updateConnectionStatus(result);
        if (_isOnline) {
          syncPendingOperations();
        }
      });
    } catch (e) {
      _setError('Failed to initialize connectivity monitoring: $e');
    }
  }

  // Load stored data
  void _loadStoredData() {
    try {
      // Load last sync time
      final lastSyncStr = _prefs.getString(_lastSyncKey);
      if (lastSyncStr != null) {
        _lastSyncTime = DateTime.parse(lastSyncStr);
      }

      // Load pending operations
      final pendingOps = _prefs.getStringList(_pendingOperationsKey);
      if (pendingOps != null) {
        _pendingOperations = pendingOps
            .map((op) => Map<String, dynamic>.from(
                Map<String, dynamic>.from(op as Map)))
            .toList();
      }

      // Load sync enabled status
      _isSyncEnabled = _prefs.getBool(_isSyncEnabledKey) ?? true;
    } catch (e) {
      _setError('Failed to load stored data: $e');
    }
  }

  // Start sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    if (_isSyncEnabled) {
      _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
        if (_isOnline) {
          syncPendingOperations();
        }
      });
    }
  }

  // Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  // Add pending operation
  Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    try {
      _pendingOperations.add(operation);
      await _savePendingOperations();
      notifyListeners();

      if (_isOnline) {
        await syncPendingOperations();
      }
    } catch (e) {
      _setError('Failed to add pending operation: $e');
    }
  }

  // Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final List<String> serializedOps = _pendingOperations
          .map((op) => op.toString())
          .toList();
      await _prefs.setStringList(_pendingOperationsKey, serializedOps);
    } catch (e) {
      _setError('Failed to save pending operations: $e');
    }
  }

  // Sync pending operations
  Future<void> syncPendingOperations() async {
    if (!_isOnline || _syncStatus == SyncStatus.syncing || _pendingOperations.isEmpty) {
      return;
    }

    _setSyncStatus(SyncStatus.syncing);

    try {
      for (var operation in List.from(_pendingOperations)) {
        await _processPendingOperation(operation);
        _pendingOperations.remove(operation);
      }

      await _savePendingOperations();
      await _updateLastSyncTime();
      _setSyncStatus(SyncStatus.completed);
    } catch (e) {
      _setError('Failed to sync pending operations: $e');
      _setSyncStatus(SyncStatus.error);
    }
  }

  // Process individual pending operation
  Future<void> _processPendingOperation(Map<String, dynamic> operation) async {
    try {
      // Implement the logic to process different types of operations
      switch (operation['type']) {
        case 'create':
          // Handle create operation
          break;
        case 'update':
          // Handle update operation
          break;
        case 'delete':
          // Handle delete operation
          break;
        default:
          throw Exception('Unknown operation type: ${operation['type']}');
      }
    } catch (e) {
      _setError('Failed to process operation: $e');
      rethrow;
    }
  }

  // Update last sync time
  Future<void> _updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    await _prefs.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());
    notifyListeners();
  }

  // Enable/disable sync
  Future<void> setSyncEnabled(bool enabled) async {
    _isSyncEnabled = enabled;
    await _prefs.setBool(_isSyncEnabledKey, enabled);
    
    if (enabled) {
      _startSyncTimer();
      if (_isOnline) {
        await syncPendingOperations();
      }
    } else {
      _syncTimer?.cancel();
    }
    
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set sync status
  void _setSyncStatus(SyncStatus status) {
    _syncStatus = status;
    notifyListeners();
  }

  // Check if sync is needed
  bool isSyncNeeded() {
    if (_lastSyncTime == null) return true;
    
    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
    return timeSinceLastSync.inMinutes >= 30;
  }

  // Force sync
  Future<void> forceSync() async {
    if (!_isOnline) {
      _setError('No internet connection available');
      return;
    }

    await syncPendingOperations();
  }

  // Clear all pending operations
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}

// Extension for easy access in widgets
extension ConnectivityProviderExtension on BuildContext {
  ConnectivityProvider get connectivityProvider => 
      Provider.of<ConnectivityProvider>(this, listen: false);
}

// Mixin for handling offline operations
mixin OfflineOperationHandler {
  Future<void> performOfflineOperation(
    BuildContext context,
    Map<String, dynamic> operation,
  ) async {
    final provider = context.connectivityProvider;
    
    if (provider.isOnline) {
      try {
        await provider._processPendingOperation(operation);
      } catch (e) {
        await provider.addPendingOperation(operation);
      }
    } else {
      await provider.addPendingOperation(operation);
    }
  }
}