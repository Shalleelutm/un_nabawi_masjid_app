import 'prayer_time_service.dart';
import 'local_notification_service.dart';

class IntelligentAdhanService {
  IntelligentAdhanService._();

  static final IntelligentAdhanService instance = IntelligentAdhanService._();

  Future<void> scheduleAdhan() async {
    final now = DateTime.now();
    final today = PrayerTimeService.instance.forDate(now);

    if (today == null) return;

    await _schedule('Fajr', now.add(const Duration(seconds: 10)), 101);
    await _schedule('Dhuhr', now.add(const Duration(seconds: 20)), 102);
    await _schedule('Asr', now.add(const Duration(seconds: 30)), 103);
    await _schedule('Maghrib', now.add(const Duration(seconds: 40)), 104);
    await _schedule('Isha', now.add(const Duration(seconds: 50)), 105);
  }

  Future<void> _schedule(String name, DateTime time, int id) async {
    await LocalNotificationService.instance.scheduleOne(
      id: id,
      title: 'Adhan Time',
      body: '$name prayer time',
      when: time,
      channelId: 'adhan',
      channelName: 'Adhan Notifications',
    );
  }
}