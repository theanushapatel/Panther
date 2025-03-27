import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

enum NavigationItem {
  dashboard,
  performance,
  injuries,
  career,
  financial,
  settings,
}

class NavigationProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  // State
  NavigationItem _currentItem = NavigationItem.dashboard;
  List<NavigationItem> _navigationHistory = [];
  Map<NavigationItem, int> _visitCount = {};
  DateTime? _lastVisitTime;
  String? _error;

  // Constants
  static const String _lastItemKey = 'last_navigation_item';
  static const String _visitCountKey = 'navigation_visit_count';
  static const int _maxHistoryLength = 10;

  NavigationProvider(this._prefs) {
    _loadNavigationState();
  }

  // Getters
  NavigationItem get currentItem => _currentItem;
  List<NavigationItem> get navigationHistory => _navigationHistory;
  Map<NavigationItem, int> get visitCount => _visitCount;
  DateTime? get lastVisitTime => _lastVisitTime;
  String? get error => _error;

  // Load navigation state
  void _loadNavigationState() {
    try {
      // Load last visited item
      final lastItem = _prefs.getString(_lastItemKey);
      if (lastItem != null) {
        _currentItem = NavigationItem.values.firstWhere(
          (item) => item.toString() == lastItem,
          orElse: () => NavigationItem.dashboard,
        );
      }

      // Load visit counts
      final visitCountData = _prefs.getString(_visitCountKey);
      if (visitCountData != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          Map<String, dynamic>.from(visitCountData as Map),
        );
        _visitCount = data.map(
          (key, value) => MapEntry(
            NavigationItem.values.firstWhere(
              (item) => item.toString() == key,
            ),
            value as int,
          ),
        );
      }
    } catch (e) {
      _setError('Failed to load navigation state: $e');
    }
  }

  // Save navigation state
  Future<void> _saveNavigationState() async {
    try {
      await _prefs.setString(_lastItemKey, _currentItem.toString());
      
      final visitCountData = _visitCount.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await _prefs.setString(_visitCountKey, visitCountData.toString());
    } catch (e) {
      _setError('Failed to save navigation state: $e');
    }
  }

  // Navigate to item
  Future<void> navigateTo(NavigationItem item) async {
    if (_currentItem != item) {
      _navigationHistory.insert(0, _currentItem);
      if (_navigationHistory.length > _maxHistoryLength) {
        _navigationHistory.removeLast();
      }

      _currentItem = item;
      _visitCount[item] = (_visitCount[item] ?? 0) + 1;
      _lastVisitTime = DateTime.now();

      await _saveNavigationState();
      notifyListeners();
    }
  }

  // Get route name for navigation item
  String getRouteName(NavigationItem item) {
    switch (item) {
      case NavigationItem.dashboard:
        return '/dashboard';
      case NavigationItem.performance:
        return '/performance';
      case NavigationItem.injuries:
        return '/injuries';
      case NavigationItem.career:
        return '/career';
      case NavigationItem.financial:
        return '/financial';
      case NavigationItem.settings:
        return '/settings';
    }
  }

  // Get icon for navigation item
  IconData getIcon(NavigationItem item) {
    switch (item) {
      case NavigationItem.dashboard:
        return Icons.dashboard;
      case NavigationItem.performance:
        return Icons.trending_up;
      case NavigationItem.injuries:
        return Icons.healing;
      case NavigationItem.career:
        return Icons.work;
      case NavigationItem.financial:
        return Icons.account_balance_wallet;
      case NavigationItem.settings:
        return Icons.settings;
    }
  }

  // Get title for navigation item
  String getTitle(NavigationItem item) {
    switch (item) {
      case NavigationItem.dashboard:
        return 'Dashboard';
      case NavigationItem.performance:
        return 'Performance';
      case NavigationItem.injuries:
        return 'Injuries';
      case NavigationItem.career:
        return 'Career';
      case NavigationItem.financial:
        return 'Financial';
      case NavigationItem.settings:
        return 'Settings';
    }
  }

  // Navigate back
  bool canNavigateBack() => _navigationHistory.isNotEmpty;

  Future<bool> navigateBack() async {
    if (canNavigateBack()) {
      final previousItem = _navigationHistory.removeAt(0);
      _currentItem = previousItem;
      _lastVisitTime = DateTime.now();
      
      await _saveNavigationState();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Clear navigation history
  Future<void> clearHistory() async {
    _navigationHistory.clear();
    notifyListeners();
  }

  // Reset visit counts
  Future<void> resetVisitCounts() async {
    _visitCount.clear();
    await _saveNavigationState();
    notifyListeners();
  }

  // Get most visited items
  List<NavigationItem> getMostVisitedItems({int limit = 3}) {
    return _visitCount.entries
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(limit)
        .map((e) => e.key)
        .toList();
  }

  // Check if item is active
  bool isActive(NavigationItem item) => _currentItem == item;

  // Get previous item
  NavigationItem? getPreviousItem() {
    return _navigationHistory.isNotEmpty ? _navigationHistory.first : null;
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
extension NavigationProviderExtension on BuildContext {
  NavigationProvider get navigationProvider =>
      Provider.of<NavigationProvider>(this, listen: false);
}

// Extension for sorting map entries
extension SortedMapEntries<K, V extends Comparable> on Iterable<MapEntry<K, V>> {
  List<MapEntry<K, V>> sorted([Comparator<MapEntry<K, V>>? compare]) {
    final list = toList();
    list.sort(compare);
    return list;
  }
}

// Mixin for handling navigation in widgets
mixin NavigationHandler<T extends StatefulWidget> on State<T> {
  Future<bool> handleBackNavigation() async {
    final provider = context.navigationProvider;
    return provider.canNavigateBack() ? provider.navigateBack() : false;
  }

  void navigateToItem(NavigationItem item) {
    context.navigationProvider.navigateTo(item);
  }
}