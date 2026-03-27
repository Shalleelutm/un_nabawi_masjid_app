import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/hadith_model.dart';

class HadithProvider extends ChangeNotifier {
  static const _kKey = 'offline_hadith_pool_v1';

  bool loading = true;
  final List<HadithModel> pool = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);

    pool.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      pool.addAll(list.map(HadithModel.fromJson));
    } else {
      // ✅ Safe starter pool (offline-first)
      pool.addAll(_starterPool());
      await _save();
    }

    loading = false;
    notifyListeners();
  }

  HadithModel getDaily(int dayIndex) {
    if (pool.isEmpty) return _starterPool().first;
    return pool[dayIndex % pool.length];
    }

  Future<void> add(HadithModel h) async {
    pool.insert(0, h);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(pool.map((e) => e.toJson()).toList()));
  }

  static List<HadithModel> _starterPool() => const [
        HadithModel(
          id: 'h1',
          title: 'Actions are by intentions',
          arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
          translation: 'Actions are only by intentions.',
          source: 'Bukhari',
          grade: 'Sahih',
          tags: ['ikhlas', 'niyyah'],
        ),
        HadithModel(
          id: 'h2',
          title: 'Ease and mercy',
          arabic: 'يَسِّرُوا وَلَا تُعَسِّرُوا',
          translation: 'Make things easy and do not make them difficult.',
          source: 'Bukhari & Muslim',
          grade: 'Sahih',
          tags: ['rahmah', 'adab'],
        ),
      ];
}