class HijriService {
  HijriService._();

  /// Kuwaiti algorithm (simple civil conversion)
  static String todayHijri() {
    final now = DateTime.now();
    final hijri = _gregorianToHijri(now);
    return '${hijri.day} ${_monthName(hijri.month)} ${hijri.year} AH';
  }

  static _HijriDate _gregorianToHijri(DateTime date) {
    final int day = date.day;
    final int month = date.month;
    final int year = date.year;

    int jd = _julianDay(year, month, day);
    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor());
    l = l -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;

    int m = ((24 * l) / 709).floor();
    int d = l - ((709 * m) / 24).floor();
    int y = 30 * n + j - 30;

    return _HijriDate(day: d, month: m, year: y);
  }

  static int _julianDay(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524;
  }

  static String _monthName(int m) {
    switch (m) {
      case 1:
        return 'Muharram';
      case 2:
        return 'Safar';
      case 3:
        return 'Rabi al-Awwal';
      case 4:
        return 'Rabi al-Thani';
      case 5:
        return 'Jumada al-Awwal';
      case 6:
        return 'Jumada al-Thani';
      case 7:
        return 'Rajab';
      case 8:
        return "Sha'ban";
      case 9:
        return 'Ramadan';
      case 10:
        return 'Shawwal';
      case 11:
        return "Dhu al-Qi'dah";
      case 12:
        return 'Dhu al-Hijjah';
      default:
        return 'Hijri';
    }
  }
}

class _HijriDate {
  final int day;
  final int month;
  final int year;

  _HijriDate({
    required this.day,
    required this.month,
    required this.year,
  });
}
