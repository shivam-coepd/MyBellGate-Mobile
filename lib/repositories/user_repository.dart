import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/services/api_service.dart';

class UserRepository {
  static const String _userBoxName = 'users';
  static const String _currentUserKey = 'current_user';

  late Box<User> _userBox;
  final ApiService _apiService = ApiService();

  Future<void> init() async {
    _userBox = await Hive.openBox<User>(_userBoxName);
  }

  Future<void> saveUser(User user) async {
    await _userBox.put(user.id, user);
  }

  User? getCurrentUser() {
    return _userBox.get(_currentUserKey);
  }

  Future<void> setCurrentUser(User user) async {
    await saveUser(user);
    await _userBox.put(_currentUserKey, user);
  }

  Future<void> clearCurrentUser() async {
    await _userBox.delete(_currentUserKey);
  }

  Future<void> logout() async {
    await clearCurrentUser();
    await AppConfig.setToken(null);
  }

  Future<User?> login(String phone, String password, {String? role}) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {
          'phone': phone, 
          'password': password,
          if (role != null) 'role': role,
        },
      );

      log("User Login Raw Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        final responseData = response.data['data'];
        final token = responseData['token'];
        await AppConfig.setToken(token);

        // Parse user directly from login response — it already includes
        // resident_data with flats, family_members, vehicles, pets etc.
        final userData = responseData['user'] as Map<String, dynamic>;
        log("User Login Parsed userData: $userData");

        final user = User.fromJson(userData);
        await setCurrentUser(user);
        log("User Login Success: ${user.name} (${user.role})");
        return user;
      } else {
        throw Exception(response.data?['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<User?> register({
    required String name,
    required String phone,
    required String email,
    required String societyId,
    required String unit,
    required String role,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'society_id': int.tryParse(societyId) ?? societyId,
          'role': role,
          'password': password,
        },
      );

      log("User Register Raw Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        final responseData = response.data['data'];
        final token = responseData['token'];
        await AppConfig.setToken(token);

        // Parse user directly from register response if available
        if (responseData['user'] != null) {
          final userData = responseData['user'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          await setCurrentUser(user);
          return user;
        } else {
          // Construct basic user from registration details as fallback
          final user = User(
            id: responseData['user_id']?.toString() ?? '',
            name: name,
            email: email,
            phone: phone,
            unit: unit,
            societyId: societyId,
            role: role,
            isApproved: role == 'resident' ? false : true,
          );
          await setCurrentUser(user);
          return user;
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<User?> getProfile() async {
    try {
      final response = await _apiService.dio.get('/users/profile');
      log("Get Profile Raw Response: ${response.data}");
      if (response.data != null && response.data['status'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        await setCurrentUser(user);
        return user;
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch profile');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.data != null && response.data['status'] == true) {
        return;
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<User?> updateProfile({
    String? name,
    String? email,
    String? profileImage,
    String? coverImageUrl,
    String? residentType,
    String? bio,
    String? profession,
    String? hometown,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (profileImage != null) data['profile_image'] = profileImage;
      if (coverImageUrl != null) data['cover_image_url'] = coverImageUrl;
      if (residentType != null) data['resident_type'] = residentType;
      if (bio != null) data['bio'] = bio;
      if (profession != null) data['profession'] = profession;
      if (hometown != null) data['hometown'] = hometown;

      final response = await _apiService.dio.put(
        '/users/profile',
        data: data,
      );

      log("Update Profile Raw Response: ${response.data}");

      if (response.data != null && response.data['status'] == true) {
        return await getProfile();
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(message);
    }
  }
}
