import 'package:flutter/material.dart';
import '../models/performance_data.dart';
import '../models/injury.dart';
import '../models/career.dart';
import '../models/financial.dart';

class AnalyticsProvider with ChangeNotifier {
  // Performance Analytics
  Map<String, List<double>> _performanceMetrics = {};
  Map<String, double> _averageMetrics = {};
  Map<String, double> _peakMetrics = {};
  List<Map<String, dynamic>> _performanceTrends = [];

  // Health Analytics
  Map<String, int> _injuryFrequency = {};
  Map<String, double> _recoveryRates = {};
  List<Map<String, dynamic>> _healthTrends = [];

  // Career Analytics
  Map<String, int> _achievementCounts = {};
  Map<String, double> _progressMetrics = {};
  List<Map<String, dynamic>> _careerTrends = [];

  // Financial Analytics
  Map<String, double> _financialMetrics = {};
  Map<String, List<double>> _revenueStreams = {};
  List<Map<String, dynamic>> _financialTrends = [];

  // Getters
  Map<String, List<double>> get performanceMetrics => _performanceMetrics;
  Map<String, double> get averageMetrics => _averageMetrics;
  Map<String, double> get peakMetrics => _peakMetrics;
  List<Map<String, dynamic>> get performanceTrends => _performanceTrends;
  Map<String, int> get injuryFrequency => _injuryFrequency;
  Map<String, double> get recoveryRates => _recoveryRates;
  List<Map<String, dynamic>> get healthTrends => _healthTrends;
  Map<String, int> get achievementCounts => _achievementCounts;
  Map<String, double> get progressMetrics => _progressMetrics;
  List<Map<String, dynamic>> get careerTrends => _careerTrends;
  Map<String, double> get financialMetrics => _financialMetrics;
  Map<String, List<double>> get revenueStreams => _revenueStreams;
  List<Map<String, dynamic>> get financialTrends => _financialTrends;

  // Performance Analytics Methods
  void analyzePerformanceData(List<PerformanceData> data) {
    if (data.isEmpty) return;

    // Reset metrics
    _performanceMetrics = {};
    _averageMetrics = {};
    _peakMetrics = {};
    _performanceTrends = [];

    // Process performance data
    for (var entry in data) {
      for (var metric in entry.metrics.entries) {
        // Update performance metrics
        _performanceMetrics.putIfAbsent(metric.key, () => []);
        _performanceMetrics[metric.key]!.add(metric.value);

        // Update peak metrics
        if (!_peakMetrics.containsKey(metric.key) ||
            metric.value > _peakMetrics[metric.key]!) {
          _peakMetrics[metric.key] = metric.value;
        }
      }
    }

    // Calculate averages
    for (var metric in _performanceMetrics.entries) {
      _averageMetrics[metric.key] =
          metric.value.reduce((a, b) => a + b) / metric.value.length;
    }

    // Calculate trends
    _calculatePerformanceTrends(data);

    notifyListeners();
  }

  void _calculatePerformanceTrends(List<PerformanceData> data) {
    // Sort data by timestamp
    final sortedData = List<PerformanceData>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate weekly averages
    final weeklyAverages = <String, List<double>>{};
    for (var entry in sortedData) {
      final weekKey = '${entry.timestamp.year}-${entry.timestamp.weekOfYear}';
      for (var metric in entry.metrics.entries) {
        weeklyAverages.putIfAbsent(metric.key, () => []);
        weeklyAverages[metric.key]!.add(metric.value);
      }
    }

    // Calculate trend percentages
    for (var metric in weeklyAverages.entries) {
      if (metric.value.length >= 2) {
        final firstValue = metric.value.first;
        final lastValue = metric.value.last;
        final trendPercentage = ((lastValue - firstValue) / firstValue) * 100;

        _performanceTrends.add({
          'metric': metric.key,
          'trend': trendPercentage,
          'direction': trendPercentage >= 0 ? 'up' : 'down',
        });
      }
    }
  }

  // Health Analytics Methods
  void analyzeHealthData(List<Injury> injuries) {
    if (injuries.isEmpty) return;

    // Reset metrics
    _injuryFrequency = {};
    _recoveryRates = {};
    _healthTrends = [];

    // Calculate injury frequency
    for (var injury in injuries) {
      _injuryFrequency[injury.type] =
          (_injuryFrequency[injury.type] ?? 0) + 1;
    }

    // Calculate recovery rates
    for (var injury in injuries.where((i) => i.status == InjuryStatus.resolved)) {
      final recoveryDays = injury.expectedRecoveryDate
          ?.difference(injury.dateOccurred)
          .inDays
          .toDouble();
      if (recoveryDays != null) {
        _recoveryRates[injury.type] =
            (_recoveryRates[injury.type] ?? 0) + recoveryDays;
      }
    }

    // Calculate average recovery rates
    for (var type in _recoveryRates.keys) {
      final injuryCount = _injuryFrequency[type] ?? 1;
      _recoveryRates[type] = _recoveryRates[type]! / injuryCount;
    }

    // Calculate health trends
    _calculateHealthTrends(injuries);

    notifyListeners();
  }

  void _calculateHealthTrends(List<Injury> injuries) {
    // Sort injuries by date
    final sortedInjuries = List<Injury>.from(injuries)
      ..sort((a, b) => a.dateOccurred.compareTo(b.dateOccurred));

    // Calculate monthly injury rates
    final monthlyRates = <String, int>{};
    for (var injury in sortedInjuries) {
      final monthKey =
          '${injury.dateOccurred.year}-${injury.dateOccurred.month}';
      monthlyRates[monthKey] = (monthlyRates[monthKey] ?? 0) + 1;
    }

    // Calculate trends
    if (monthlyRates.length >= 2) {
      final values = monthlyRates.values.toList();
      final firstValue = values.first;
      final lastValue = values.last;
      final trendPercentage = ((lastValue - firstValue) / firstValue) * 100;

      _healthTrends.add({
        'metric': 'Monthly Injury Rate',
        'trend': trendPercentage,
        'direction': trendPercentage <= 0 ? 'up' : 'down',
      });
    }
  }

  // Career Analytics Methods
  void analyzeCareerData(Career career) {
    // Reset metrics
    _achievementCounts = {};
    _progressMetrics = {};
    _careerTrends = [];

    // Calculate achievement counts
    for (var achievement in career.achievements) {
      final category = achievement.title.split(' ')[0];
      _achievementCounts[category] = (_achievementCounts[category] ?? 0) + 1;
    }

    // Calculate progress metrics
    _progressMetrics['goals'] = career.calculateProgressPercentage();
    _progressMetrics['courses'] = _calculateCourseProgress(career.courses);
    _progressMetrics['mentorship'] = _calculateMentorshipProgress(
        career.mentorships);

    // Calculate career trends
    _calculateCareerTrends(career);

    notifyListeners();
  }

  double _calculateCourseProgress(List<Course> courses) {
    if (courses.isEmpty) return 0;
    final completedCourses =
        courses.where((c) => c.status == CourseStatus.completed).length;
    return (completedCourses / courses.length) * 100;
  }

  double _calculateMentorshipProgress(List<MentorshipProgram> mentorships) {
    if (mentorships.isEmpty) return 0;
    final completedMentorships = mentorships
        .where((m) => m.status == MentorshipStatus.completed)
        .length;
    return (completedMentorships / mentorships.length) * 100;
  }

  void _calculateCareerTrends(Career career) {
    // Sort achievements by date
    final sortedAchievements = List<Achievement>.from(career.achievements)
      ..sort((a, b) => a.dateAchieved.compareTo(b.dateAchieved));

    // Calculate quarterly achievement rates
    final quarterlyRates = <String, int>{};
    for (var achievement in sortedAchievements) {
      final quarterKey =
          '${achievement.dateAchieved.year}-Q${(achievement.dateAchieved.month / 3).ceil()}';
      quarterlyRates[quarterKey] = (quarterlyRates[quarterKey] ?? 0) + 1;
    }

    // Calculate trends
    if (quarterlyRates.length >= 2) {
      final values = quarterlyRates.values.toList();
      final firstValue = values.first;
      final lastValue = values.last;
      final trendPercentage = ((lastValue - firstValue) / firstValue) * 100;

      _careerTrends.add({
        'metric': 'Quarterly Achievement Rate',
        'trend': trendPercentage,
        'direction': trendPercentage >= 0 ? 'up' : 'down',
      });
    }
  }

  // Financial Analytics Methods
  void analyzeFinancialData(Financial financial) {
    // Reset metrics
    _financialMetrics = {};
    _revenueStreams = {};
    _financialTrends = [];

    // Calculate financial metrics
    _financialMetrics['totalIncome'] = financial.totalIncome;
    _financialMetrics['totalExpenses'] = financial.totalExpenses;
    _financialMetrics['balance'] = financial.balance;

    // Calculate revenue streams
    for (var sponsorship in financial.sponsorships) {
      _revenueStreams['sponsorships'] = _revenueStreams['sponsorships'] ?? [];
      _revenueStreams['sponsorships']!.add(sponsorship.amount);
    }

    for (var grant in financial.grants) {
      _revenueStreams['grants'] = _revenueStreams['grants'] ?? [];
      _revenueStreams['grants']!.add(grant.amount);
    }

    // Calculate financial trends
    _calculateFinancialTrends(financial);

    notifyListeners();
  }

  void _calculateFinancialTrends(Financial financial) {
    // Sort transactions by date
    final sortedTransactions = List<Transaction>.from(financial.transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate monthly income/expense
    final monthlyMetrics = <String, Map<String, double>>{};
    for (var transaction in sortedTransactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      monthlyMetrics[monthKey] = monthlyMetrics[monthKey] ?? {
        'income': 0,
        'expenses': 0,
      };

      if (transaction.amount > 0) {
        monthlyMetrics[monthKey]!['income'] =
            (monthlyMetrics[monthKey]!['income'] ?? 0) + transaction.amount;
      } else {
        monthlyMetrics[monthKey]!['expenses'] =
            (monthlyMetrics[monthKey]!['expenses'] ?? 0) +
                transaction.amount.abs();
      }
    }

    // Calculate trends
    if (monthlyMetrics.length >= 2) {
      final months = monthlyMetrics.values.toList();
      final firstMonth = months.first;
      final lastMonth = months.last;

      for (var metric in ['income', 'expenses']) {
        final firstValue = firstMonth[metric] ?? 0;
        final lastValue = lastMonth[metric] ?? 0;
        final trendPercentage = ((lastValue - firstValue) / firstValue) * 100;

        _financialTrends.add({
          'metric': 'Monthly $metric',
          'trend': trendPercentage,
          'direction': metric == 'income'
              ? (trendPercentage >= 0 ? 'up' : 'down')
              : (trendPercentage <= 0 ? 'up' : 'down'),
        });
      }
    }
  }
}

// Extension for easy access in widgets
extension AnalyticsProviderExtension on BuildContext {
  AnalyticsProvider get analyticsProvider =>
      Provider.of<AnalyticsProvider>(this, listen: false);
}

// Extension for DateTime
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstWeekday = firstDayOfYear.subtract(Duration(days: daysOffset));
    final difference = difference(firstWeekday);
    return (difference.inDays / 7).ceil();
  }
}