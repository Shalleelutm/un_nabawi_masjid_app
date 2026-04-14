import 'package:flutter/material.dart';

import '../widgets/admin_guard.dart';

import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_reservations_screen.dart';
import '../screens/admin/admin_requests_screen.dart';
import '../screens/admin/admin_gallery_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/phase0/language_selection_screen.dart';
import '../screens/phase0/role_selection_screen.dart';
import '../screens/phase0/simple_mode_screen.dart';
import '../screens/phase0/splash_screen.dart';
import '../screens/phase1/prayer_times_screen.dart';
import '../screens/phase4_announcements/announcements_screen.dart';
import '../screens/phase6_dashboard/dashboard_screen.dart';
import '../screens/phase6_dashboard/next_salah_screen.dart';
import '../screens/phase7_settings/settings_screen.dart';
import '../screens/phase8_islamic/quran_reader_screen.dart';

import '../screens/requests/create_request_screen.dart';
import '../screens/requests/my_requests_screen.dart';
import '../screens/gallery/member_gallery_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String role = '/role';
  static const String language = '/language';
  static const String simple = '/simple';

  static const String login = '/login';
  static const String memberHome = '/memberHome';
  static const String adminHome = '/adminHome';

  static const String createRequest = '/createRequest';
  static const String myRequests = '/myRequests';
  static const String adminRequests = '/adminRequests';

  static const String gallery = '/gallery';
  static const String adminGallery = '/adminGallery';

  static const String prayerTimes = '/prayerTimes';
  static const String nextSalah = '/nextSalah';
  static const String announcements = '/announcements';
  static const String quran = '/quran';
  static const String settings = '/settings';
  static const String adminReservations = '/adminReservations';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    role: (_) => const RoleSelectionScreen(),
    language: (_) => const LanguageSelectionScreen(),
    simple: (_) => const SimpleModeScreen(),
    login: (_) => const LoginScreen(),

    memberHome: (_) => const DashboardScreen(),

    adminHome: (_) => const AdminGuard(
          child: AdminHomeScreen(),
        ),

    prayerTimes: (_) => const PrayerTimesScreen(),
    nextSalah: (_) => const NextSalahScreen(),
    announcements: (_) => const AnnouncementsScreen(),
    quran: (_) => const QuranReaderScreen(),
    settings: (_) => const SettingsScreen(),

    adminReservations: (_) => const AdminGuard(
          child: AdminReservationsScreen(),
        ),

    createRequest: (_) => const CreateRequestScreen(),
    myRequests: (_) => const MyRequestsScreen(),

    adminRequests: (_) => const AdminGuard(
          child: AdminRequestsScreen(),
        ),

    gallery: (_) => const MemberGalleryScreen(),

    adminGallery: (_) => const AdminGuard(
          child: AdminGalleryScreen(),
        ),
  };
}