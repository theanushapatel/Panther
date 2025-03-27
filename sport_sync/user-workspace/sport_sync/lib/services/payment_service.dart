import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/financial.dart';
import '../utils/constants.dart';

enum PaymentProvider {
  stripe,
  razorpay,
  paypal,
  other
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled
}

class PaymentService {
  final String apiKey;
  final PaymentProvider provider;
  final http.Client _client;
  final String _baseUrl;

  PaymentService({
    required this.apiKey,
    required this.provider,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _baseUrl = _getBaseUrl(provider);

  static String _getBaseUrl(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.stripe:
        return 'https://api.stripe.com/v1';
      case PaymentProvider.razorpay:
        return 'https://api.razorpay.com/v1';
      case PaymentProvider.paypal:
        return 'https://api.paypal.com/v1';
      default:
        return ApiEndpoints.baseUrl + '/payments';
    }
  }

  // Base headers for API requests
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  // Process payment
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/payments'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'currency': currency,
          'paymentMethod': paymentMethod,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to process payment', e);
    }
  }

  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String userId,
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/payment-intents'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'currency': currency,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to create payment intent', e);
    }
  }

  // Process refund
  Future<Map<String, dynamic>> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/refunds'),
        headers: _headers,
        body: jsonEncode({
          'paymentId': paymentId,
          if (amount != null) 'amount': amount,
          if (reason != null) 'reason': reason,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to process refund', e);
    }
  }

  // Get payment status
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: _headers,
      );

      final data = _handleResponse(response);
      return PaymentStatus.values.firstWhere(
        (status) => status.toString() == 'PaymentStatus.${data['status']}',
      );
    } catch (e) {
      throw _handleError('Failed to get payment status', e);
    }
  }

  // Process sponsorship payment
  Future<Map<String, dynamic>> processSponsorshipPayment({
    required String userId,
    required Sponsorship sponsorship,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/sponsorships'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'sponsorship': sponsorship.toJson(),
          'paymentMethod': paymentMethod,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to process sponsorship payment', e);
    }
  }

  // Process grant disbursement
  Future<Map<String, dynamic>> processGrantDisbursement({
    required String userId,
    required Grant grant,
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/grants/disburse'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'grant': grant.toJson(),
          'bankDetails': bankDetails,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to process grant disbursement', e);
    }
  }

  // Get payment methods for user
  Future<List<Map<String, dynamic>>> getPaymentMethods(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/payment-methods').replace(
          queryParameters: {'userId': userId},
        ),
        headers: _headers,
      );

      final List<dynamic> data = _handleResponse(response);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError('Failed to get payment methods', e);
    }
  }

  // Add payment method
  Future<Map<String, dynamic>> addPaymentMethod({
    required String userId,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/payment-methods'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'paymentMethod': paymentMethod,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to add payment method', e);
    }
  }

  // Remove payment method
  Future<void> removePaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/payment-methods/$paymentMethodId').replace(
          queryParameters: {'userId': userId},
        ),
        headers: _headers,
      );

      _handleResponse(response);
    } catch (e) {
      throw _handleError('Failed to remove payment method', e);
    }
  }

  // Get transaction history
  Future<List<Transaction>> getTransactionHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/transactions').replace(
          queryParameters: {
            'userId': userId,
            if (startDate != null)
              'startDate': startDate.toIso8601String(),
            if (endDate != null)
              'endDate': endDate.toIso8601String(),
            if (type != null)
              'type': type.toString().split('.').last,
          },
        ),
        headers: _headers,
      );

      final List<dynamic> data = _handleResponse(response);
      return data.map((item) => Transaction.fromJson(item)).toList();
    } catch (e) {
      throw _handleError('Failed to get transaction history', e);
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    throw Exception(
      'Payment API Error: ${response.statusCode} - ${response.reasonPhrase}\n'
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