import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberProvider extends ChangeNotifier {
  static const _kKey = 'offline_members_v1';

  bool loading = true;
  final List<Map<String, dynamic>> members = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);

    members.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      members.addAll(list);
    }

    loading = false;
    notifyListeners();
  }

  Future<void> upsertMember(Map<String, dynamic> m) async {
    final id = (m['id'] ?? '').toString();
    final idx = members.indexWhere((e) => (e['id'] ?? '').toString() == id);

    if (idx >= 0) {
      members[idx] = m;
    } else {
      members.insert(0, m);
    }

    await _save();
    notifyListeners();
  }

  Future<void> removeMember(String id) async {
    members.removeWhere((e) => (e['id'] ?? '').toString() == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(members));
  }
}