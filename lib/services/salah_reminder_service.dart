import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';

class SalahReminderService {
  SalahReminderService._();

  static const String _storageKey = 'salah_reminders_v1';

  static Future<List<SalahReminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      return [];
    }

    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;

    return list
        .map((e) => SalahReminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveReminders(List<SalahReminder> list) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      list.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> addReminder(SalahReminder r) async {
    final list = await loadReminders();

    list.add(r);

    await saveReminders(list);

    await LocalNotificationService.instance.scheduleOne(
      id: r.id,
      title: 'Salah Reminder 🕌',
      body: '${r.prayerName} ${r.offsetLabel}',
      when: r.time,
      channelId: 'salah_reminder',
      channelName: 'Salah Reminders',
    );
  }

  static Future<void> removeReminder(int id) async {
    final list = await loadReminders();

    list.removeWhere((e) => e.id == id);

    await saveReminders(list);

    await LocalNotificationService.instance.cancel(id);
  }
}

class SalahReminder {
  final int id;
  final String prayerName;
  final DateTime time;
  final String offsetLabel;

  const SalahReminder({
    required this.id,
    required this.prayerName,
    required this.time,
    required this.offsetLabel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayerName': prayerName,
      'time': time.toIso8601String(),
      'offsetLabel': offsetLabel,
    };
  }

  factory SalahReminder.fromJson(Map<String, dynamic> json) {
    return SalahReminder(
      id: json['id'] as int,
      prayerName: json['prayerName'] as String,
      time: DateTime.parse(json['time'] as String),
      offsetLabel: json['offsetLabel'] as String,
    );
  }
}