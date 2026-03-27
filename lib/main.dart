import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';

import 'providers/announcement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/masjid_mode_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/reservation_provider.dart';

import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';
import 'services/prayer_auto_scheduler_service.dart';
import 'services/prayer_notification_service.dart';
import 'services/prayer_time_change_detector.dart';
import 'services/prayer_time_service.dart';
import 'services/ramadan_auto_hadith_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load local timetable first so app opens offline
  await PrayerTimeService.instance.loadFromAssets();

  /// Init local notifications first
  await LocalNotificationService.instance.init();

  /// Init prayer notifications first
  await PrayerNotificationService.instance.init();

  /// Firebase should not block app opening
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

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

  /// Start online/background services after UI is already shown
  Future.microtask(() async {
    try {
      await FcmService.instance.init();
    } catch (e) {
      debugPrint('FCM init skipped: $e');
    }

    try {
      await PrayerTimeChangeDetector.instance.detectChanges();
    } catch (e) {
      debugPrint('Prayer time change detector skipped: $e');
    }

    try {
      await PrayerAutoSchedulerService.instance.start();
    } catch (e) {
      debugPrint('Prayer scheduler skipped: $e');
    }

    try {
      await RamadanAutoHadithService.scheduleRamadanHadiths();
    } catch (e) {
      debugPrint('Ramadan hadith scheduler skipped: $e');
    }
  });
}