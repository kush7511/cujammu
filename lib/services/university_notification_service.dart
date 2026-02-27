import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_backend_service.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await UniversityNotificationService.instance.initialize();
  await UniversityNotificationService.instance.storeRemoteMessage(message);
}

class UniversityNotification {
  final String id;
  final String title;
  final String message;
  final DateTime receivedAt;
  final bool isRead;

  const UniversityNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.receivedAt,
    required this.isRead,
  });

  UniversityNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? receivedAt,
    bool? isRead,
  }) {
    return UniversityNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "receivedAt": receivedAt.toIso8601String(),
        "isRead": isRead,
      };

  factory UniversityNotification.fromJson(Map<String, dynamic> json) {
    return UniversityNotification(
      id: json["id"] as String,
      title: json["title"] as String,
      message: json["message"] as String,
      receivedAt: DateTime.parse(json["receivedAt"] as String),
      isRead: json["isRead"] as bool? ?? false,
    );
  }
}

class UniversityNotificationService {
  UniversityNotificationService._();

  static final UniversityNotificationService instance =
      UniversityNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _notificationsKey = "university_notifications_v1";
  static const int _maxNotifications = 200;

  final StreamController<List<UniversityNotification>> _streamController =
      StreamController<List<UniversityNotification>>.broadcast();

  List<UniversityNotification> _notifications = [];
  bool _initialized = false;

  List<UniversityNotification> get notifications =>
      List.unmodifiable(_notifications);

  Stream<List<UniversityNotification>> get notificationsStream =>
      _streamController.stream;

  int get unreadCount =>
      _notifications.where((e) => !e.isRead).length;

  /// ---------------- INITIALIZE ----------------

  Future<void> initialize({String? userRoll}) async {
    if (_initialized) return;

    await _initializeFirebase();
    await _loadStoredNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _registerToken(userRoll: userRoll);

    FirebaseMessaging.onMessage.listen((message) async {
      await storeRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await storeRemoteMessage(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await storeRemoteMessage(initialMessage);
    }

    _initialized = true;
  }

  Future<void> _initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp();
  }

  Future<void> _registerToken({String? userRoll}) async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) return;

      await NotificationBackendService.registerDeviceToken(
        token: token,
        userRoll: userRoll,
      );

      _messaging.onTokenRefresh.listen((newToken) {
        print("🔄 Token refreshed: $newToken");
      });
    } catch (e) {
      print("Token registration error: $e");
    }
  }

  /// ---------------- LOCAL STORAGE ----------------

  Future<void> _loadStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notificationsKey);

    if (raw == null || raw.isEmpty) {
      _streamController.add(notifications);
      return;
    }

    final parsed = jsonDecode(raw);
    _notifications = (parsed as List)
        .map((e) =>
            UniversityNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    _streamController.add(notifications);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsKey,
      jsonEncode(_notifications.map((e) => e.toJson()).toList()),
    );
    _streamController.add(notifications);
  }

  /// ---------------- STORE NEW NOTIFICATION ----------------

  Future<void> storeRemoteMessage(RemoteMessage remoteMessage) async {
    final title = remoteMessage.notification?.title ??
        remoteMessage.data["title"]?.toString() ??
        "University Update";

    final message = remoteMessage.notification?.body ??
        remoteMessage.data["body"]?.toString() ??
        "New update received.";

    final notification = UniversityNotification(
      id: remoteMessage.messageId ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      receivedAt: DateTime.now(),
      isRead: false,
    );

    _notifications = [notification, ..._notifications];

    if (_notifications.length > _maxNotifications) {
      _notifications = _notifications.take(_maxNotifications).toList();
    }

    await _persist();
  }

  Future<void> addLocalNotification({
    required String title,
    required String message,
  }) async {
    final notification = UniversityNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      receivedAt: DateTime.now(),
      isRead: false,
    );

    _notifications = [notification, ..._notifications];
    await _persist();
  }

  /// ---------------- ACTION METHODS ----------------

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _persist();
  }

  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((e) => e.copyWith(isRead: true)).toList();
    await _persist();
  }
}