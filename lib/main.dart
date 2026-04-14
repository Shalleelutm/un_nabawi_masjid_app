import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'firebase_options.dart';

import 'providers/announcement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/masjid_mode_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/reservation_provider.dart';

import 'services/prayer_auto_scheduler_service.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FcmService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MasjidModeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()..start()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: const MyApp(),
    ),
  );

  Future.microtask(() async {
    await PrayerAutoSchedulerService.instance.start();
  });
}