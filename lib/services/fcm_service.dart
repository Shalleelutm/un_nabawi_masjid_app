import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 🔥 PERMISSION
    await _fcm.requestPermission();

    // 🔥 TOKEN
    final token = await _fcm.getToken();
    print('🔥 FCM TOKEN: $token');

    // 🔥 LOCAL INIT
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _local.initialize(
      const InitializationSettings(android: android),
    );

    // 🔥 LISTENERS
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpen);

    // 🔥 TOPICS (FINAL)
    await _fcm.subscribeToTopic('announcements');
    await _fcm.subscribeToTopic('events');
    await _fcm.subscribeToTopic('chat');

    print('✅ FCM READY');
  }

  Future<void> subscribe(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribe(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  void _handleMessage(RemoteMessage msg) {
    final notif = msg.notification;
    if (notif == null) return;

    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'masjid',
          'Masjid Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _handleOpen(RemoteMessage msg) {
    final type = msg.data['type'];

    if (type == 'chat') {
      navigatorKey.currentState?.pushNamed('/requests');
    } else {
      navigatorKey.currentState?.pushNamed('/announcements');
    }
  }
}