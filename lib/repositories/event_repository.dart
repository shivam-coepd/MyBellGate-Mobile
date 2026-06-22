import 'package:dio/dio.dart';
import 'package:mygate_coepd/services/api_service.dart';

class EventRepository {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final response = await _apiService.dio.get('/events');
      if (response.data != null && response.data['status'] == true) {
        final List<dynamic> data = response.data['data']['events'] ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception(response.data?['message'] ?? 'Failed to load events');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.dio.post(
        '/events',
        data: eventData,
      );
      if (response.data != null && response.data['status'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data?['message'] ?? 'Failed to create event');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<void> updateEvent(int eventId, Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.dio.put(
        '/events/$eventId',
        data: eventData,
      );
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to update event');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      final response = await _apiService.dio.delete('/events/$eventId');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to delete event');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<Map<String, dynamic>> rsvpEvent(int eventId, String status) async {
    try {
      final response = await _apiService.dio.post(
        '/events/$eventId/rsvp',
        data: {'status': status},
      );
      if (response.data != null && response.data['status'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data?['message'] ?? 'Failed to RSVP');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }
}
