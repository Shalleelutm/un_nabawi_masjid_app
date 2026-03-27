import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String generalChannelId = 'general_notifications';
  static const String prayerChannelId = 'prayer_notifications';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initSettings);

    final androidPlatform =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlatform?.requestNotificationsPermission();

    await androidPlatform?.createNotificationChannel(
      const AndroidNotificationChannel(
        generalChannelId,
        'General Notifications',
        description: 'General announcements and app notifications',
        importance: Importance.high,
      ),
    );

    await androidPlatform?.createNotificationChannel(
      const AndroidNotificationChannel(
        prayerChannelId,
        'Prayer Notifications',
        description: 'Scheduled prayer alerts',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<void> showNow({
    int? notificationId,
    required String title,
    required String body,
    String channelId = generalChannelId,
    String? payload,
  }) async {
    await init();

    await _plugin.show(
      notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == prayerChannelId
              ? 'Prayer Notifications'
              : 'General Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String channelId = generalChannelId,
    String? payload,
  }) async {
    await showNow(
      notificationId: id,
      title: title,
      body: body,
      channelId: channelId,
      payload: payload,
    );
  }

  Future<void> scheduleOne({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    String channelId = prayerChannelId,
    String channelName = 'Prayer Notifications',
    String? payload,
  }) async {
    await init();

    if (!when.isAfter(DateTime.now())) return;

    final scheduled = tz.TZDateTime.from(when, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // fallback if exact alarms are not allowed (Android 13+ emulator)
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String channelId = prayerChannelId,
    String? payload,
  }) async {
    await scheduleOne(
      id: id,
      when: scheduledAt,
      title: title,
      body: body,
      channelId: channelId,
      channelName: channelId == prayerChannelId
          ? 'Prayer Notifications'
          : 'General Notifications',
      payload: payload,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllPrayerNotifications() async {
    await init();
    for (var i = 1000; i <= 2999; i++) {
      await _plugin.cancel(i);
    }
  }

  Future<List<PendingNotificationRequest>> pending() async {
    return _plugin.pendingNotificationRequests();
  }
}