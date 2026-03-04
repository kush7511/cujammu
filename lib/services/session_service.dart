import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _loggedInRollKey = 'logged_in_roll_v1';

  static Future<void> saveLoggedInRoll(String roll) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInRollKey, roll.trim());
  }

  static Future<String?> getLoggedInRoll() async {
    final prefs = await SharedPreferences.getInstance();
    final roll = prefs.getString(_loggedInRollKey);
    if (roll == null || roll.trim().isEmpty) return null;
    return roll.trim();
  }

  static Future<void> clearLoggedInRoll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInRollKey);
  }
}