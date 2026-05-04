import 'package:flutter/material.dart'; // ✅ ONLY THIS (clean)

import '../app.dart';
import 'local_notification_service.dart';
import 'prayer_time_service.dart';

class PrayerNotificationService {
  PrayerNotificationService._();

  static final PrayerNotificationService instance =
      PrayerNotificationService._();

  bool _initialized = false;

  static const int _jumuah1Id = 9001;
  static const int _jumuah2Id = 9002;

  Future<void> init() async {
    await initialize();
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await LocalNotificationService.instance.init();
    _initialized = true;
  }

  Future<void> refreshUpcomingPrayerSchedules(List<PrayerDay> upcoming) async {
    await initialize();

    await LocalNotificationService.instance.cancelAllPrayerNotifications();

    for (int dayIndex = 0; dayIndex < upcoming.length; dayIndex++) {
      final day = upcoming[dayIndex];

      await _schedulePrayer(dayIndex, 1, 'Fajr', day.date, day.fajrAdhan);
      await _schedulePrayer(dayIndex, 2, 'Zohr', day.date, day.zohrAdhan);
      await _schedulePrayer(dayIndex, 3, 'Asr', day.date, day.asrAdhan);
      await _schedulePrayer(dayIndex, 4, 'Maghrib', day.date, day.maghribAdhan);
      await _schedulePrayer(dayIndex, 5, 'Esha', day.date, day.eshaAdhan);
    }
  }

  Future<void> _schedulePrayer(
    int dayIndex,
    int prayerIndex,
    String prayerName,
    DateTime date,
    String adhanTime,
  ) async {
    final when = PrayerTimeService.instance.parseTimeForDate(date, adhanTime);

    if (when == null) return;
    if (!when.isAfter(DateTime.now())) return;

    final id = 1000 + (dayIndex * 10) + prayerIndex;

    await LocalNotificationService.instance.scheduleOne(
      id: id,
      when: when,
      title: '$prayerName Adhan',
      body: 'Time for $prayerName prayer',
      channelId: LocalNotificationService.prayerChannelId,
      channelName: 'Prayer Notifications',
      payload: 'adhan',
    );

    // 🔥 FULLSCREEN TRIGGER
    Future.delayed(
      when.difference(DateTime.now()),
      () => AdhanTrigger.showAdhan(),
    );
  }

  Future<void> cancelJumuah() async {
    await LocalNotificationService.instance.cancel(_jumuah1Id);
    await LocalNotificationService.instance.cancel(_jumuah2Id);
  }

  Future<void> scheduleWeeklyJumuah({
    required DateTime first,
    required DateTime second,
  }) async {
    await initialize();

    await LocalNotificationService.instance.scheduleOne(
      id: _jumuah1Id,
      when: first,
      title: 'Jumu’ah Reminder',
      body: 'Jumu’ah khutbah will start soon.',
      channelId: LocalNotificationService.generalChannelId,
      channelName: 'General Notifications',
      payload: 'jumuah',
    );

    await LocalNotificationService.instance.scheduleOne(
      id: _jumuah2Id,
      when: second,
      title: 'Jumu’ah Starting',
      body: 'Please proceed to the masjid for Jumu’ah prayer.',
      channelId: LocalNotificationService.generalChannelId,
      channelName: 'General Notifications',
      payload: 'jumuah',
    );
  }
}

class AdhanTrigger {
  static void showAdhan() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.pushNamed(context, '/adhan');
  }
}