import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Un Nabawi Masjid',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,

      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}