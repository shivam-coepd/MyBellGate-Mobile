import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/models/invoice.dart';
import 'package:mygate_coepd/services/api_service.dart';

class AccountingRepository {
  final ApiService _apiService = ApiService();

  // ── Invoices ──────────────────────────────────────────────────────────────

  Future<List<Invoice>> getInvoices({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'limit': limit};
      if (status != null) params['status'] = status;

      final response = await _apiService.dio.get(
        '/accounting/invoices',
        queryParameters: params,
      );
      log('Get Invoices: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => Invoice.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load invoices');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<Invoice> getInvoiceById(String id) async {
    try {
      final response = await _apiService.dio.get('/accounting/invoices/$id');
      log('Get Invoice $id: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        return Invoice.fromJson(response.data['data']);
      }
      throw Exception(response.data?['message'] ?? 'Failed to load invoice');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  /// Returns a map with payment_id, receipt_id, payment_reference, receipt_number
  Future<Map<String, dynamic>> processPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'invoice_id': invoiceId,
        'amount': amount,
        'payment_method': paymentMethod,
      };
      if (transactionId != null) data['transaction_id'] = transactionId;
      if (notes != null) data['notes'] = notes;

      final response = await _apiService.dio.post(
        '/accounting/payments',
        data: data,
      );
      log('Process Payment: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data?['message'] ?? 'Payment failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }
}
