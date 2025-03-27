import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/performance_data.dart';
import '../utils/constants.dart';

enum WearableType {
  fitbit,
  garmin,
  appleHealth,
  googleFit,
  other
}

class WearableService {
  final String apiKey;
  final http.Client _client;

  WearableService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Base headers for API requests
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  // Connect to wearable device
  Future<bool> connectDevice({
    required WearableType type,
    required String deviceId,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.wearableApi}/connect'),
        headers: _headers,
        body: jsonEncode({
          'type': type.toString().split('.').last,
          'deviceId': deviceId,
          ...?additionalParams,
        }),
      );

      _handleResponse(response);
      return true;
    } catch (e) {
      throw _handleError('Failed to connect device', e);
    }
  }

  // Fetch real-time performance data
  Future<PerformanceData> fetchRealtimeData({
    required String userId,
    required String deviceId,
    List<String>? metrics,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiEndpoints.wearableApi}/realtime').replace(
          queryParameters: {
            'userId': userId,
            'deviceId': deviceId,
            if (metrics != null) 'metrics': metrics.join(','),
          },
        ),
        headers: _headers,
      );

      final data = _handleResponse(response);
      return PerformanceData.fromJson(data);
    } catch (e) {
      throw _handleError('Failed to fetch realtime data', e);
    }
  }

  // Fetch historical performance data
  Future<List<PerformanceData>> fetchHistoricalData({
    required String userId,
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? metrics,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiEndpoints.wearableApi}/historical').replace(
          queryParameters: {
            'userId': userId,
            'deviceId': deviceId,
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
            if (metrics != null) 'metrics': metrics.join(','),
          },
        ),
        headers: _headers,
      );

      final List<dynamic> data = _handleResponse(response);
      return data.map((item) => PerformanceData.fromJson(item)).toList();
    } catch (e) {
      throw _handleError('Failed to fetch historical data', e);
    }
  }

  // Sync data from wearable device
  Future<void> syncData({
    required String userId,
    required String deviceId,
    DateTime? lastSyncTime,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.wearableApi}/sync'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'deviceId': deviceId,
          if (lastSyncTime != null)
            'lastSyncTime': lastSyncTime.toIso8601String(),
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to sync data', e);
    }
  }

  // Subscribe to real-time updates
  Stream<PerformanceData> subscribeToUpdates({
    required String userId,
    required String deviceId,
    List<String>? metrics,
  }) async* {
    try {
      final request = http.Request(
        'GET',
        Uri.parse('${ApiEndpoints.wearableApi}/subscribe').replace(
          queryParameters: {
            'userId': userId,
            'deviceId': deviceId,
            if (metrics != null) 'metrics': metrics.join(','),
          },
        ),
      )..headers.addAll(_headers);

      final streamedResponse = await _client.send(request);
      await for (final data in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (data.isEmpty) continue;
        yield PerformanceData.fromJson(jsonDecode(data));
      }
    } catch (e) {
      throw _handleError('Failed to subscribe to updates', e);
    }
  }

  // Get device status
  Future<Map<String, dynamic>> getDeviceStatus(String deviceId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiEndpoints.wearableApi}/status/$deviceId'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to get device status', e);
    }
  }

  // Update device settings
  Future<void> updateDeviceSettings({
    required String deviceId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiEndpoints.wearableApi}/settings/$deviceId'),
        headers: _headers,
        body: jsonEncode(settings),
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to update device settings', e);
    }
  }

  // Disconnect device
  Future<void> disconnectDevice(String deviceId) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiEndpoints.wearableApi}/disconnect/$deviceId'),
        headers: _headers,
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to disconnect device', e);
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    throw Exception(
      'API Error: ${response.statusCode} - ${response.reasonPhrase}\n'
      'Body: ${response.body}',
    );
  }

  // Handle errors
  Exception _handleError(String message, dynamic error) {
    if (error is http.ClientException) {
      return Exception('$message: Network error - ${error.message}');
    }
    return Exception('$message: ${error.toString()}');
  }

  // Cleanup resources
  void dispose() {
    _client.close();
  }
}