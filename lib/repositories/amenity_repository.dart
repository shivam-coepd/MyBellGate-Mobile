import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/models/amenity.dart';
import 'package:mygate_coepd/services/api_service.dart';

class AmenityRepository {
  final ApiService _apiService = ApiService();

  // ── Amenities ─────────────────────────────────────────────────────────────

  Future<List<Amenity>> getAmenities({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.dio.get(
        '/amenities',
        queryParameters: {'page': page, 'limit': limit, 'is_active': 1},
      );
      log('Get Amenities: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => Amenity.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load amenities');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  Future<AmenityBooking> bookAmenity({
    required String amenityId,
    required String bookingDate,
    required String startTime, // HH:MM:SS
    required String endTime,   // HH:MM:SS
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/amenities/$amenityId/book',
        data: {
          'booking_date': bookingDate,
          'start_time': startTime,
          'end_time': endTime,
        },
      );
      log('Book Amenity: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        // Return a minimal booking constructed from returned id
        return AmenityBooking(
          id: data['booking_id'].toString(),
          amenityId: amenityId,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
          status: 'requested',
        );
      }
      throw Exception(response.data?['message'] ?? 'Failed to book amenity');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<List<AmenityBooking>> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'limit': limit};
      if (status != null) params['status'] = status;

      final response = await _apiService.dio.get(
        '/amenities/bookings',
        queryParameters: params,
      );
      log('Get Bookings: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        var rawData = response.data['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((e) => AmenityBooking.fromJson(e)).toList();
      }
      throw Exception(response.data?['message'] ?? 'Failed to load bookings');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }
}
