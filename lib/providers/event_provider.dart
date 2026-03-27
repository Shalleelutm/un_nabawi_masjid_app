import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventProvider extends ChangeNotifier {
  static const _kKey = 'offline_events_v1';

  bool loading = true;
  final List<Map<String, dynamic>> items = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);

    items.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      items.addAll(list);
    }

    loading = false;
    notifyListeners();
  }

  Future<void> addEvent(Map<String, dynamic> e) async {
    items.insert(0, e);
    await _save();
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(items));
  }
}