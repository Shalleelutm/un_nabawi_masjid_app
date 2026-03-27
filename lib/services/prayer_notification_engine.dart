import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class PrayerDaySchedule {
  final DateTime date;
  final String fajrAdhan;
  final String zohrAdhan;
  final String asrAdhan;
  final String maghribAdhan;
  final String eshaAdhan;

  final String? fajrIqama;
  final String? zohrIqama;
  final String? asrIqama;
  final String? maghribIqama;
  final String? eshaIqama;

  const PrayerDaySchedule({
    required this.date,
    required this.fajrAdhan,
    required this.zohrAdhan,
    required this.asrAdhan,
    required this.maghribAdhan,
    required this.eshaAdhan,
    this.fajrIqama,
    this.zohrIqama,
    this.asrIqama,
    this.maghribIqama,
    this.eshaIqama,
  });

  String get dateKey {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime _safeParseDate(String raw) {
    final cleaned = raw
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('\u200e', '')
        .replaceAll('\u200f', '')
        .replaceAll('\ufeff', '');

    try {
      return DateTime.parse(cleaned);
    } catch (_) {
      final parts = cleaned.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]) ?? DateTime.now().year;
        final m = int.tryParse(parts[1]) ?? 1;
        final d = int.tryParse(parts[2]) ?? 1;
        return DateTime(y, m, d);
      }
      return DateTime.now();
    }
  }

  factory PrayerDaySchedule.fromMap(Map<String, dynamic> map) {
    final rawDate = (map['date'] ?? '').toString().trim();

    DateTime date;
    if (rawDate.isNotEmpty) {
      date = _safeParseDate(rawDate);
    } else {
      final month = int.tryParse('${map['month'] ?? 1}') ?? 1;
      final day = int.tryParse('${map['day'] ?? 1}') ?? 1;
      final year =
          int.tryParse('${map['year'] ?? DateTime.now().year}') ??
              DateTime.now().year;
      date = DateTime(year, month, day);
    }

    String read(List<String> keys, {String fallback = '00:00'}) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return fallback;
    }

    String? readNullable(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return null;
    }

    return PrayerDaySchedule(
      date: DateTime(date.year, date.month, date.day),
      fajrAdhan: read(['fajr_adhan', 'fajr_begin', 'fajr']),
      zohrAdhan: read([
        'zohr_adhan',
        'dhuhr_adhan',
        'dhuhr_begin',
        'zohr_begin',
        'dhuhr',
      ]),
      asrAdhan: read(['asr_adhan', 'asr_begin', 'asr']),
      maghribAdhan: read(['maghrib_adhan', 'maghrib_time', 'maghrib']),
      eshaAdhan: read([
        'esha_adhan',
        'isha_adhan',
        'esha_begin',
        'isha_begin',
        'isha',
      ]),
      fajrIqama: readNullable(['fajr_iqama']),
      zohrIqama: readNullable(['zohr_iqama', 'dhuhr_iqama']),
      asrIqama: readNullable(['asr_iqama']),
      maghribIqama: readNullable(['maghrib_iqama']),
      eshaIqama: readNullable(['esha_iqama', 'isha_iqama']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': dateKey,
      'fajr_adhan': fajrAdhan,
      'zohr_adhan': zohrAdhan,
      'asr_adhan': asrAdhan,
      'maghrib_adhan': maghribAdhan,
      'esha_adhan': eshaAdhan,
      'fajr_iqama': fajrIqama,
      'zohr_iqama': zohrIqama,
      'asr_iqama': asrIqama,
      'maghrib_iqama': maghribIqama,
      'esha_iqama': eshaIqama,
    };
  }
}

class PrayerNotificationEngine {
  PrayerNotificationEngine._();

  static final PrayerNotificationEngine instance = PrayerNotificationEngine._();

  static final AndroidNotificationChannel _channel =
      const AndroidNotificationChannel(
    'daily_prayer_channel',
    'Prayer Notifications',
    description: 'Adhan and daily prayer alerts',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  List<PrayerDaySchedule>? _cache;
  bool _initialized = false;

  /// Keep this low so Android never reaches the 500-alarm limit.
  static const int scheduleWindowDays = 7;

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Indian/Mauritius'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> initializeAndSchedule() async {
    await initialize();
    await scheduleAllRemainingPrayerNotifications();
  }

  Future<List<PrayerDaySchedule>> loadSchedules() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/prayer_times.json');
    final decoded = jsonDecode(raw) as List;

    final baseSchedules = decoded
        .map((e) => PrayerDaySchedule.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final overrides = await _loadOverrides();
    final merged = <PrayerDaySchedule>[];

    for (final item in baseSchedules) {
      final override = overrides[item.dateKey];
      if (override != null) {
        merged.add(PrayerDaySchedule.fromMap({...item.toMap(), ...override}));
      } else {
        merged.add(item);
      }
    }

    final overrideOnlyDates = overrides.keys
        .where((dateKey) => !baseSchedules.any((e) => e.dateKey == dateKey));

    for (final dateKey in overrideOnlyDates) {
      merged.add(PrayerDaySchedule.fromMap(overrides[dateKey]!));
    }

    merged.sort((a, b) => a.date.compareTo(b.date));
    _cache = merged;
    return _cache!;
  }

  Future<Map<String, Map<String, dynamic>>> _loadOverrides() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('prayer_timetable_overrides')
          .get();

      final map = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] ?? doc.id).toString();
        map[date] = {...data, 'date': date};
      }
      return map;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Prayer overrides skipped. Using local asset timetable only. Error: $e',
        );
      }
      return {};
    }
  }

  Future<int> scheduleAllRemainingPrayerNotifications() async {
    await initialize();

    await _notifications.cancelAll();

    final schedules = await loadSchedules();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = today.add(const Duration(days: scheduleWindowDays));

    int scheduledCount = 0;

    for (final schedule in schedules) {
      if (schedule.date.isBefore(today)) {
        continue;
      }
      if (schedule.date.isAfter(lastDay)) {
        break;
      }
      scheduledCount += await _scheduleSingleDay(schedule);
    }

    if (kDebugMode) {
      debugPrint(
        'Prayer notifications scheduled for next $scheduleWindowDays days: $scheduledCount',
      );
    }

    return scheduledCount;
  }

  Future<int> _scheduleSingleDay(PrayerDaySchedule day) async {
    final prayers = {
      'Fajr': day.fajrAdhan,
      'Dhuhr': day.zohrAdhan,
      'Asr': day.asrAdhan,
      'Maghrib': day.maghribAdhan,
      'Isha': day.eshaAdhan,
    };

    int count = 0;
    int prayerIndex = 0;

    for (final entry in prayers.entries) {
      final prayerDateTime = _combine(day.date, entry.value);

      if (!prayerDateTime.isAfter(DateTime.now())) {
        prayerIndex++;
        continue;
      }

      final id = _notificationId(day.date, prayerIndex);

      try {
        await _notifications.zonedSchedule(
          id,
          '${entry.key} Adhan',
          'It is now time for ${entry.key} prayer at Un Nabawi Masjid.',
          tz.TZDateTime.from(prayerDateTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        await _notifications.zonedSchedule(
          id,
          '${entry.key} Adhan',
          'It is now time for ${entry.key} prayer at Un Nabawi Masjid.',
          tz.TZDateTime.from(prayerDateTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      count++;
      prayerIndex++;
    }

    return count;
  }

  Future<void> clearCache() async {
    _cache = null;
  }

  Future<void> cancelPrayerNotifications() async {
    await _notifications.cancelAll();
  }

  Future<Map<String, dynamic>> debugToday() async {
    final today = await scheduleForDate(DateTime.now());

    if (today == null) {
      return {
        'found': false,
        'message': 'No prayer timetable found for today.',
      };
    }

    return {
      'found': true,
      'date': today.dateKey,
      'fajr': today.fajrAdhan,
      'dhuhr': today.zohrAdhan,
      'asr': today.asrAdhan,
      'maghrib': today.maghribAdhan,
      'isha': today.eshaAdhan,
    };
  }

  Future<PrayerDaySchedule?> scheduleForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final all = await loadSchedules();

    try {
      return all.firstWhere(
        (e) =>
            e.date.year == normalized.year &&
            e.date.month == normalized.month &&
            e.date.day == normalized.day,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime _combine(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  int _notificationId(DateTime date, int prayerIndex) {
    final datePart = (date.year * 10000) + (date.month * 100) + date.day;
    return int.parse('$datePart$prayerIndex');
  }
}