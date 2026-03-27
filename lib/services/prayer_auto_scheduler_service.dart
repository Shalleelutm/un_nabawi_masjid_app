import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_notification_engine.dart';

class PrayerAutoSchedulerService {
  PrayerAutoSchedulerService._();

  static final PrayerAutoSchedulerService instance =
      PrayerAutoSchedulerService._();

  static const String _lastScheduledDateKey = 'prayer_last_scheduled_date';

  Future<void> start() async {
    await initializeAndSchedule();
  }

  Future<void> initializeAndSchedule() async {
    await PrayerNotificationEngine.instance.initialize();
    await rescheduleIfNeeded();
  }

  Future<void> refreshSchedules() async {
    await forceReschedule();
  }

  Future<void> rescheduleIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();

    final lastScheduledDate = prefs.getString(_lastScheduledDateKey);
    if (lastScheduledDate == todayKey) {
      return;
    }

    await PrayerNotificationEngine.instance.clearCache();
    await PrayerNotificationEngine.instance.cancelPrayerNotifications();
    await PrayerNotificationEngine.instance.scheduleAllRemainingPrayerNotifications();

    await prefs.setString(_lastScheduledDateKey, todayKey);
  }

  Future<void> forceReschedule() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_lastScheduledDateKey);

    await PrayerNotificationEngine.instance.clearCache();
    await PrayerNotificationEngine.instance.cancelPrayerNotifications();
    await PrayerNotificationEngine.instance.scheduleAllRemainingPrayerNotifications();

    await prefs.setString(_lastScheduledDateKey, _todayKey());
  }

  Future<Map<String, dynamic>> debugStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduledDate = prefs.getString(_lastScheduledDateKey);

    final todayData = await PrayerNotificationEngine.instance.debugToday();

    return {
      'lastScheduledDate': lastScheduledDate,
      'today': todayData,
    };
  }

  String _todayKey() {
    final now = DateTime.now();

    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }
}