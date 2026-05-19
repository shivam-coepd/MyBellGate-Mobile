import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyRememberDevice = 'remember_device';
  static const String _keySelectedRole = 'selected_role';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static bool get isOnboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // Remember Device
  static bool get rememberDevice =>
      _prefs.getBool(_keyRememberDevice) ?? false;

  static Future<void> setRememberDevice(bool value) async {
    await _prefs.setBool(_keyRememberDevice, value);
  }

  // Selected Role
  static String? get selectedRole => _prefs.getString(_keySelectedRole);

  static Future<void> setSelectedRole(String? role) async {
    if (role == null) {
      await _prefs.remove(_keySelectedRole);
    } else {
      await _prefs.setString(_keySelectedRole, role);
    }
  }
}