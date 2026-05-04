import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HijriScreen extends StatefulWidget {
  const HijriScreen({super.key});

  @override
  State<HijriScreen> createState() => _HijriScreenState();
}

class _HijriScreenState extends State<HijriScreen> {
  DateTime selectedDate = DateTime.now();

  void nextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  Map<String, int> _gregorianToHijri(DateTime date) {
    final jd = _julianDay(date.year, date.month, date.day);

    int l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();

    l = l - 10631 * n + 354;

    final j = (((10985 - l) / 5316).floor()) *
            (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor());

    l = l -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;

    final month = ((24 * l) / 709).floor();
    final day = l - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    return {
      'day': day,
      'month': month,
      'year': year,
    };
  }

  int _julianDay(int year, int month, int day) {
    var y = year;
    var m = month;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;
  }

  String _hijriMonthName(int month) {
    const months = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    if (month < 1 || month > 12) return 'Hijri';
    return months[month - 1];
  }

  String _getIslamicEvent(int month, int day) {
    final events = {
      '1-1': 'Islamic New Year',
      '10-1': 'Day of Ashura',
      '27-7': 'Isra and Mi\'raj',
      '15-8': 'Mid-Sha\'ban',
      '1-9': 'First day of Ramadan',
      '27-9': 'Laylat al-Qadr',
      '1-10': 'Eid al-Fitr',
      '9-12': 'Day of Arafah',
      '10-12': 'Eid al-Adha',
    };

    return events['$day-$month'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final hijri = _gregorianToHijri(selectedDate);
    final day = hijri['day'] ?? 1;
    final month = hijri['month'] ?? 1;
    final year = hijri['year'] ?? 1447;
    final event = _getIslamicEvent(month, day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijri Calendar'),
        backgroundColor: const Color(0xFF007A3D),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F2EA),
              Color(0xFFEFF7F2),
              Color(0xFFFBEFF1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const Divider(height: 34),
                    Text(
                      '$day ${_hijriMonthName(month)} $year AH',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF007A3D),
                      ),
                    ),
                    if (event.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007A3D).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                const Color(0xFF007A3D).withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: Color(0xFF007A3D)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                event,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007A3D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: previousDay,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous Day'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: nextDay,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next Day'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime.now();
                  });
                },
                icon: const Icon(Icons.today),
                label: const Text('Back to Today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}