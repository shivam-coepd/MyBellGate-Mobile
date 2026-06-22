import 'package:dio/dio.dart';
import 'package:mygate_coepd/models/community_post.dart';
import 'package:mygate_coepd/models/marketplace_item.dart';
import 'package:mygate_coepd/services/api_service.dart';

class CommunityRepository {
  final ApiService _apiService = ApiService();

  Future<List<CommunityPost>> getPosts({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.dio.get(
        '/community/posts',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => CommunityPost.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load posts');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<void> createPost(String content, {String? image}) async {
    try {
      final response = await _apiService.dio.post(
        '/community/posts',
        data: {'content': content, if (image != null) 'image': image},
      );
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to create post');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<void> likePost(int postId) async {
    try {
      final response = await _apiService.dio.post(
        '/community/posts/$postId/like',
      );
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to like post');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final response = await _apiService.dio.delete('/community/posts/$postId');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to delete post');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<List<MarketplaceItem>> getMarketplaceItems() async {
    try {
      final response = await _apiService.dio.get('/marketplace/products');
      if (response.data != null && response.data['status'] == true) {
        final List<dynamic> data = response.data['data'] is List
            ? response.data['data']
            : [];
        return data.map((e) => MarketplaceItem.fromJson(e)).toList();
      }
      throw Exception(
        response.data?['message'] ?? 'Failed to load marketplace items',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getComments(int postId) async {
    try {
      final response = await _apiService.dio.get(
        '/community/posts/$postId/comments',
      );
      if (response.data != null && response.data['status'] == true) {
        final List<dynamic> data = response.data['data']['comments'] ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception(response.data?['message'] ?? 'Failed to load comments');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  Future<Map<String, dynamic>> commentOnPost(int postId, String content) async {
    try {
      final response = await _apiService.dio.post(
        '/community/posts/$postId/comments',
        data: {'content': content},
      );
      if (response.data != null && response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data']['comment']);
      }
      throw Exception(response.data?['message'] ?? 'Failed to add comment');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
