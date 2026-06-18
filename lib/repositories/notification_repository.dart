import 'package:dio/dio.dart';
import 'package:mygate_coepd/models/notification_model.dart';
import 'package:mygate_coepd/services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        final List<dynamic> notificationsData = data['notifications'] ?? [];
        final notifications = notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        return {
          'notifications': notifications,
          'unread_count': data['unread_count'] ?? 0,
          'total': data['total'] ?? 0,
          'has_more': data['has_more'] ?? false,
        };
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch notifications');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await _apiService.dio.put('/notifications/$id/read');

      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to mark as read');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.dio.put('/notifications/read-all');

      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to mark all as read');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.dio.get('/notifications/unread-count');

      if (response.data != null && response.data['status'] == true) {
        return response.data['data']['count'] ?? 0;
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to get unread count');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }
}
