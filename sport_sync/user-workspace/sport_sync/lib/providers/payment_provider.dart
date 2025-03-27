import 'package:flutter/material.dart';
import '../models/financial.dart';
import '../services/payment_service.dart';
import '../services/firebase_service.dart';

enum PaymentProcessingStatus {
  idle,
  processing,
  completed,
  failed,
}

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService;
  final FirebaseService _firebaseService;

  // State
  PaymentProcessingStatus _status = PaymentProcessingStatus.idle;
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Transaction> _recentTransactions = [];
  Map<String, dynamic>? _activePaymentIntent;
  String? _error;
  bool _isLoading = false;

  PaymentProvider({
    required PaymentService paymentService,
    required FirebaseService firebaseService,
  })  : _paymentService = paymentService,
        _firebaseService = firebaseService;

  // Getters
  PaymentProcessingStatus get status => _status;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  List<Transaction> get recentTransactions => _recentTransactions;
  Map<String, dynamic>? get activePaymentIntent => _activePaymentIntent;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Process payment
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    if (_status == PaymentProcessingStatus.processing) {
      throw Exception('Payment already in progress');
    }

    _setStatus(PaymentProcessingStatus.processing);
    _setLoading(true);

    try {
      final result = await _paymentService.processPayment(
        userId: userId,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        metadata: metadata,
      );

      _setStatus(PaymentProcessingStatus.completed);
      await _updateTransactionHistory(userId);
      return result;
    } catch (e) {
      _setError('Failed to process payment: $e');
      _setStatus(PaymentProcessingStatus.failed);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String userId,
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);

    try {
      final intent = await _paymentService.createPaymentIntent(
        userId: userId,
        amount: amount,
        currency: currency,
        metadata: metadata,
      );
      _activePaymentIntent = intent;
      return intent;
    } catch (e) {
      _setError('Failed to create payment intent: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Process refund
  Future<Map<String, dynamic>> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    _setLoading(true);

    try {
      final result = await _paymentService.processRefund(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );
      await _updateTransactionHistory(null);
      return result;
    } catch (e) {
      _setError('Failed to process refund: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Process sponsorship payment
  Future<Map<String, dynamic>> processSponsorshipPayment({
    required String userId,
    required Sponsorship sponsorship,
    required Map<String, dynamic> paymentMethod,
  }) async {
    _setLoading(true);

    try {
      final result = await _paymentService.processSponsorshipPayment(
        userId: userId,
        sponsorship: sponsorship,
        paymentMethod: paymentMethod,
      );
      await _updateFinancialData(userId);
      return result;
    } catch (e) {
      _setError('Failed to process sponsorship payment: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Process grant disbursement
  Future<Map<String, dynamic>> processGrantDisbursement({
    required String userId,
    required Grant grant,
    required Map<String, dynamic> bankDetails,
  }) async {
    _setLoading(true);

    try {
      final result = await _paymentService.processGrantDisbursement(
        userId: userId,
        grant: grant,
        bankDetails: bankDetails,
      );
      await _updateFinancialData(userId);
      return result;
    } catch (e) {
      _setError('Failed to process grant disbursement: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Load payment methods
  Future<void> loadPaymentMethods(String userId) async {
    _setLoading(true);

    try {
      _paymentMethods = await _paymentService.getPaymentMethods(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment methods: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add payment method
  Future<void> addPaymentMethod({
    required String userId,
    required Map<String, dynamic> paymentMethod,
  }) async {
    _setLoading(true);

    try {
      await _paymentService.addPaymentMethod(
        userId: userId,
        paymentMethod: paymentMethod,
      );
      await loadPaymentMethods(userId);
    } catch (e) {
      _setError('Failed to add payment method: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Remove payment method
  Future<void> removePaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    _setLoading(true);

    try {
      await _paymentService.removePaymentMethod(
        userId: userId,
        paymentMethodId: paymentMethodId,
      );
      await loadPaymentMethods(userId);
    } catch (e) {
      _setError('Failed to remove payment method: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update transaction history
  Future<void> _updateTransactionHistory(String? userId) async {
    if (userId == null) return;

    try {
      _recentTransactions = await _paymentService.getTransactionHistory(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to update transaction history: $e');
    }
  }

  // Update financial data in Firebase
  Future<void> _updateFinancialData(String userId) async {
    try {
      final financial = await _firebaseService.getFinancialStream(userId).first;
      if (financial != null) {
        await _firebaseService.updateFinancial(financial);
      }
    } catch (e) {
      _setError('Failed to update financial data: $e');
    }
  }

  // Get payment status
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      return await _paymentService.getPaymentStatus(paymentId);
    } catch (e) {
      _setError('Failed to get payment status: $e');
      rethrow;
    }
  }

  // Helper methods
  void _setStatus(PaymentProcessingStatus status) {
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

  // Analytics methods
  double getTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.amount > 0)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  Map<String, double> getCategoryBreakdown(List<Transaction> transactions) {
    final breakdown = <String, double>{};
    for (var transaction in transactions) {
      if (transaction.category != null) {
        breakdown[transaction.category!] =
            (breakdown[transaction.category!] ?? 0) + transaction.amount.abs();
      }
    }
    return breakdown;
  }
}

// Extension for easy access in widgets
extension PaymentProviderExtension on BuildContext {
  PaymentProvider get paymentProvider =>
      Provider.of<PaymentProvider>(this, listen: false);
}