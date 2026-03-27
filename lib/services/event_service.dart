import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EventService {
  EventService._();

  static const _kKey = 'offline_events_v1';

  static Future<List<Map<String, dynamic>>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> add({
    required String title,
    required String body,
    required DateTime when,
    required String createdBy,
  }) async {
    final items = await list();
    items.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'when': when.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(items));
  }
}