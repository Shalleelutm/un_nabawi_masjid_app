import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class PrayerDay {
  final DateTime date;
  final String tahajjudLast;
  final String sehriLast;
  final String fajrBegin;
  final String fajrAdhan;
  final String fajrIqama;
  final String zohrBegin;
  final String zohrAdhan;
  final String zohrIqama;
  final String asrBegin;
  final String asrAdhan;
  final String asrIqama;
  final String maghribTime;
  final String maghribAdhan;
  final String maghribIqama;
  final String eshaBegin;
  final String eshaAdhan;
  final String eshaIqama;
  final String forbiddenSunrise;
  final String forbiddenZawwaal;
  final String forbiddenSunset;
  final int month;
  final int day;

  const PrayerDay({
    required this.date,
    required this.tahajjudLast,
    required this.sehriLast,
    required this.fajrBegin,
    required this.fajrAdhan,
    required this.fajrIqama,
    required this.zohrBegin,
    required this.zohrAdhan,
    required this.zohrIqama,
    required this.asrBegin,
    required this.asrAdhan,
    required this.asrIqama,
    required this.maghribTime,
    required this.maghribAdhan,
    required this.maghribIqama,
    required this.eshaBegin,
    required this.eshaAdhan,
    required this.eshaIqama,
    required this.forbiddenSunrise,
    required this.forbiddenZawwaal,
    required this.forbiddenSunset,
    required this.month,
    required this.day,
  });

  factory PrayerDay.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.parse((json['date'] ?? '').toString());

    String read(String key) => (json[key] ?? '').toString().trim();

    return PrayerDay(
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      tahajjudLast: read('tahajjud_last'),
      sehriLast: read('sehri_last'),
      fajrBegin: read('fajr_begin'),
      fajrAdhan: read('fajr_adhan'),
      fajrIqama: read('fajr_iqama'),
      zohrBegin: read('zohr_begin'),
      zohrAdhan: read('zohr_adhan'),
      zohrIqama: read('zohr_iqama'),
      asrBegin: read('asr_begin'),
      asrAdhan: read('asr_adhan'),
      asrIqama: read('asr_iqama'),
      maghribTime: read('maghrib_time'),
      maghribAdhan: read('maghrib_adhan'),
      maghribIqama: read('maghrib_iqama'),
      eshaBegin: read('esha_begin'),
      eshaAdhan: read('esha_adhan'),
      eshaIqama: read('esha_iqama'),
      forbiddenSunrise: read('forbidden_sunrise'),
      forbiddenZawwaal: read('forbidden_zawwaal'),
      forbiddenSunset: read('forbidden_sunset'),
      month: (json['month'] as num?)?.toInt() ?? parsedDate.month,
      day: (json['day'] as num?)?.toInt() ?? parsedDate.day,
    );
  }

  PrayerDay copyWith({
    DateTime? date,
    String? tahajjudLast,
    String? sehriLast,
    String? fajrBegin,
    String? fajrAdhan,
    String? fajrIqama,
    String? zohrBegin,
    String? zohrAdhan,
    String? zohrIqama,
    String? asrBegin,
    String? asrAdhan,
    String? asrIqama,
    String? maghribTime,
    String? maghribAdhan,
    String? maghribIqama,
    String? eshaBegin,
    String? eshaAdhan,
    String? eshaIqama,
    String? forbiddenSunrise,
    String? forbiddenZawwaal,
    String? forbiddenSunset,
    int? month,
    int? day,
  }) {
    return PrayerDay(
      date: date ?? this.date,
      tahajjudLast: tahajjudLast ?? this.tahajjudLast,
      sehriLast: sehriLast ?? this.sehriLast,
      fajrBegin: fajrBegin ?? this.fajrBegin,
      fajrAdhan: fajrAdhan ?? this.fajrAdhan,
      fajrIqama: fajrIqama ?? this.fajrIqama,
      zohrBegin: zohrBegin ?? this.zohrBegin,
      zohrAdhan: zohrAdhan ?? this.zohrAdhan,
      zohrIqama: zohrIqama ?? this.zohrIqama,
      asrBegin: asrBegin ?? this.asrBegin,
      asrAdhan: asrAdhan ?? this.asrAdhan,
      asrIqama: asrIqama ?? this.asrIqama,
      maghribTime: maghribTime ?? this.maghribTime,
      maghribAdhan: maghribAdhan ?? this.maghribAdhan,
      maghribIqama: maghribIqama ?? this.maghribIqama,
      eshaBegin: eshaBegin ?? this.eshaBegin,
      eshaAdhan: eshaAdhan ?? this.eshaAdhan,
      eshaIqama: eshaIqama ?? this.eshaIqama,
      forbiddenSunrise: forbiddenSunrise ?? this.forbiddenSunrise,
      forbiddenZawwaal: forbiddenZawwaal ?? this.forbiddenZawwaal,
      forbiddenSunset: forbiddenSunset ?? this.forbiddenSunset,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }

  String get fingerprint =>
      '${date.toIso8601String()}|$fajrAdhan|$zohrAdhan|$asrAdhan|$maghribAdhan|$eshaAdhan|$fajrIqama|$zohrIqama|$asrIqama|$maghribIqama|$eshaIqama';

  Map<String, String> toPrayerMap() {
    return {
      'Fajr': fajrIqama.isNotEmpty ? fajrIqama : fajrAdhan,
      'Dhuhr': zohrIqama.isNotEmpty ? zohrIqama : zohrAdhan,
      'Asr': asrIqama.isNotEmpty ? asrIqama : asrAdhan,
      'Maghrib': maghribIqama.isNotEmpty ? maghribIqama : maghribAdhan,
      'Isha': eshaIqama.isNotEmpty ? eshaIqama : eshaAdhan,
    };
  }
}

class PrayerTimeService {
  PrayerTimeService._();
  static final PrayerTimeService instance = PrayerTimeService._();

  final Map<String, PrayerDay> _byDate = {};
  bool _loaded = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rulesSub;

  bool get isLoaded => _loaded;

  List<PrayerDay> get all => getAllDays();

  Future<void> loadFromAssets({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;

    final raw = await rootBundle.loadString('assets/prayer_times.json');
    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw Exception('assets/prayer_times.json must contain a JSON array.');
    }

    _byDate.clear();

    for (final item in decoded) {
      if (item is! Map) continue;

      final map = Map<String, dynamic>.from(item);
      final dateValue = (map['date'] ?? '').toString().trim();
      if (dateValue.isEmpty) {
        continue;
      }

      final day = PrayerDay.fromJson(map);
      _byDate[_key(day.date)] = day;
    }

    if (_byDate.isEmpty) {
      throw Exception(
        'No prayer timetable rows were loaded from assets/prayer_times.json',
      );
    }

    await _applyFirestoreGlobalRules();

    _loaded = true;
  }

  Future<void> reloadFromAssets() async {
    _loaded = false;
    await loadFromAssets(forceReload: true);
  }

  Future<void> _applyFirestoreGlobalRules() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mosque_settings')
          .doc('fixed_prayer_rules')
          .get();

      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      final bool zohrFixed = data['zohr_fixed'] == true;
      if (!zohrFixed) return;

      final String zohrAdhan = (data['zohr_adhan'] ?? '').toString().trim();
      final String zohrIqama = (data['zohr_iqama'] ?? '').toString().trim();

      if (zohrAdhan.isEmpty && zohrIqama.isEmpty) return;

      final updated = <String, PrayerDay>{};

      for (final entry in _byDate.entries) {
        final current = entry.value;

        updated[entry.key] = current.copyWith(
          zohrAdhan: zohrAdhan.isNotEmpty ? zohrAdhan : current.zohrAdhan,
          zohrIqama: zohrIqama.isNotEmpty ? zohrIqama : current.zohrIqama,
        );
      }

      _byDate
        ..clear()
        ..addAll(updated);
    } catch (_) {
      // If Firestore is unavailable/offline/error, keep JSON values.
    }
  }

  void startFirestoreRulesAutoReload({
    Future<void> Function()? onRulesChanged,
  }) {
    _rulesSub?.cancel();

    _rulesSub = FirebaseFirestore.instance
        .collection('mosque_settings')
        .doc('fixed_prayer_rules')
        .snapshots()
        .listen((_) async {
      await reloadFromAssets();
      if (onRulesChanged != null) {
        await onRulesChanged();
      }
    });
  }

  Future<void> stopFirestoreRulesAutoReload() async {
    await _rulesSub?.cancel();
    _rulesSub = null;
  }

  List<PrayerDay> getAllDays() {
    final days = _byDate.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return days;
  }

  PrayerDay? forDate(DateTime date) {
    return _byDate[_key(date)];
  }

  PrayerDay? today({DateTime? now}) {
    return forDate(_dateOnly(now ?? DateTime.now()));
  }

  PrayerDay? tomorrow({DateTime? now}) {
    final base = _dateOnly(now ?? DateTime.now());
    return forDate(base.add(const Duration(days: 1)));
  }

  List<PrayerDay> range(DateTime start, DateTime endInclusive) {
    final result = <PrayerDay>[];
    var current = _dateOnly(start);
    final last = _dateOnly(endInclusive);

    while (!current.isAfter(last)) {
      final day = forDate(current);
      if (day != null) result.add(day);
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  List<PrayerDay> forMonth(int year, int month) {
    return getAllDays()
        .where((d) => d.date.year == year && d.date.month == month)
        .toList();
  }

  List<PrayerDay> nextDays({
    DateTime? from,
    required int days,
  }) {
    final start = _dateOnly(from ?? DateTime.now());
    final end = start.add(Duration(days: days - 1));
    return range(start, end);
  }

  DateTime? parseTimeForDate(DateTime baseDate, String hhmm) {
    final value = hhmm.trim();
    if (value.isEmpty || !value.contains(':')) return null;

    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  List<MapEntry<String, DateTime?>> _salahTimesForDay(PrayerDay day) {
    return [
      MapEntry(
        'Fajr',
        parseTimeForDate(
          day.date,
          day.fajrIqama.isNotEmpty ? day.fajrIqama : day.fajrAdhan,
        ),
      ),
      MapEntry(
        'Dhuhr',
        parseTimeForDate(
          day.date,
          day.zohrIqama.isNotEmpty ? day.zohrIqama : day.zohrAdhan,
        ),
      ),
      MapEntry(
        'Asr',
        parseTimeForDate(
          day.date,
          day.asrIqama.isNotEmpty ? day.asrIqama : day.asrAdhan,
        ),
      ),
      MapEntry(
        'Maghrib',
        parseTimeForDate(
          day.date,
          day.maghribIqama.isNotEmpty ? day.maghribIqama : day.maghribAdhan,
        ),
      ),
      MapEntry(
        'Isha',
        parseTimeForDate(
          day.date,
          day.eshaIqama.isNotEmpty ? day.eshaIqama : day.eshaAdhan,
        ),
      ),
    ];
  }

  DateTime? nextPrayerDateTime({DateTime? now}) {
    final current = now ?? DateTime.now();
    final todayEntry = today(now: current);
    final tomorrowEntry = tomorrow(now: current);

    if (todayEntry != null) {
      final todayTimes = _salahTimesForDay(todayEntry);

      for (final pair in todayTimes) {
        final t = pair.value;
        if (t != null && t.isAfter(current)) return t;
      }
    }

    if (tomorrowEntry != null) {
      final tomorrowTimes = _salahTimesForDay(tomorrowEntry);
      return tomorrowTimes.first.value;
    }

    return null;
  }

  String? nextPrayerName({DateTime? now}) {
    final current = now ?? DateTime.now();
    final todayEntry = today(now: current);
    final tomorrowEntry = tomorrow(now: current);

    if (todayEntry != null) {
      final pairs = _salahTimesForDay(todayEntry);

      for (final pair in pairs) {
        if (pair.value != null && pair.value!.isAfter(current)) {
          return pair.key;
        }
      }
    }

    if (tomorrowEntry != null) return 'Fajr';
    return null;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _key(DateTime value) {
    final d = _dateOnly(value);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}