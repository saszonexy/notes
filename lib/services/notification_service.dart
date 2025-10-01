import 'dart:io' show Platform; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final List<String> _subscribedTopics = [];

  List<String> get subscribedTopics => List.unmodifiable(_subscribedTopics);

  Future<void> init() async {
    if (kIsWeb) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("🔔 Permission status: ${settings.authorizationStatus}");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showFCMLocalNotification(message);
    });

    if (!kIsWeb) {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _localNotifications.initialize(settings);
    }
  }

  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print("❌ Error getToken: $e");
      return null;
    }
  }

  Future<void> setupFCMToken() async {
    _messaging.onTokenRefresh.listen((token) {
      print("🔄 Token refreshed: $token");
    });
  }

  Future<bool> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      print("⚠️ subscribeToTopic() tidak didukung di Web. Gunakan backend.");
      return false;
    }
    try {
      await _messaging.subscribeToTopic(topic);
      _subscribedTopics.add(topic);
      return true;
    } catch (e) {
      print("❌ Error subscribe: $e");
      return false;
    }
  }

  Future<bool> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      print(
          "⚠️ unsubscribeFromTopic() tidak didukung di Web. Gunakan backend.");
      return false;
    }
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _subscribedTopics.remove(topic);
      return true;
    } catch (e) {
      print("❌ Error unsubscribe: $e");
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb)
      return true; 
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> openAppSettings() async {
    if (!kIsWeb && Platform.isAndroid) {
      print("⚠️ Implement open settings pakai package permission_handler");
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      print("⚠️ LocalNotification tidak tersedia di Web");
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  Future<void> clearAllNotifications() async {
    if (!kIsWeb) {
      await _localNotifications.cancelAll();
    }
  }

  Future<void> logDeliveryMetrics() async {
    print("📊 Delivery metrics: Token=${await getCurrentToken()}");
    print("📊 Topics: $_subscribedTopics");
  }

  Future<void> _showFCMLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: message.notification?.title ?? "No Title",
      body: message.notification?.body ?? "No Body",
    );
  }

  initialize() {}

  unsubscribeFromAllTopics() {}
}
