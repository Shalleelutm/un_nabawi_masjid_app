// ignore_for_file: prefer_single_quotes

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _local.initialize(
      const InitializationSettings(android: android),
    );

    // 🔥 SUBSCRIBE TO MEMBERS
    await _fcm.subscribeToTopic('members');

    // 🔥 FOREGROUND
    FirebaseMessaging.onMessage.listen((event) {
      final notif = event.notification;
      if (notif != null) {
        _show(notif.title, notif.body);
      }
    });

    // 🔥 BACKGROUND TAP
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      debugPrint("Notification clicked");
    });

    // 🔥 TERMINATED
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      debugPrint("App opened from terminated state");
    }
  }

  Future<void> _show(String? title, String? body) async {
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
        ),
      ),
    );
  }
}

// 🔥 BACKGROUND HANDLER (REQUIRED)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background message: ${message.notification?.title}");
}