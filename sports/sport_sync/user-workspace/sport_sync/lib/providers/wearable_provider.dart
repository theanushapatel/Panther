import 'dart:async';
import 'package:flutter/material.dart';
import '../models/performance_data.dart';
import '../services/wearable_service.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

enum DeviceConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class WearableProvider with ChangeNotifier {
  final WearableService _wearableService;
  final FirebaseService _firebaseService;

  // State
  DeviceConnectionStatus _connectionStatus = DeviceConnectionStatus.disconnected;
  String? _connectedDeviceId;
  WearableType? _connectedDeviceType;
  StreamSubscription<PerformanceData>? _dataSubscription;
  List<PerformanceData> _realtimeData = [];
  DateTime? _lastSyncTime;
  String? _error;
  bool _isLoading = false;

  // Getters
  DeviceConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectedDeviceId => _connectedDeviceId;
  WearableType? get connectedDeviceType => _connectedDeviceType;
  List<PerformanceData> get realtimeData => _realtimeData;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isConnected => _connectionStatus == DeviceConnectionStatus.connected;

  WearableProvider({
    required WearableService wearableService,
    required FirebaseService firebaseService,
  })  : _wearableService = wearableService,
        _firebaseService = firebaseService;

  // Connect to wearable device
  Future<void> connectDevice({
    required WearableType type,
    required String deviceId,
    Map<String, dynamic>? additionalParams,
  }) async {
    if (_connectionStatus == DeviceConnectionStatus.connecting) return;

    _setConnectionStatus(DeviceConnectionStatus.connecting);
    _clearError();

    try {
      final success = await _wearableService.connectDevice(
        type: type,
        deviceId: deviceId,
        additionalParams: additionalParams,
      );

      if (success) {
        _connectedDeviceId = deviceId;
        _connectedDeviceType = type;
        _setConnectionStatus(DeviceConnectionStatus.connected);
        _startRealtimeDataStream();
      } else {
        throw Exception('Failed to connect to device');
      }
    } catch (e) {
      _setError('Failed to connect to device: $e');
      _setConnectionStatus(DeviceConnectionStatus.error);
      rethrow;
    }
  }

  // Disconnect from wearable device
  Future<void> disconnectDevice() async {
    if (_connectedDeviceId == null) return;

    _setLoading(true);

    try {
      await _wearableService.disconnectDevice(_connectedDeviceId!);
      _dataSubscription?.cancel();
      _connectedDeviceId = null;
      _connectedDeviceType = null;
      _realtimeData.clear();
      _setConnectionStatus(DeviceConnectionStatus.disconnected);
    } catch (e) {
      _setError('Failed to disconnect device: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Start realtime data stream
  void _startRealtimeDataStream() {
    if (_connectedDeviceId == null) return;

    _dataSubscription?.cancel();
    _dataSubscription = _wearableService
        .subscribeToUpdates(
          userId: 'current_user_id', // Replace with actual user ID
          deviceId: _connectedDeviceId!,
        )
        .listen(
          _handleRealtimeData,
          onError: (error) => _setError('Realtime data error: $error'),
        );
  }

  // Handle realtime data
  void _handleRealtimeData(PerformanceData data) {
    _realtimeData.add(data);
    if (_realtimeData.length > 100) {
      _realtimeData.removeAt(0);
    }
    notifyListeners();

    // Save data to Firebase if significant change
    if (_shouldSaveData(data)) {
      _savePerformanceData(data);
    }
  }

  // Check if data should be saved
  bool _shouldSaveData(PerformanceData data) {
    if (_realtimeData.length < 2) return true;

    final previousData = _realtimeData[_realtimeData.length - 2];
    final timeDifference = data.timestamp.difference(previousData.timestamp);
    
    // Save data if more than 5 minutes have passed
    if (timeDifference.inMinutes >= 5) return true;

    // Save data if significant change in metrics
    return _hasSignificantChange(data, previousData);
  }

  // Check for significant change in metrics
  bool _hasSignificantChange(PerformanceData current, PerformanceData previous) {
    const threshold = 0.1; // 10% change threshold

    for (var metric in current.metrics.keys) {
      final currentValue = current.metrics[metric] ?? 0;
      final previousValue = previous.metrics[metric] ?? 0;

      if (previousValue == 0) continue;

      final percentChange = (currentValue - previousValue).abs() / previousValue;
      if (percentChange > threshold) return true;
    }

    return false;
  }

  // Save performance data to Firebase
  Future<void> _savePerformanceData(PerformanceData data) async {
    try {
      await _firebaseService.addPerformanceData(data);
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to save performance data: $e');
    }
  }

  // Fetch historical data
  Future<List<PerformanceData>> fetchHistoricalData({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? metrics,
  }) async {
    if (_connectedDeviceId == null) {
      throw Exception('No device connected');
    }

    _setLoading(true);

    try {
      final data = await _wearableService.fetchHistoricalData(
        userId: 'current_user_id', // Replace with actual user ID
        deviceId: _connectedDeviceId!,
        startDate: startDate,
        endDate: endDate,
        metrics: metrics,
      );
      return data;
    } catch (e) {
      _setError('Failed to fetch historical data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get device status
  Future<Map<String, dynamic>> getDeviceStatus() async {
    if (_connectedDeviceId == null) {
      throw Exception('No device connected');
    }

    try {
      return await _wearableService.getDeviceStatus(_connectedDeviceId!);
    } catch (e) {
      _setError('Failed to get device status: $e');
      rethrow;
    }
  }

  // Update device settings
  Future<void> updateDeviceSettings(Map<String, dynamic> settings) async {
    if (_connectedDeviceId == null) {
      throw Exception('No device connected');
    }

    _setLoading(true);

    try {
      await _wearableService.updateDeviceSettings(
        deviceId: _connectedDeviceId!,
        settings: settings,
      );
    } catch (e) {
      _setError('Failed to update device settings: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sync data manually
  Future<void> syncData() async {
    if (_connectedDeviceId == null) {
      throw Exception('No device connected');
    }

    _setLoading(true);

    try {
      await _wearableService.syncData(
        userId: 'current_user_id', // Replace with actual user ID
        deviceId: _connectedDeviceId!,
        lastSyncTime: _lastSyncTime,
      );
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to sync data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setConnectionStatus(DeviceConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
}

// Extension for easy access in widgets
extension WearableProviderExtension on BuildContext {
  WearableProvider get wearableProvider =>
      Provider.of<WearableProvider>(this, listen: false);
}