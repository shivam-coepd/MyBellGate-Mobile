import 'package:hive/hive.dart';
import 'package:mygate_coepd/models/user.dart';

class UserRepository {
  static const String _userBoxName = 'users';
  static const String _currentUserKey = 'current_user';

  late Box<User> _userBox;

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
  }

  Future<User?> login(String phone, String otp) async {
    // In a real app, this would call an API
    // For now, we'll simulate a successful login
    final user = User(
      id: '123',
      name: 'John Doe',
      email: 'john@example.com',
      phone: phone,
      unit: 'A-101',
      societyId: 'SOC12345',
      role: 'resident',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
      biometricEnabled: false,
      isApproved: true,
      points: 0,
    );

    await setCurrentUser(user);
    return user;
  }

  Future<User?> register({
    required String name,
    required String phone,
    required String email,
    required String societyId,
    required String unit,
    required String role,
  }) async {
    // In a real app, this would call an API
    // For now, we'll simulate a successful registration
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      unit: unit,
      societyId: societyId,
      role: role,
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
      biometricEnabled: false,
      isApproved: role == 'resident' ? false : true,
      points: 0,
    );

    await setCurrentUser(user);
    return user;
  }
}