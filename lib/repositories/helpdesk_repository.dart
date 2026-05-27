import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/models/ticket.dart';
import 'package:mygate_coepd/services/api_service.dart';

class HelpdeskRepository {
  final ApiService _apiService = ApiService();

  // ── Tickets ───────────────────────────────────────────────────────────────

  Future<List<Ticket>> getTickets({
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
    String? priority,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'limit': limit};
      if (status != null) params['status'] = status;
      if (category != null) params['category'] = category;
      if (priority != null) params['priority'] = priority;

      final response = await _apiService.dio.get(
        '/helpdesk/tickets',
        queryParameters: params,
      );
      log('Get Tickets: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => Ticket.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load tickets');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<Ticket> getTicketById(String id) async {
    try {
      final response = await _apiService.dio.get('/helpdesk/tickets/$id');
      log('Get Ticket $id: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        return Ticket.fromJson(response.data['data']);
      }
      throw Exception(response.data?['message'] ?? 'Failed to load ticket');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<String> createTicket({
    required String title,
    required String description,
    String category = 'general',
    String priority = 'medium',
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/helpdesk/tickets',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
        },
      );
      log('Create Ticket: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        return response.data['data']['ticket_id'].toString();
      }
      throw Exception(response.data?['message'] ?? 'Failed to create ticket');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<void> updateTicketStatus(String id, String status) async {
    try {
      final response = await _apiService.dio.patch(
        '/helpdesk/tickets/$id/status',
        data: {'status': status},
      );
      log('Update Ticket Status: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to update status');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<String> addComment(String ticketId, String comment) async {
    try {
      final response = await _apiService.dio.post(
        '/helpdesk/tickets/$ticketId/comments',
        data: {'comment': comment},
      );
      log('Add Comment: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        return response.data['data']['comment_id'].toString();
      }
      throw Exception(response.data?['message'] ?? 'Failed to add comment');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }
}
