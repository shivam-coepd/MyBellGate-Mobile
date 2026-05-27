import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/models/announcement.dart';
import 'package:mygate_coepd/services/api_service.dart';

class CommunicationsRepository {
  final ApiService _apiService = ApiService();

  // ── Announcements ─────────────────────────────────────────────────────────

  Future<List<Announcement>> getAnnouncements({
    int page = 1,
    int limit = 20,
    bool? isDraft,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'limit': limit};
      if (isDraft != null) params['is_draft'] = isDraft ? 1 : 0;

      final response = await _apiService.dio.get(
        '/communications/announcements',
        queryParameters: params,
      );
      log('Get Announcements: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => Announcement.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load announcements');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── Polls ─────────────────────────────────────────────────────────────────

  Future<List<Poll>> getPolls({
    int page = 1,
    int limit = 20,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'limit': limit};
      if (isActive != null) params['is_active'] = isActive ? 1 : 0;

      final response = await _apiService.dio.get(
        '/communications/polls',
        queryParameters: params,
      );
      log('Get Polls: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => Poll.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load polls');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<void> voteOnPoll(String pollId, String optionId) async {
    try {
      final response = await _apiService.dio.post(
        '/communications/polls/$pollId/vote',
        data: {'option_id': optionId},
      );
      log('Vote Poll: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to cast vote');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── Groups ────────────────────────────────────────────────────────────────

  Future<void> joinGroup(String groupId) async {
    try {
      final response = await _apiService.dio.post(
        '/communications/groups/$groupId/join',
      );
      log('Join Group: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to join group');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      final response = await _apiService.dio.post(
        '/communications/groups/$groupId/leave',
      );
      log('Leave Group: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to leave group');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }
}
