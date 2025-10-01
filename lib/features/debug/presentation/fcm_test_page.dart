import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/notification_service.dart';

class FCMTestPage extends StatefulWidget {
  const FCMTestPage({super.key});

  @override
  State<FCMTestPage> createState() => _FCMTestPageState();
}

class _FCMTestPageState extends State<FCMTestPage> {
  final NotificationService _notificationService = NotificationService();
  String? _fcmToken;
  List<String> _subscribedTopics = [];
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFCMData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadFCMData() async {
    setState(() => _isLoading = true);
    try {
      final token = await _notificationService.getCurrentToken();
      final enabled = await _notificationService.areNotificationsEnabled();
      final topics = _notificationService.subscribedTopics;

      setState(() {
        _fcmToken = token;
        _notificationsEnabled = enabled;
        _subscribedTopics = topics;
      });
    } catch (e) {
      _showSnackBar('Error loading FCM data: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyTokenToClipboard() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      _showSnackBar('✅ FCM Token copied to clipboard!', Colors.green);
    }
  }

  Future<void> _refreshToken() async {
    setState(() => _isLoading = true);
    try {
      // cukup panggil getCurrentToken ulang
      final newToken = await _notificationService.getCurrentToken();
      setState(() {
        _fcmToken = newToken;
      });
      _showSnackBar('✅ Token refreshed successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('❌ Error refreshing token: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _subscribeToTopic() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      _showSnackBar('⚠️ Please enter a topic name', Colors.orange);
      return;
    }

    try {
      final success = await _notificationService.subscribeToTopic(topic);
      if (success) {
        _topicController.clear();
        await _loadFCMData();
        _showSnackBar('✅ Subscribed to topic: $topic', Colors.green);
      } else {
        _showSnackBar('❌ Failed to subscribe to topic', Colors.red);
      }
    } catch (e) {
      _showSnackBar('❌ Error subscribing to topic: $e', Colors.red);
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    try {
      final success = await _notificationService.unsubscribeFromTopic(topic);
      if (success) {
        await _loadFCMData();
        _showSnackBar('✅ Unsubscribed from topic: $topic', Colors.green);
      } else {
        _showSnackBar('❌ Failed to unsubscribe from topic', Colors.red);
      }
    } catch (e) {
      _showSnackBar('❌ Error unsubscribing from topic: $e', Colors.red);
    }
  }

  Future<void> _testLocalNotification() async {
    try {
      await _notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: '🧪 Test Local Notification',
        body:
            'This is a test notification sent at ${TimeOfDay.now().format(context)}',
        payload: 'test_payload_${DateTime.now().millisecondsSinceEpoch}',
      );
      _showSnackBar('✅ Test notification sent!', Colors.green);
    } catch (e) {
      _showSnackBar('❌ Error sending test notification: $e', Colors.red);
    }
  }

  Future<void> _clearAllNotifications() async {
    await _notificationService.clearAllNotifications();
    _showSnackBar('🧹 All notifications cleared', Colors.blue);
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _notificationsEnabled ? 'Enabled ✅' : 'Disabled ❌',
                    style: TextStyle(
                      color: _notificationsEnabled ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FCM Registration Token',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _fcmToken ?? 'Loading token...',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _fcmToken != null ? _copyTokenToClipboard : null,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Token'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _refreshToken,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic Subscriptions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      labelText: 'Topic Name',
                      hintText: 'e.g., news, updates, test_topic',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.topic),
                    ),
                    onSubmitted: (_) => _subscribeToTopic(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _subscribeToTopic,
                  icon: const Icon(Icons.add),
                  label: const Text('Subscribe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_subscribedTopics.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No topics subscribed yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subscribedTopics
                    .map((topic) => Chip(
                          label: Text(topic),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _unsubscribeFromTopic(topic),
                          backgroundColor: Colors.blue[100],
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Functions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _testLocalNotification,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Test Local Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearAllNotifications,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 FCM Test Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadFCMData,
            tooltip: 'Refresh All Data',
          ),
        ],
      ),
      body: _isLoading && _fcmToken == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading FCM data...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFCMData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildTokenCard(),
                    const SizedBox(height: 16),
                    _buildTopicCard(),
                    const SizedBox(height: 16),
                    _buildTestCard(),
                  ],
                ),
              ),
            ),
    );
  }
}
