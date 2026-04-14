// ignore_for_file: prefer_single_quotes

import 'dart:async';
import 'package:flutter/material.dart';

import 'fcm_service.dart';
import 'local_notification_service.dart';
import 'prayer_auto_scheduler_service.dart';
import 'prayer_notification_service.dart';
import 'prayer_time_change_detector.dart';
import 'prayer_time_service.dart';
import 'ramadan_auto_hadith_service.dart';

class AppInitializerService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    debugPrint("🚀 Starting app services...");

    // Small delay to let UI render first
    await Future.delayed(const Duration(seconds: 1));

    try {
      await PrayerTimeService.instance.loadFromAssets();
    } catch (e) {
      debugPrint('PrayerTime load failed: $e');
    }

    try {
      await LocalNotificationService.instance.init();
    } catch (e) {
      debugPrint('LocalNotification init failed: $e');
    }

    try {
      await PrayerNotificationService.instance.init();
    } catch (e) {
      debugPrint('PrayerNotification init failed: $e');
    }

    try {
      await FcmService.instance.init();
    } catch (e) {
      debugPrint('FCM init failed: $e');
    }

    try {
      await PrayerTimeChangeDetector.instance.detectChanges();
    } catch (e) {
      debugPrint('Prayer change detect failed: $e');
    }

    try {
      await PrayerAutoSchedulerService.instance.start();
    } catch (e) {
      debugPrint('Scheduler failed: $e');
    }

    try {
      await RamadanAutoHadithService.scheduleRamadanHadiths();
    } catch (e) {
      debugPrint('Ramadan service failed: $e');
    }

    debugPrint("✅ All services initialized");
  }
}