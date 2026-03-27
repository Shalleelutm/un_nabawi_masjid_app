import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyWisdom {
  final String title;
  final String body;
  final String tag; // dua / sunnah / hadith / tip

  const DailyWisdom({
    required this.title,
    required this.body,
    required this.tag,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'tag': tag,
      };

  static DailyWisdom fromJson(Map<String, dynamic> m) => DailyWisdom(
        title: (m['title'] ?? '').toString(),
        body: (m['body'] ?? '').toString(),
        tag: (m['tag'] ?? '').toString(),
      );
}

class DailyWisdomService {
  DailyWisdomService._();

  static const _kLastDay = 'daily_wisdom_last_day_v1';
  static const _kLastItem = 'daily_wisdom_last_item_v1';

  static final List<DailyWisdom> _pool = [
    const DailyWisdom(
      tag: 'dua',
      title: 'Dua for Ease',
      body: 'Allahumma la sahla illa ma ja‘altahu sahla…',
    ),
    const DailyWisdom(
      tag: 'sunnah',
      title: 'One Sunnah Today',
      body: 'Smile sincerely. It is a charity (sadaqah).',
    ),
    const DailyWisdom(
      tag: 'tip',
      title: 'Masjid Etiquette',
      body: 'Silence phone, walk calmly, keep rows straight.',
    ),
    const DailyWisdom(
      tag: 'hadith',
      title: 'Good Deeds',
      body: 'The most beloved deeds are those done consistently, even if small.',
    ),
    const DailyWisdom(
      tag: 'dua',
      title: 'Protection',
      body: 'A‘udhu bikalimatillahit-tammati min sharri ma khalaq.',
    ),
  ];

  static Future<DailyWisdom> today() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final key = '${now.year}-${now.month}-${now.day}';
    final lastDay = prefs.getString(_kLastDay);

    // Same day -> return cached item
    if (lastDay == key) {
      final raw = prefs.getString(_kLastItem);
      if (raw != null && raw.isNotEmpty) {
        return DailyWisdom.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    }

    // New day -> rotate deterministically using day hash
    final idx = (now.year + now.month * 37 + now.day * 101) % _pool.length;
    final item = _pool[idx];

    await prefs.setString(_kLastDay, key);
    await prefs.setString(_kLastItem, jsonEncode(item.toJson()));

    return item;
  }
}