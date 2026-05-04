import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/local_notification_service.dart';

import 'providers/announcement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/masjid_mode_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/role_provider.dart';

import 'services/prayer_auto_scheduler_service.dart';
import 'services/fcm_service.dart';
import 'services/notification_listener_service.dart';
import 'services/prayer_time_service.dart';
import 'core/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PrayerTimeService.instance.loadFromAssets();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MasjidModeProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationSettingsProvider()..load(),
        ),
        
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()..start()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()..loadRole()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Un Nabawi Masjid',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) =>
                AppRoutes.routes[settings.name]!(context),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007A3D),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007A3D),
            brightness: Brightness.dark,
          ),
        ),
        home: const MyApp(),
      ),
    ),
  );
  Future.microtask(() async {
    await FcmService.instance.init();
    await NotificationListenerService.instance.start();
    await LocalNotificationService.instance.init();
    await PrayerAutoSchedulerService.instance.start();
  });
}