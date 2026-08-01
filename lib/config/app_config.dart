import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyRememberDevice = 'remember_device';
  static const String _keySelectedRole = 'selected_role';
  static const String _keyThemeMode = 'theme_mode';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Mode
  static String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';

  static Future<void> setThemeMode(String value) async {
    await _prefs.setString(_keyThemeMode, value);
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

  // Token
  static const String _keyToken = 'auth_token';

  static String? get token => _prefs.getString(_keyToken);

  static Future<void> setToken(String? value) async {
    if (value == null) {
      await _prefs.remove(_keyToken);
    } else {
      await _prefs.setString(_keyToken, value);
    }
  }

  // PIN Lock
  static const String _keyPinLockEnabled = 'pin_lock_enabled';
  static const String _keyAppPin = 'app_pin';

  static bool get pinLockEnabled =>
      _prefs.getBool(_keyPinLockEnabled) ?? false;

  static Future<void> setPinLockEnabled(bool value) async {
    await _prefs.setBool(_keyPinLockEnabled, value);
  }

  static String? get appPin => _prefs.getString(_keyAppPin);

  static Future<void> setAppPin(String? pin) async {
    if (pin == null) {
      await _prefs.remove(_keyAppPin);
    } else {
      await _prefs.setString(_keyAppPin, pin);
    }
  }
}
