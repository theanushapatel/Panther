class PerformanceData {
  final String id;
  final String userId;
  final DateTime timestamp;
  final Map<String, double> metrics;
  final String? deviceSource;
  final Map<String, dynamic>? aiInsights;
  final List<String>? tags;

  PerformanceData({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.metrics,
    this.deviceSource,
    this.aiInsights,
    this.tags,
  });

  // Predefined metric keys for type safety
  static const String SPEED = 'speed';
  static const String DISTANCE = 'distance';
  static const String HEART_RATE = 'heartRate';
  static const String CALORIES = 'calories';
  static const String STEPS = 'steps';
  static const String ELEVATION = 'elevation';
  static const String POWER = 'power';
  static const String CADENCE = 'cadence';

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metrics: Map<String, double>.from(json['metrics'] as Map),
      deviceSource: json['deviceSource'] as String?,
      aiInsights: json['aiInsights'] as Map<String, dynamic>?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'metrics': metrics,
      'deviceSource': deviceSource,
      'aiInsights': aiInsights,
      'tags': tags,
    };
  }

  PerformanceData copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    Map<String, double>? metrics,
    String? deviceSource,
    Map<String, dynamic>? aiInsights,
    List<String>? tags,
  }) {
    return PerformanceData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      metrics: metrics ?? this.metrics,
      deviceSource: deviceSource ?? this.deviceSource,
      aiInsights: aiInsights ?? this.aiInsights,
      tags: tags ?? this.tags,
    );
  }

  // Helper methods for common metrics
  double? getSpeed() => metrics[SPEED];
  double? getDistance() => metrics[DISTANCE];
  double? getHeartRate() => metrics[HEART_RATE];
  double? getCalories() => metrics[CALORIES];
  double? getSteps() => metrics[STEPS];
  double? getElevation() => metrics[ELEVATION];
  double? getPower() => metrics[POWER];
  double? getCadence() => metrics[CADENCE];

  // Utility method to calculate intensity score based on metrics
  double calculateIntensityScore() {
    double score = 0;
    if (getHeartRate() != null) {
      score += (getHeartRate()! / 180) * 50; // Max heart rate contribution
    }
    if (getPower() != null) {
      score += (getPower()! / 300) * 30; // Power output contribution
    }
    if (getSpeed() != null) {
      score += (getSpeed()! / 30) * 20; // Speed contribution
    }
    return score.clamp(0, 100); // Returns a score between 0-100
  }

  // Method to get AI-generated insights for specific metric
  String? getInsightForMetric(String metricName) {
    return aiInsights?[metricName] as String?;
  }

  @override
  String toString() {
    return 'PerformanceData(id: $id, userId: $userId, timestamp: $timestamp, metrics: $metrics)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extension for performance data analysis
extension PerformanceDataAnalysis on List<PerformanceData> {
  // Calculate average for a specific metric over time
  double? calculateAverageMetric(String metricKey) {
    if (isEmpty) return null;
    
    double sum = 0;
    int count = 0;
    
    for (var data in this) {
      if (data.metrics[metricKey] != null) {
        sum += data.metrics[metricKey]!;
        count++;
      }
    }
    
    return count > 0 ? sum / count : null;
  }

  // Get performance trend (positive or negative) for a specific metric
  double calculateMetricTrend(String metricKey) {
    if (length < 2) return 0;
    
    var sortedData = [...this]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    var firstValue = sortedData.first.metrics[metricKey];
    var lastValue = sortedData.last.metrics[metricKey];
    
    if (firstValue == null || lastValue == null) return 0;
    
    return ((lastValue - firstValue) / firstValue) * 100;
  }
}