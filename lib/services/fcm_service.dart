import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notification_service.dart';
import 'prayer_notification_engine.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await LocalNotificationService.instance.init();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('FCM permission status: ${settings.authorizationStatus}');
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final token = await _messaging.getToken();
    if (kDebugMode) {
      debugPrint('FCM token: $token');
    }

    await _messaging.subscribeToTopic('members');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final data = message.data;

      final title = notification?.title ?? data['title'] ?? 'Notification';
      final body = notification?.body ?? data['body'] ?? '';

      await LocalNotificationService.instance.showNow(
        notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: jsonEncode(data),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Notification opened: ${message.data}');
      }
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && kDebugMode) {
      debugPrint(
        'App opened from terminated state by notification: ${initialMessage.data}',
      );
    }

    await PrayerNotificationEngine.instance.initializeAndSchedule();

    _initialized = true;
  }

  Future<void> resubscribeMembersTopic() async {
    await _messaging.unsubscribeFromTopic('members');
    await _messaging.subscribeToTopic('members');
  }
}