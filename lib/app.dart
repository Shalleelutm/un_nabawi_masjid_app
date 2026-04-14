import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'services/prayer_notification_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Un Nabawi Masjid',
      debugShowCheckedModeBanner: false,

      // 🔥 REQUIRED FOR ADHAN FULLSCREEN
      navigatorKey: AdhanTrigger.navigatorKey,

      // THEME
      theme: AppTheme.light(),

      // START SCREEN
      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}