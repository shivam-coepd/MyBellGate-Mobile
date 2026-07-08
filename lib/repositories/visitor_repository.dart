import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/services/api_service.dart';

class VisitorRepository {
  final ApiService _apiService = ApiService();

  /// Fetch all visitors with pagination and optional status filter
  Future<List<Map<String, dynamic>>> getVisitors({
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status.toLowerCase();
      }

      final response = await _apiService.dio.get(
        '/visitors',
        queryParameters: queryParameters,
      );

      log("Get Visitors Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        if (data != null && data['data'] != null) {
          final list = List<Map<String, dynamic>>.from(data['data']);
          return list;
        }
        return [];
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch visitors');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  /// Fetch single visitor by ID
  Future<Map<String, dynamic>?> getVisitorById(int id) async {
    try {
      final response = await _apiService.dio.get('/visitors/$id');
      log("Get Visitor By ID ($id) Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch visitor details');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  /// Create/Add a new visitor pre-approval
  Future<Map<String, dynamic>> addVisitor({
    required String name,
    required String phone,
    required String purpose,
    String? email,
    String? visitDate,
    String? visitTime,
    String? expectedExitTime,
    String? visitorType,
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
        'purpose': purpose,
      };

      if (email != null && email.isNotEmpty) data['email'] = email;
      if (visitDate != null && visitDate.isNotEmpty) data['visit_date'] = visitDate;
      if (visitTime != null && visitTime.isNotEmpty) data['visit_time'] = visitTime;
      if (expectedExitTime != null && expectedExitTime.isNotEmpty) {
        data['expected_exit_time'] = expectedExitTime;
      }
      if (visitorType != null && visitorType.isNotEmpty) {
        data['visitor_type'] = visitorType.toLowerCase();
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        data['image_url'] = imageUrl;
      }

      final response = await _apiService.dio.post(
        '/visitors',
        data: data,
      );

      log("Add Visitor Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to add visitor');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  /// Update visitor details
  Future<Map<String, dynamic>> updateVisitor(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put(
        '/visitors/$id',
        data: data,
      );
      log("Update Visitor ($id) Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data']['visitor'] ?? {});
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to update visitor');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  /// Update visitor status (approve/reject for resident, or enter/exit for guard)
  Future<Map<String, dynamic>> updateVisitorStatus(int id, String status) async {
    try {
      final response = await _apiService.dio.put(
        '/visitors/$id/status',
        data: {'status': status.toLowerCase()},
      );
      log("Update Visitor Status ($id, $status) Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data'] ?? {});
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to update visitor status');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }
}
