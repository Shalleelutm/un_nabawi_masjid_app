import 'prayer_time_service.dart';

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

class NextPrayerResult {
  final PrayerMoment current;
  final Duration remaining;

  const NextPrayerResult({
    required this.current,
    required this.remaining,
  });
}

class NextPrayerService {
  static String nextPrayer(PrayerDay model, {DateTime? now}) {
    return nextPrayerInfo(model, now: now).current.name;
  }

  static NextPrayerResult nextPrayerInfo(
    PrayerDay model, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final prayers = _momentsForDay(model);

    for (final prayer in prayers) {
      if (prayer.adhan.isAfter(currentTime)) {
        return NextPrayerResult(
          current: prayer,
          remaining: prayer.adhan.difference(currentTime),
        );
      }
    }

    final tomorrowModel = PrayerTimeService.instance.forDate(
      currentTime.add(const Duration(days: 1)),
    );

    if (tomorrowModel != null) {
      final fajr = _momentsForDay(tomorrowModel).first;
      return NextPrayerResult(
        current: fajr,
        remaining: fajr.adhan.difference(currentTime),
      );
    }

    final fallback = prayers.first;
    final nextDayFajr = fallback.adhan.add(const Duration(days: 1));
    final nextDayIqama = fallback.iqama.add(const Duration(days: 1));

    return NextPrayerResult(
      current: PrayerMoment(
        key: fallback.key,
        name: fallback.name,
        adhan: nextDayFajr,
        iqama: nextDayIqama,
      ),
      remaining: nextDayFajr.difference(currentTime),
    );
  }

  static List<PrayerMoment> _momentsForDay(PrayerDay model) {
    DateTime parse(String value) =>
        PrayerTimeService.instance.parseTimeForDate(model.date, value)!;

    return [
      PrayerMoment(
        key: 'fajr',
        name: 'Fajr',
        adhan: parse(model.fajrAdhan),
        iqama: parse(model.fajrIqama),
      ),
      PrayerMoment(
        key: 'zohr',
        name: 'Zohr',
        adhan: parse(model.zohrAdhan),
        iqama: parse(model.zohrIqama),
      ),
      PrayerMoment(
        key: 'asr',
        name: 'Asr',
        adhan: parse(model.asrAdhan),
        iqama: parse(model.asrIqama),
      ),
      PrayerMoment(
        key: 'maghrib',
        name: 'Maghrib',
        adhan: parse(model.maghribAdhan),
        iqama: parse(model.maghribIqama),
      ),
      PrayerMoment(
        key: 'esha',
        name: 'Esha',
        adhan: parse(model.eshaAdhan),
        iqama: parse(model.eshaIqama),
      ),
    ];
  }
}