import 'prayer_time_service.dart';

class BlockedTimeItem {
  final String name;
  final String reason;
  final DateTime start;
  final DateTime end;

  const BlockedTimeItem({
    required this.name,
    required this.reason,
    required this.start,
    required this.end,
  });
}

class BlockedTimeService {
  Future<List<BlockedTimeItem>> getBlockedTimes({DateTime? date}) async {
    await PrayerTimeService.instance.loadFromAssets();

    final target = date ?? DateTime.now();
    final model = PrayerTimeService.instance.forDate(target);

    if (model == null) return [];

    DateTime? parse(String t) =>
        PrayerTimeService.instance.parseTimeForDate(target, t);

    final fajr = parse(model.fajrAdhan);
    final zohr = parse(model.zohrAdhan);
    final maghrib = parse(model.maghribAdhan);

    if (fajr == null || zohr == null || maghrib == null) {
      return [];
    }

    final sunriseStart = fajr.add(const Duration(hours: 1, minutes: 20));
    final sunriseEnd = sunriseStart.add(const Duration(minutes: 20));

    final zawwaalStart = zohr.subtract(const Duration(minutes: 10));
    final zawwaalEnd = zohr.add(const Duration(minutes: 5));

    final sunsetStart = maghrib.subtract(const Duration(minutes: 10));
    final sunsetEnd = maghrib.add(const Duration(minutes: 5));

    return [
      BlockedTimeItem(
        name: 'After Fajr',
        reason: 'Sunrise forbidden prayer time',
        start: sunriseStart,
        end: sunriseEnd,
      ),
      BlockedTimeItem(
        name: 'Zawwaal',
        reason: 'Sun at zenith',
        start: zawwaalStart,
        end: zawwaalEnd,
      ),
      BlockedTimeItem(
        name: 'Before Maghrib',
        reason: 'Sunset forbidden prayer time',
        start: sunsetStart,
        end: sunsetEnd,
      ),
    ];
  }
}