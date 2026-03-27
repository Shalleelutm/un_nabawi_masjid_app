import 'package:intl/intl.dart';

class PrayerMoment {
  final String key;
  final String name;
  final DateTime adhan;
  final DateTime iqama;

  const PrayerMoment({
    required this.key,
    required this.name,
    required this.adhan,
    required this.iqama,
  });
}

class PrayerTimeModel {
  final DateTime date;

  final DateTime fajrBegin;
  final DateTime fajrAdhan;
  final DateTime fajrIqama;

  final DateTime zohrBegin;
  final DateTime zohrAdhan;
  final DateTime zohrIqama;

  final DateTime asrBegin;
  final DateTime asrAdhan;
  final DateTime asrIqama;

  final DateTime maghribTime;
  final DateTime maghribAdhan;
  final DateTime maghribIqama;

  final DateTime eshaBegin;
  final DateTime eshaAdhan;
  final DateTime eshaIqama;

  final DateTime? tahajjudLast;
  final DateTime? sehriLast;
  final DateTime? jumuah1;
  final DateTime? jumuah2;

  final String forbiddenSunrise;
  final String forbiddenZawwaal;
  final String forbiddenSunset;

  const PrayerTimeModel({
    required this.date,
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
    this.tahajjudLast,
    this.sehriLast,
    this.jumuah1,
    this.jumuah2,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final date = _parseDate(json['date']);

    return PrayerTimeModel(
      date: date,
      tahajjudLast: _parseTimeOrNull(date, json['tahajjud_last']),
      sehriLast: _parseTimeOrNull(date, json['sehri_last']),
      fajrBegin: _parseTime(date, json['fajr_begin']),
      fajrAdhan: _parseTime(date, json['fajr_adhan']),
      fajrIqama: _parseTime(date, json['fajr_iqama']),
      zohrBegin: _parseTime(date, json['zohr_begin']),
      zohrAdhan: _parseTime(date, json['zohr_adhan']),
      zohrIqama: _parseTime(date, json['zohr_iqama']),
      asrBegin: _parseTime(date, json['asr_begin']),
      asrAdhan: _parseTime(date, json['asr_adhan']),
      asrIqama: _parseTime(date, json['asr_iqama']),
      maghribTime: _parseTime(date, json['maghrib_time']),
      maghribAdhan: _parseTime(date, json['maghrib_adhan']),
      maghribIqama: _parseTime(date, json['maghrib_iqama']),
      eshaBegin: _parseTime(date, json['esha_begin']),
      eshaAdhan: _parseTime(date, json['esha_adhan']),
      eshaIqama: _parseTime(date, json['esha_iqama']),
      jumuah1: _parseTimeOrNull(date, json['jumuah_1']),
      jumuah2: _parseTimeOrNull(date, json['jumuah_2']),
      forbiddenSunrise: (json['forbidden_sunrise'] ?? '').toString(),
      forbiddenZawwaal: (json['forbidden_zawwaal'] ?? '').toString(),
      forbiddenSunset: (json['forbidden_sunset'] ?? '').toString(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    final raw = value.toString().trim();
    try {
      return DateTime.parse(raw);
    } catch (_) {}

    final parts = raw.split('-');
    if (parts.length == 3) {
      try {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {}
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _parseTime(DateTime base, dynamic value) {
    final parsed = _parseTimeOrNull(base, value);
    return parsed ?? base;
  }

  static DateTime? _parseTimeOrNull(DateTime base, dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    try {
      return DateTime.parse(raw);
    } catch (_) {}

    for (final pattern in const ['HH:mm', 'H:mm']) {
      try {
        final t = DateFormat(pattern).parseStrict(raw);
        return DateTime(base.year, base.month, base.day, t.hour, t.minute);
      } catch (_) {}
    }

    return null;
  }

  List<PrayerMoment> get prayers => [
        PrayerMoment(
          key: 'fajr',
          name: 'Fajr',
          adhan: fajrAdhan,
          iqama: fajrIqama,
        ),
        PrayerMoment(
          key: 'dhuhr',
          name: 'Dhuhr',
          adhan: zohrAdhan,
          iqama: zohrIqama,
        ),
        PrayerMoment(
          key: 'asr',
          name: 'Asr',
          adhan: asrAdhan,
          iqama: asrIqama,
        ),
        PrayerMoment(
          key: 'maghrib',
          name: 'Maghrib',
          adhan: maghribAdhan,
          iqama: maghribIqama,
        ),
        PrayerMoment(
          key: 'isha',
          name: 'Isha',
          adhan: eshaAdhan,
          iqama: eshaIqama,
        ),
      ];

  PrayerMoment prayerByKey(String key) {
    return prayers.firstWhere(
      (p) => p.key == key.toLowerCase(),
      orElse: () => prayers.first,
    );
  }

  DateTime adhanDateTime(String prayer) => prayerByKey(prayer).adhan;

  DateTime iqamaDateTime(String prayer) => prayerByKey(prayer).iqama;

  DateTime timeOn(String prayer) => prayerByKey(prayer).adhan;

  DateTime? timeOnOrNull(String prayer) {
    try {
      return prayerByKey(prayer).adhan;
    } catch (_) {
      return null;
    }
  }

  DateTime get fajr => fajrAdhan;
  DateTime get dhuhr => zohrAdhan;
  DateTime get asr => asrAdhan;
  DateTime get maghrib => maghribAdhan;
  DateTime get isha => eshaAdhan;

  Map<String, String> notificationFingerprint() {
    String fmt(DateTime value) => DateFormat('HH:mm').format(value);

    return {
      'fajr_adhan': fmt(fajrAdhan),
      'fajr_iqama': fmt(fajrIqama),
      'zohr_adhan': fmt(zohrAdhan),
      'zohr_iqama': fmt(zohrIqama),
      'asr_adhan': fmt(asrAdhan),
      'asr_iqama': fmt(asrIqama),
      'maghrib_adhan': fmt(maghribAdhan),
      'maghrib_iqama': fmt(maghribIqama),
      'esha_adhan': fmt(eshaAdhan),
      'esha_iqama': fmt(eshaIqama),
    };
  }

  String fingerprintString() {
    final map = notificationFingerprint();
    final keys = map.keys.toList()..sort();
    return keys.map((k) => '$k=${map[k]}').join('|');
  }
}