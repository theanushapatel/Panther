import 'dart:async';
import 'package:flutter/material.dart';
import '../models/performance_data.dart';
import '../models/injury.dart';
import '../services/ai_service.dart';

enum AnalysisStatus {
  idle,
  analyzing,
  completed,
  error,
}

class AIProvider with ChangeNotifier {
  final AIService _aiService;

  // State
  AnalysisStatus _status = AnalysisStatus.idle;
  Map<String, dynamic>? _performanceInsights;
  Map<String, dynamic>? _injuryPredictions;
  List<Map<String, dynamic>>? _trainingRecommendations;
  Map<String, dynamic>? _recoveryAnalysis;
  String? _error;
  bool _isLoading = false;
  Timer? _analysisTimer;

  // Cache
  final Map<String, dynamic> _insightsCache = {};
  final Duration _cacheDuration = const Duration(minutes: 30);

  AIProvider({
    required AIService aiService,
  }) : _aiService = aiService {
    _startPeriodicAnalysis();
  }

  // Getters
  AnalysisStatus get status => _status;
  Map<String, dynamic>? get performanceInsights => _performanceInsights;
  Map<String, dynamic>? get injuryPredictions => _injuryPredictions;
  List<Map<String, dynamic>>? get trainingRecommendations => _trainingRecommendations;
  Map<String, dynamic>? get recoveryAnalysis => _recoveryAnalysis;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Start periodic analysis
  void _startPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => analyzePerformanceData([]),
    );
  }

  // Analyze performance data
  Future<void> analyzePerformanceData(
    List<PerformanceData> performanceData,
  ) async {
    if (_status == AnalysisStatus.analyzing) return;

    final cacheKey = 'performance_${DateTime.now().day}';
    if (_checkCache(cacheKey)) {
      _performanceInsights = _insightsCache[cacheKey];
      notifyListeners();
      return;
    }

    _setStatus(AnalysisStatus.analyzing);
    _setLoading(true);

    try {
      final insights = await _aiService.analyzePerformance(performanceData);
      _performanceInsights = insights;
      _updateCache(cacheKey, insights);
      _setStatus(AnalysisStatus.completed);
    } catch (e) {
      _setError('Failed to analyze performance data: $e');
      _setStatus(AnalysisStatus.error);
    } finally {
      _setLoading(false);
    }
  }

  // Get training recommendations
  Future<void> getTrainingRecommendations({
    required String userId,
    required List<PerformanceData> recentPerformance,
    List<Injury>? injuries,
    Map<String, dynamic>? preferences,
  }) async {
    final cacheKey = 'recommendations_$userId';
    if (_checkCache(cacheKey)) {
      _trainingRecommendations = _insightsCache[cacheKey];
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final recommendations = await _aiService.getTrainingRecommendations(
        userId: userId,
        recentPerformance: recentPerformance,
        injuries: injuries,
        preferences: preferences,
      );
      _trainingRecommendations = recommendations;
      _updateCache(cacheKey, recommendations);
    } catch (e) {
      _setError('Failed to get training recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Predict injury risks
  Future<void> predictInjuryRisks({
    required String userId,
    required List<PerformanceData> performanceHistory,
    List<Injury>? injuryHistory,
  }) async {
    final cacheKey = 'injury_predictions_$userId';
    if (_checkCache(cacheKey)) {
      _injuryPredictions = _insightsCache[cacheKey];
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final predictions = await _aiService.predictInjuryRisks(
        userId: userId,
        performanceHistory: performanceHistory,
        injuryHistory: injuryHistory,
      );
      _injuryPredictions = predictions;
      _updateCache(cacheKey, predictions);
    } catch (e) {
      _setError('Failed to predict injury risks: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get technique improvements
  Future<List<Map<String, dynamic>>> getTechniqueImprovements({
    required String userId,
    required String sport,
    required Map<String, dynamic> techniqueData,
  }) async {
    final cacheKey = 'technique_${userId}_${DateTime.now().day}';
    if (_checkCache(cacheKey)) {
      return _insightsCache[cacheKey];
    }

    try {
      final improvements = await _aiService.getTechniqueImprovements(
        userId: userId,
        sport: sport,
        techniqueData: techniqueData,
      );
      _updateCache(cacheKey, improvements);
      return improvements;
    } catch (e) {
      _setError('Failed to get technique improvements: $e');
      rethrow;
    }
  }

  // Generate training plan
  Future<Map<String, dynamic>> generateTrainingPlan({
    required String userId,
    required Map<String, dynamic> athleteProfile,
    required Map<String, dynamic> goals,
    Map<String, dynamic>? constraints,
  }) async {
    final cacheKey = 'training_plan_$userId';
    if (_checkCache(cacheKey)) {
      return _insightsCache[cacheKey];
    }

    try {
      final plan = await _aiService.generateTrainingPlan(
        userId: userId,
        athleteProfile: athleteProfile,
        goals: goals,
        constraints: constraints,
      );
      _updateCache(cacheKey, plan);
      return plan;
    } catch (e) {
      _setError('Failed to generate training plan: $e');
      rethrow;
    }
  }

  // Analyze recovery progress
  Future<void> analyzeRecoveryProgress({
    required String userId,
    required Injury injury,
    required List<Map<String, dynamic>> recoveryData,
  }) async {
    final cacheKey = 'recovery_${injury.id}';
    if (_checkCache(cacheKey)) {
      _recoveryAnalysis = _insightsCache[cacheKey];
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final analysis = await _aiService.analyzeRecoveryProgress(
        userId: userId,
        injury: injury,
        recoveryData: recoveryData,
      );
      _recoveryAnalysis = analysis;
      _updateCache(cacheKey, analysis);
    } catch (e) {
      _setError('Failed to analyze recovery progress: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Analyze technique video
  Future<Map<String, dynamic>> analyzeTechniqueVideo({
    required String userId,
    required String videoUrl,
    required String sport,
    Map<String, dynamic>? analysisPreferences,
  }) async {
    try {
      return await _aiService.analyzeTechniqueVideo(
        userId: userId,
        videoUrl: videoUrl,
        sport: sport,
        analysisPreferences: analysisPreferences,
      );
    } catch (e) {
      _setError('Failed to analyze technique video: $e');
      rethrow;
    }
  }

  // Cache management
  bool _checkCache(String key) {
    if (!_insightsCache.containsKey(key)) return false;
    
    final cacheEntry = _insightsCache[key];
    final timestamp = cacheEntry['timestamp'] as DateTime;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  void _updateCache(String key, dynamic data) {
    _insightsCache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  void clearCache() {
    _insightsCache.clear();
    notifyListeners();
  }

  // Helper methods
  void _setStatus(AnalysisStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }
}

// Extension for easy access in widgets
extension AIProviderExtension on BuildContext {
  AIProvider get aiProvider => Provider.of<AIProvider>(this, listen: false);
}