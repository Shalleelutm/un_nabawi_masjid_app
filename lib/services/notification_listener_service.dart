import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationListenerService {
  static final instance = NotificationListenerService._();
  NotificationListenerService._();

  final _db = FirebaseFirestore.instance;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _started = false;

  Future<void> initLocal() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _local.initialize(
      const InitializationSettings(android: android),
    );
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;

    await initLocal();

    _db.collection('notifications').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) return;

          String title;

          switch (data['type']) {
            case 'chat':
              title = '💬 New Message';
              break;
            case 'announcement':
              title = '🕌 Masjid Update';
              break;
            case 'prayer':
              title = '🕋 Prayer Time';
              break;
            default:
              title = '📢 Notification';
          }
          
          final message = data['message'] ?? '';

          _show(title, message);
        }
      }
    });
  }

  Future<void> _show(String title, String body) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'masjid_channel',
          'Masjid Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }

  // Method to send a notification
  Future<void> sendNotification({
    required String title,
    required String message,
    String type = 'chat',
  }) async {
    try {
      await _db.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Notification sent successfully');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
}

// Extension to easily use the sendNotification method
extension NotificationSender on NotificationListenerService {
  Future<void> sendChatNotification(String message) async {
    await sendNotification(
      title: 'New Message',
      message: message,
      type: 'chat',
    );
  }
}