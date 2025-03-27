import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/performance_data.dart';
import '../models/injury.dart';
import '../models/career.dart';
import '../models/financial.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService;
  final FirebaseService _firebaseService;

  UserModel? _currentUser;
  List<PerformanceData> _performanceData = [];
  List<Injury> _injuries = [];
  Career? _career;
  Financial? _financial;
  bool _isLoading = false;
  String? _error;

  UserProvider({
    required AuthService authService,
    required FirebaseService firebaseService,
  })  : _authService = authService,
        _firebaseService = firebaseService {
    _initializeUser();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  List<PerformanceData> get performanceData => _performanceData;
  List<Injury> get injuries => _injuries;
  Career? get career => _career;
  Financial? get financial => _financial;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialize user data
  Future<void> _initializeUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
    }
  }

  // Load user data
  Future<void> _loadUserData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Set up stream subscriptions
      _firebaseService.getUserStream(userId).listen(
        (user) {
          _currentUser = user;
          notifyListeners();
        },
        onError: (error) => _setError(error.toString()),
      );

      _firebaseService.getPerformanceStream(userId).listen(
        (data) {
          _performanceData = data;
          notifyListeners();
        },
        onError: (error) => _setError(error.toString()),
      );

      _firebaseService.getInjuriesStream(userId).listen(
        (data) {
          _injuries = data;
          notifyListeners();
        },
        onError: (error) => _setError(error.toString()),
      );

      _firebaseService.getCareerStream(userId).listen(
        (data) {
          _career = data;
          notifyListeners();
        },
        onError: (error) => _setError(error.toString()),
      );

      _firebaseService.getFinancialStream(userId).listen(
        (data) {
          _financial = data;
          notifyListeners();
        },
        onError: (error) => _setError(error.toString()),
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      await _loadUserData(user.id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String sport,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        age: age,
        gender: gender,
        sport: sport,
      );
      await _loadUserData(user.id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _clearUserData();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.updateUser(updatedUser);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add performance data
  Future<void> addPerformanceData(PerformanceData data) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.addPerformanceData(data);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add injury
  Future<void> addInjury(Injury injury) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.addInjury(injury);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update career
  Future<void> updateCareer(Career career) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.updateCareer(career);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update financial
  Future<void> updateFinancial(Financial financial) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.updateFinancial(financial);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount(password);
      _clearUserData();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  void _clearUserData() {
    _currentUser = null;
    _performanceData = [];
    _injuries = [];
    _career = null;
    _financial = null;
    notifyListeners();
  }

  // Performance analytics
  double getAveragePerformanceScore() {
    if (_performanceData.isEmpty) return 0;
    final scores = _performanceData.map((data) => data.calculateIntensityScore());
    return scores.reduce((a, b) => a + b) / _performanceData.length;
  }

  // Injury statistics
  int get activeInjuriesCount =>
      _injuries.where((injury) => injury.status == InjuryStatus.active).length;

  // Career progress
  double get careerProgress => _career?.calculateProgressPercentage() ?? 0;

  // Financial summary
  double get totalIncome => _financial?.totalIncome ?? 0;
  double get totalExpenses => _financial?.totalExpenses ?? 0;
  double get balance => _financial?.balance ?? 0;
}