import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final List<String> _subscribedTopics = [];
  bool _isInitialized = false;

  List<String> get subscribedTopics => List.unmodifiable(_subscribedTopics);

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await init();
      _isInitialized = true;
      print('✅ NotificationService initialized');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
    }
  }

  Future<void> init() async {
    if (kIsWeb) {
      print('⚠️ Web platform: FCM with limited functionality');
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        print('✅ Web notification permission requested');
      } catch (e) {
        print('⚠️ Web FCM error (expected in dev mode): $e');
      }
    } else {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("🔔 Permission status: ${settings.authorizationStatus}");

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      await _localNotifications.initialize(settings as InitializationSettings);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground message: ${message.notification?.title}');
      _showFCMLocalNotification(message);
    });
  }

  Future<String?> getCurrentToken() async {
    try {
      if (kIsWeb) {
        print('⚠️ Getting web FCM token (may fail without service worker)');
      }
      final token = await _messaging.getToken();
      if (token != null) {
        print('🔥 FCM Token: ${token.substring(0, 20)}...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      return token;
    } catch (e) {
      print("❌ Error getToken: $e");
      if (kIsWeb) {
        print('ℹ️ This is expected on web without service worker setup');
      }
      return null;
    }
  }

  Future<void> setupFCMToken() async {
    await getCurrentToken();
    
    _messaging.onTokenRefresh.listen((token) {
      print("🔄 Token refreshed: ${token.substring(0, 20)}...");
    });
  }

  Future<bool> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      print("⚠️ subscribeToTopic() tidak didukung di Web.");
      return false;
    }
    try {
      await _messaging.subscribeToTopic(topic);
      if (!_subscribedTopics.contains(topic)) {
        _subscribedTopics.add(topic);
      }
      print('✅ Subscribed to topic: $topic');
      return true;
    } catch (e) {
      print("❌ Error subscribe: $e");
      return false;
    }
  }

  Future<bool> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      print("⚠️ unsubscribeFromTopic() tidak didukung di Web.");
      return false;
    }
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _subscribedTopics.remove(topic);
      print('✅ Unsubscribed from topic: $topic');
      return true;
    } catch (e) {
      print("❌ Error unsubscribe: $e");
      return false;
    }
  }

  Future<void> unsubscribeFromAllTopics() async {
    if (kIsWeb) {
      print("⚠️ unsubscribeFromAllTopics() tidak didukung di Web.");
      return;
    }
    
    for (String topic in List.from(_subscribedTopics)) {
      await unsubscribeFromTopic(topic);
    }
    print('✅ Unsubscribed from all topics');
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return true;
    
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> openAppSettings() async {
    if (kIsWeb) {
      print("⚠️ openAppSettings() tidak tersedia di Web");
      return;
    }
    
    await _messaging.requestPermission();
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
    print('📱 Local notification shown: $title');
  }

  Future<void> clearAllNotifications() async {
    if (kIsWeb) return;
    
    await _localNotifications.cancelAll();
    print('🧹 All notifications cleared');
  }

  Future<void> logDeliveryMetrics() async {
    final token = await getCurrentToken();
    print("📊 Delivery metrics:");
    print("   Token: ${token?.substring(0, 30)}...");
    print("   Topics: $_subscribedTopics");
    print("   Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}");
  }

  Future<void> _showFCMLocalNotification(RemoteMessage message) async {
    if (kIsWeb) {
      print('ℹ️ Web foreground notification: ${message.notification?.title}');
      return;
    }

    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: message.notification?.title ?? "Notifikasi",
      body: message.notification?.body ?? "",
    );
  }
}