import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/hadith_model.dart';

class HadithService {
  HadithService._();

  static const _kKey = 'offline_hadith_pool_v1';

  static Future<List<HadithModel>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(HadithModel.fromJson).toList();
  }

  static Future<void> add(HadithModel h) async {
    final all = await list();
    all.insert(0, h);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }
}