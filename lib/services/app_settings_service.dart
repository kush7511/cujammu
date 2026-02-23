import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool biometricLoginEnabled;

  const AppSettings({
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.biometricLoginEnabled,
  });

  AppSettings copyWith({
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? biometricLoginEnabled,
  }) {
    return AppSettings(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricLoginEnabled:
          biometricLoginEnabled ?? this.biometricLoginEnabled,
    );
  }
}

class AppSettingsService {
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricKey = 'biometric_login_enabled';

  static const AppSettings _defaults = AppSettings(
    darkModeEnabled: false,
    notificationsEnabled: true,
    biometricLoginEnabled: false,
  );

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      darkModeEnabled: prefs.getBool(_darkModeKey) ?? _defaults.darkModeEnabled,
      notificationsEnabled:
          prefs.getBool(_notificationsKey) ?? _defaults.notificationsEnabled,
      biometricLoginEnabled:
          prefs.getBool(_biometricKey) ?? _defaults.biometricLoginEnabled,
    );
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, settings.darkModeEnabled);
    await prefs.setBool(_notificationsKey, settings.notificationsEnabled);
    await prefs.setBool(_biometricKey, settings.biometricLoginEnabled);
  }
}
