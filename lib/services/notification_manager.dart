import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationData {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'data': data,
      };

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        data: json['data'] as Map<String, dynamic>?,
      );

  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  static const String _storageKey = 'notifications_storage';
  static const int _maxNotifications = 100; 

  Future<void> saveNotification(NotificationData notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      notifications.insert(0, notification);

      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
      }

      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      print('📱 Notification saved: ${notification.title}');
    } catch (e) {
      print('❌ Error saving notification: $e');
    }
  }

  Future<List<NotificationData>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
              (json) => NotificationData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);

        final prefs = await SharedPreferences.getInstance();
        final jsonList = notifications.map((n) => n.toJson()).toList();
        await prefs.setString(_storageKey, jsonEncode(jsonList));

        print('✅ Notification marked as read: $notificationId');
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications =
          notifications.map((n) => n.copyWith(isRead: true)).toList();

      final prefs = await SharedPreferences.getInstance();
      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      print('🗑️ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      print('🧹 All notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  /// Add test notifications (for demo)
  Future<void> addTestNotifications() async {
    final now = DateTime.now();

    await saveNotification(NotificationData(
      id: 'test_1',
      title: '🎉 Selamat Datang!',
      body: 'Terima kasih telah menggunakan aplikasi kami',
      timestamp: now.subtract(const Duration(minutes: 5)),
      isRead: false,
    ));

    await saveNotification(NotificationData(
      id: 'test_2',
      title: '📝 Catatan Baru',
      body: 'Anda memiliki 3 catatan yang belum selesai',
      timestamp: now.subtract(const Duration(hours: 2)),
      isRead: false,
    ));

    await saveNotification(NotificationData(
      id: 'test_3',
      title: '💡 Tips & Trik',
      body: 'Gunakan fitur search untuk menemukan catatan lebih cepat',
      timestamp: now.subtract(const Duration(days: 1)),
      isRead: true,
    ));

    print('✅ Test notifications added');
  }
}
