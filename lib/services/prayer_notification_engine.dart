import 'package:flutter/material.dart';
import '../app.dart';
import 'local_notification_service.dart';
import 'prayer_time_service.dart';
import 'sound_service.dart';

class PrayerNotificationEngine {
  PrayerNotificationEngine._();
  static final PrayerNotificationEngine instance = PrayerNotificationEngine._();

  bool _initialized = false;

  // Jumuah notification IDs (declared and used)
  static const int _jumuah1Id = 9001;
  static const int _jumuah2Id = 9002;

  Future<void> initialize() async {
    if (_initialized) return;
    await LocalNotificationService.instance.init();
    _initialized = true;
  }

  Future<void> clearCache() async {
    // Clear any cached prayer data
  }

  Future<void> cancelPrayerNotifications() async {
    await LocalNotificationService.instance.cancelAllPrayerNotifications();
  }

  Future<void> scheduleAllRemainingPrayerNotifications() async {
    final now = DateTime.now();
    final today = PrayerTimeService.instance.today(now: now);
    final tomorrow = PrayerTimeService.instance.tomorrow(now: now);
    
    final days = [today, tomorrow];
    
    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final day = days[dayIndex];
      if (day == null) continue;
      
      await _schedulePrayer(dayIndex, 1, 'Fajr', day.date, day.fajrAdhan);
      await _schedulePrayer(dayIndex, 2, 'Dhuhr', day.date, day.zohrAdhan);
      await _schedulePrayer(dayIndex, 3, 'Asr', day.date, day.asrAdhan);
      await _schedulePrayer(dayIndex, 4, 'Maghrib', day.date, day.maghribAdhan);
      await _schedulePrayer(dayIndex, 5, 'Isha', day.date, day.eshaAdhan);
    }
  }

  Future<void> scheduleJumuah({required DateTime first, required DateTime second}) async {
    await LocalNotificationService.instance.scheduleOne(
      id: _jumuah1Id,
      when: first,
      title: 'Jumu\'ah Reminder',
      body: 'Jumu\'ah khutbah will start soon.',
      channelId: LocalNotificationService.generalChannelId,
      channelName: 'General Notifications',
      payload: 'jumuah',
    );
    
    await LocalNotificationService.instance.scheduleOne(
      id: _jumuah2Id,
      when: second,
      title: 'Jumu\'ah Starting',
      body: 'Please proceed to the masjid for Jumu\'ah prayer.',
      channelId: LocalNotificationService.generalChannelId,
      channelName: 'General Notifications',
      payload: 'jumuah',
    );
  }

  Future<void> cancelJumuah() async {
    await LocalNotificationService.instance.cancel(_jumuah1Id);
    await LocalNotificationService.instance.cancel(_jumuah2Id);
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
      body: 'Time for $prayerName prayer at ${_formatTime(when)}',
      channelId: LocalNotificationService.prayerChannelId,
      channelName: 'Prayer Notifications',
      payload: 'adhan',
    );

    // Schedule adhan + vibration
    final delay = when.difference(DateTime.now());
    if (delay.inSeconds > 0) {
      Future.delayed(delay, () {
        SoundService.playAdhan();
        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.pushNamed(context, '/adhan');
        }
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> debugToday() async {
    final today = PrayerTimeService.instance.today();
    return {
      'hasData': today != null,
      'fajr': today?.fajrAdhan ?? '--',
      'dhuhr': today?.zohrAdhan ?? '--',
      'asr': today?.asrAdhan ?? '--',
      'maghrib': today?.maghribAdhan ?? '--',
      'isha': today?.eshaAdhan ?? '--',
    };
  }
}