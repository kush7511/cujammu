import 'dart:convert';

import 'package:http/http.dart' as http;

class NotificationBackendService {
  // Update this URL to your production server endpoint.
  static const String baseUrl = "http://10.0.2.2:4000";

  static Future<void> registerDeviceToken({
    required String token,
    String? userRoll,
    String platform = "android",
  }) async {
    final uri = Uri.parse("$baseUrl/devices/register");
    try {
      await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "token": token,
              "userRoll": userRoll,
              "platform": platform,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Keep app flow resilient if backend is unavailable.
    }
  }
}
