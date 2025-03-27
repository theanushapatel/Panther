import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/performance_data.dart';
import '../models/injury.dart';
import '../utils/constants.dart';

class AIService {
  final String apiKey;
  final http.Client _client;

  AIService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Base headers for API requests
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  // Analyze performance data using Vertex AI
  Future<Map<String, dynamic>> analyzePerformance(
    List<PerformanceData> performanceData,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.vertexAi}/analyze'),
        headers: _headers,
        body: jsonEncode({
          'data': performanceData.map((data) => data.toJson()).toList(),
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to analyze performance', e);
    }
  }

  // Get personalized training recommendations
  Future<List<Map<String, dynamic>>> getTrainingRecommendations({
    required String userId,
    required List<PerformanceData> recentPerformance,
    List<Injury>? injuries,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.vertexAi}/recommendations'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'recentPerformance': recentPerformance.map((p) => p.toJson()).toList(),
          if (injuries != null)
            'injuries': injuries.map((i) => i.toJson()).toList(),
          if (preferences != null) 'preferences': preferences,
        }),
      );

      final List<dynamic> data = _handleResponse(response);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError('Failed to get training recommendations', e);
    }
  }

  // Predict injury risks using Vertex AI
  Future<Map<String, dynamic>> predictInjuryRisks({
    required String userId,
    required List<PerformanceData> performanceHistory,
    List<Injury>? injuryHistory,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.vertexAi}/injury-prediction'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'performanceHistory': performanceHistory.map((p) => p.toJson()).toList(),
          if (injuryHistory != null)
            'injuryHistory': injuryHistory.map((i) => i.toJson()).toList(),
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to predict injury risks', e);
    }
  }

  // Get technique improvement suggestions using Gemini
  Future<List<Map<String, dynamic>>> getTechniqueImprovements({
    required String userId,
    required String sport,
    required Map<String, dynamic> techniqueData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.gemini}/technique-analysis'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'sport': sport,
          'techniqueData': techniqueData,
        }),
      );

      final List<dynamic> data = _handleResponse(response);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError('Failed to get technique improvements', e);
    }
  }

  // Generate personalized training plan
  Future<Map<String, dynamic>> generateTrainingPlan({
    required String userId,
    required Map<String, dynamic> athleteProfile,
    required Map<String, dynamic> goals,
    Map<String, dynamic>? constraints,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.vertexAi}/training-plan'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'athleteProfile': athleteProfile,
          'goals': goals,
          if (constraints != null) 'constraints': constraints,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to generate training plan', e);
    }
  }

  // Get performance insights using Gemini
  Future<List<Map<String, dynamic>>> getPerformanceInsights({
    required String userId,
    required List<PerformanceData> performanceData,
    String? focusArea,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.gemini}/performance-insights'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'performanceData': performanceData.map((p) => p.toJson()).toList(),
          if (focusArea != null) 'focusArea': focusArea,
        }),
      );

      final List<dynamic> data = _handleResponse(response);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError('Failed to get performance insights', e);
    }
  }

  // Analyze recovery progress
  Future<Map<String, dynamic>> analyzeRecoveryProgress({
    required String userId,
    required Injury injury,
    required List<Map<String, dynamic>> recoveryData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.vertexAi}/recovery-analysis'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'injury': injury.toJson(),
          'recoveryData': recoveryData,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to analyze recovery progress', e);
    }
  }

  // Get AI-powered feedback on technique videos
  Future<Map<String, dynamic>> analyzeTechniqueVideo({
    required String userId,
    required String videoUrl,
    required String sport,
    Map<String, dynamic>? analysisPreferences,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.gemini}/video-analysis'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'videoUrl': videoUrl,
          'sport': sport,
          if (analysisPreferences != null)
            'analysisPreferences': analysisPreferences,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to analyze technique video', e);
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    throw Exception(
      'AI API Error: ${response.statusCode} - ${response.reasonPhrase}\n'
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