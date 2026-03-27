import 'package:flutter/material.dart';

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
  static const splash = '/';
  static const role = '/role';
  static const language = '/language';
  static const simple = '/simple';

  static const login = '/login';
  static const memberHome = '/memberHome';
  static const adminHome = '/adminHome';

  static const createRequest = '/createRequest';
  static const myRequests = '/myRequests';
  static const adminRequests = '/adminRequests';

  static const gallery = '/gallery';
  static const adminGallery = '/adminGallery';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    role: (_) => const RoleSelectionScreen(),
    language: (_) => const LanguageSelectionScreen(),
    simple: (_) => const SimpleModeScreen(),
    login: (_) => const LoginScreen(),

    memberHome: (_) => const DashboardScreen(),
    adminHome: (_) => const AdminHomeScreen(),

    prayerTimes: (_) => const PrayerTimesScreen(),
    nextSalah: (_) => const NextSalahScreen(),
    announcements: (_) => const AnnouncementsScreen(),
    quran: (_) => const QuranReaderScreen(),
    settings: (_) => const SettingsScreen(),
    adminReservations: (_) => const AdminReservationsScreen(),

    createRequest: (_) => const CreateRequestScreen(),
    myRequests: (_) => const MyRequestsScreen(),
    adminRequests: (_) => const AdminRequestsScreen(),

    gallery: (_) => const MemberGalleryScreen(),
    adminGallery: (_) => const AdminGalleryScreen(),
  };

  static const prayerTimes = '/prayerTimes';
  static const nextSalah = '/nextSalah';
  static const announcements = '/announcements';
  static const quran = '/quran';
  static const settings = '/settings';
  static const adminReservations = '/adminReservations';
}