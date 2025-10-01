import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/notification_manager.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationManager _notificationManager = NotificationManager();
  List<NotificationData> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final notifications = await _notificationManager.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showSnackBar('Error loading notifications: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markAsRead(String id) async {
    await _notificationManager.markAsRead(id);
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    await _notificationManager.markAllAsRead();
    await _loadNotifications();
    _showSnackBar('Semua notifikasi ditandai sudah dibaca');
  }

  Future<void> _deleteNotification(String id) async {
    await _notificationManager.deleteNotification(id);
    await _loadNotifications();
    _showSnackBar('Notifikasi dihapus');
  }

  Future<void> _clearAll() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 10),
            Text('Hapus Semua Notifikasi', style: TextStyle(fontSize: 16)),
          ],
        ),
        content:
            const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _notificationManager.clearAll();
              await _loadNotifications();
              if (mounted) {
                Navigator.pop(ctx);
                _showSnackBar('Semua notifikasi dihapus');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
    }
  }

  Widget _buildNotificationItem(NotificationData notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xfff8f5f0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xff8d6e63).withOpacity(0.1)
                : const Color(0xff8b4513).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8d6e63).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _markAsRead(notification.id);
              // Handle navigation based on notification data
              if (notification.data != null &&
                  notification.data!.containsKey('route')) {
                final route = notification.data!['route'] as String;
                if (route == '/notes') {
                  Navigator.pop(context); // Back to notes page
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread indicator
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: notification.isRead
                          ? Colors.transparent
                          : const Color(0xff8b4513),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: const Color(0xff3e2723),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xff6d4c41).withOpacity(0.8),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xff8d6e63).withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: const Color(0xff8d6e63).withOpacity(0.5),
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'mark_read') {
                        _markAsRead(notification.id);
                      } else if (value == 'delete') {
                        _deleteNotification(notification.id);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.check, size: 18),
                              SizedBox(width: 8),
                              Text('Tandai sudah dibaca'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: const Color(0xff8d6e63).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff6d4c41),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xff8d6e63).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            const Text(
              "Notifikasi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xff8b4513),
        elevation: 4,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'mark_all') {
                  _markAllAsRead();
                } else if (value == 'clear_all') {
                  _clearAll();
                }
              },
              itemBuilder: (context) => [
                if (unreadCount > 0)
                  const PopupMenuItem(
                    value: 'mark_all',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 18),
                        SizedBox(width: 8),
                        Text('Tandai semua sudah dibaca'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus semua', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      backgroundColor: const Color(0xfff8f5f0),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff8b4513)),
            ))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xff8b4513),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
                ),
    );
  }
}
