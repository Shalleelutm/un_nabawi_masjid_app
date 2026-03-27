import 'local_notification_service.dart';

class NotificationTestService {
  NotificationTestService._();

  static Future<void> sendInstantTest({
    required String title,
    required String body,
  }) async {
    await LocalNotificationService.instance.showNow(
      title: title,
      body: body,
    );
  }

  static Future<void> sendPrayerChangePreview({
    required String prayerName,
    required String oldTime,
    required String newTime,
  }) async {
    await LocalNotificationService.instance.showNow(
      title: 'Prayer Time Updated',
      body: '$prayerName changed from $oldTime to $newTime',
    );
  }

  static Future<void> sendAdhanPreview({
    required String prayerName,
    required String adhanTime,
  }) async {
    await LocalNotificationService.instance.showNow(
      title: '$prayerName Adhan',
      body: 'It is now time for $prayerName at $adhanTime',
    );
  }

  static Future<void> sendIqamaPreview({
    required String prayerName,
    required String iqamaTime,
  }) async {
    await LocalNotificationService.instance.showNow(
      title: '$prayerName Jamaat',
      body: 'Jamaat for $prayerName is at $iqamaTime',
    );
  }
}