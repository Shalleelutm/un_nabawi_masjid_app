import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';
import 'prayer_time_service.dart';
import '../screens/adhan/adhan_screen.dart';

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

  /*
  ------------------------------------------------------------
  PRAYER NOTIFICATION ENGINE
  ------------------------------------------------------------
  */

  Future<void> refreshUpcomingPrayerSchedules(List<PrayerDay> upcoming) async {
    await initialize();

    await LocalNotificationService.instance.cancelAllPrayerNotifications();

    for (int dayIndex = 0; dayIndex < upcoming.length; dayIndex++) {
      final day = upcoming[dayIndex];

      await _schedulePrayer(
        dayIndex: dayIndex,
        prayerIndex: 1,
        prayerName: 'Fajr',
        date: day.date,
        adhanTime: day.fajrAdhan,
      );

      await _schedulePrayer(
        dayIndex: dayIndex,
        prayerIndex: 2,
        prayerName: 'Zohr',
        date: day.date,
        adhanTime: day.zohrAdhan,
      );

      await _schedulePrayer(
        dayIndex: dayIndex,
        prayerIndex: 3,
        prayerName: 'Asr',
        date: day.date,
        adhanTime: day.asrAdhan,
      );

      await _schedulePrayer(
        dayIndex: dayIndex,
        prayerIndex: 4,
        prayerName: 'Maghrib',
        date: day.date,
        adhanTime: day.maghribAdhan,
      );

      await _schedulePrayer(
        dayIndex: dayIndex,
        prayerIndex: 5,
        prayerName: 'Esha',
        date: day.date,
        adhanTime: day.eshaAdhan,
      );
    }

    if (kDebugMode) {
      final pending = await LocalNotificationService.instance.pending();
      debugPrint('Prayer notifications scheduled: ${pending.length}');
    }
  }

  Future<void> _schedulePrayer({
    required int dayIndex,
    required int prayerIndex,
    required String prayerName,
    required DateTime date,
    required String adhanTime,
  }) async {
    final when = PrayerTimeService.instance.parseTimeForDate(date, adhanTime);

    if (when == null) return;
    if (!when.isAfter(DateTime.now())) return;

    final id = 1000 + (dayIndex * 10) + prayerIndex;

    await LocalNotificationService.instance.scheduleOne(
      id: id,
      when: when,
      title: '$prayerName time',
      body: '$prayerName Adhan is at $adhanTime',
      channelId: LocalNotificationService.prayerChannelId,
      channelName: 'Prayer Notifications',
    );

    // 🔥 TRIGGER FULLSCREEN ADHAN
    Future.delayed(
      when.difference(DateTime.now()),
      () => AdhanTrigger.showAdhan(),
    );
  }

  /*
  ------------------------------------------------------------
  JUMUAH SCHEDULER
  ------------------------------------------------------------
  */

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
    );

    await LocalNotificationService.instance.scheduleOne(
      id: _jumuah2Id,
      when: second,
      title: 'Jumu’ah Starting',
      body: 'Please proceed to the masjid for Jumu’ah prayer.',
      channelId: LocalNotificationService.generalChannelId,
      channelName: 'General Notifications',
    );
  }
}

/*
------------------------------------------------------------
ADHAN TRIGGER SYSTEM
------------------------------------------------------------
*/

class AdhanTrigger {
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showAdhan() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdhanScreen(),
      ),
    );
  }
}