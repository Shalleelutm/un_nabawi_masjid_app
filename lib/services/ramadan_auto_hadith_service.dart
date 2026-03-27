import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';

class RamadanAutoHadithService {
  static const String _kRamadanScheduled = 'ramadan_hadith_scheduled_v1';

  static Future<void> scheduleRamadanHadiths() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_kRamadanScheduled) == true) {
      return;
    }

    final raw = await rootBundle.loadString('assets/ramadan_hadith.json');
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;

    final now = DateTime.now();

    for (int i = 0; i < list.length; i++) {
      final day = now.add(Duration(days: i));

      final scheduled = DateTime(
        day.year,
        day.month,
        day.day,
        6,
        10,
      );

      final item = list[i] as Map<String, dynamic>;

      await LocalNotificationService.instance.scheduleOne(
        id: 9000 + i,
        title: 'Ramadan Day ${i + 1}',
        body: (item['text'] ?? '').toString(),
        when: scheduled,
        channelId: 'ramadan_daily',
        channelName: 'Ramadan Hadith',
      );
    }

    await prefs.setBool(_kRamadanScheduled, true);
  }
}