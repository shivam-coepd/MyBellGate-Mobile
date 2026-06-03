import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/services/api_service.dart';

class GuardRepository {
  final ApiService _apiService;

  GuardRepository() : _apiService = ApiService();

  // ─── Visitors ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getVisitors({
    String? status,
    String? visitorType,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) params['status'] = status;
      if (visitorType != null) params['visitor_type'] = visitorType;

      final response = await _apiService.dio.get(
        '/api/visitors',
        queryParameters: params,
      );

      if (response.data['status'] == true) {
        final data = response.data['data'];
        final List raw = data is Map ? (data['data'] ?? []) : data;
        return raw.map((v) => Map<String, dynamic>.from(v)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load visitors');
    } on DioException catch (e) {
      log('getVisitors DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<Map<String, dynamic>?> getVisitorById(int id) async {
    try {
      final response = await _apiService.dio.get('/api/visitors/$id');
      if (response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      log('getVisitorById DioError: $e');
      throw Exception(_extractError(e));
    }
  }

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
    int? residentId,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'phone': phone,
        'purpose': purpose,
        'visit_date': visitDate ?? _today(),
        'visit_time': visitTime ?? _nowTime(),
        'visitor_type': visitorType ?? 'guest',
      };
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (expectedExitTime != null) body['expected_exit_time'] = expectedExitTime;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (residentId != null) body['resident_id'] = residentId;

      final response = await _apiService.dio.post('/api/visitors', data: body);

      if (response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data'] ?? {});
      }
      throw Exception(response.data['message'] ?? 'Failed to add visitor');
    } on DioException catch (e) {
      log('addVisitor DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<void> updateVisitorStatus(int id, String status) async {
    try {
      final response = await _apiService.dio.put(
        '/api/visitors/$id/status',
        data: {'status': status},
      );
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } on DioException catch (e) {
      log('updateVisitorStatus DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  // ─── Security Alerts ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSecurityAlerts({
    String? status,
    String? severity,
    String? alertType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) params['status'] = status;
      if (severity != null) params['severity'] = severity;
      if (alertType != null) params['alert_type'] = alertType;

      final response = await _apiService.dio.get(
        '/api/security/alerts',
        queryParameters: params,
      );

      if (response.data['status'] == true) {
        final data = response.data['data'];
        final List raw = data is Map ? (data['data'] ?? []) : data;
        return raw.map((a) => Map<String, dynamic>.from(a)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load alerts');
    } on DioException catch (e) {
      log('getSecurityAlerts DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<Map<String, dynamic>> reportSecurityAlert({
    required String alertType,
    required String description,
    String severity = 'medium',
    String? imageUrl,
    String? location,
  }) async {
    try {
      final body = <String, dynamic>{
        'alert_type': alertType,
        'description': description,
        'severity': severity,
      };
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (location != null) body['location'] = location;

      final response = await _apiService.dio.post(
        '/api/security/alerts',
        data: body,
      );

      if (response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data'] ?? {});
      }
      throw Exception(response.data['message'] ?? 'Failed to report alert');
    } on DioException catch (e) {
      log('reportSecurityAlert DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<void> updateAlertStatus(int id, String status) async {
    try {
      final response = await _apiService.dio.put(
        '/api/security/alerts/$id/status',
        data: {'status': status},
      );
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update alert');
      }
    } on DioException catch (e) {
      log('updateAlertStatus DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  // ─── Emergency Contacts ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getEmergencyContacts({
    String? contactType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (contactType != null) params['contact_type'] = contactType;

      final response = await _apiService.dio.get(
        '/api/security/emergency-contacts',
        queryParameters: params,
      );

      if (response.data['status'] == true) {
        final data = response.data['data'];
        final List raw = data is Map ? (data['data'] ?? []) : data;
        return raw.map((c) => Map<String, dynamic>.from(c)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load contacts');
    } on DioException catch (e) {
      log('getEmergencyContacts DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  // ─── Residents (guard lookup) ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getResidents({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _apiService.dio.get(
        '/api/guard/residents',
        queryParameters: params,
      );

      if (response.data['status'] == true) {
        final data = response.data['data'];
        final List raw = data is Map ? (data['data'] ?? []) : data;
        return raw.map((r) => Map<String, dynamic>.from(r)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load residents');
    } on DioException catch (e) {
      log('getResidents DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  // ─── Vehicle Entries (guard gate log) ────────────────────────────────────

  Future<List<Map<String, dynamic>>> getVehicleEntries({
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) params['status'] = status;

      final response = await _apiService.dio.get(
        '/api/guard/vehicle-entries',
        queryParameters: params,
      );

      if (response.data['status'] == true) {
        final data = response.data['data'];
        final List raw = data is Map ? (data['data'] ?? []) : data;
        return raw.map((v) => Map<String, dynamic>.from(v)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load vehicle entries');
    } on DioException catch (e) {
      log('getVehicleEntries DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<Map<String, dynamic>> addVehicleEntry({
    required String vehicleType,
    required String vehicleNumber,
    required String driverName,
    required String driverPhone,
    required String purpose,
    int? residentId,
  }) async {
    try {
      final body = <String, dynamic>{
        'vehicle_type': vehicleType,
        'vehicle_number': vehicleNumber,
        'driver_name': driverName,
        'driver_phone': driverPhone,
        'purpose': purpose,
      };
      if (residentId != null) body['resident_id'] = residentId;

      final response = await _apiService.dio.post(
        '/api/guard/vehicle-entries',
        data: body,
      );

      if (response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data'] ?? {});
      }
      throw Exception(response.data['message'] ?? 'Failed to add vehicle entry');
    } on DioException catch (e) {
      log('addVehicleEntry DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<void> updateVehicleEntryStatus(int id, String status) async {
    try {
      final response = await _apiService.dio.put(
        '/api/guard/vehicle-entries/$id/status',
        data: {'status': status},
      );
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update vehicle entry');
      }
    } on DioException catch (e) {
      log('updateVehicleEntryStatus DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  // ─── Guard Attendance ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getGuardAttendance() async {
    try {
      final response = await _apiService.dio.get('/api/guard/attendance');

      if (response.data['status'] == true) {
        return Map<String, dynamic>.from(response.data['data'] ?? {});
      }
      throw Exception(response.data['message'] ?? 'Failed to load attendance');
    } on DioException catch (e) {
      log('getGuardAttendance DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  Future<void> markAttendance(String type) async {
    try {
      final response = await _apiService.dio.post(
        '/api/guard/attendance/mark',
        data: {'type': type},
      );
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to mark attendance');
      }
    } on DioException catch (e) {
      log('markAttendance DioError: $e');
      throw Exception(_extractError(e));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00';
  }

  String _extractError(DioException e) {
    try {
      return e.response?.data?['message'] ?? e.message ?? 'Network error';
    } catch (_) {
      return e.message ?? 'Network error';
    }
  }
}
