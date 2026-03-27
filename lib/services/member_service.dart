import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/member_model.dart';

class MemberService {
  MemberService._();

  static const _kKey = 'members_v1';

  static Future<List<MemberModel>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final items = decoded
        .whereType<Map>()
        .map((m) => MemberModel.fromMap(m.cast<String, dynamic>()))
        .toList();

    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  static Future<void> upsert(MemberModel m) async {
    final items = await list();
    final idx = items.indexWhere((x) => x.id == m.id);
    if (idx >= 0) {
      items[idx] = m.copyWith(updatedAt: DateTime.now());
    } else {
      items.insert(0, m);
    }
    await _save(items);
  }

  static Future<MemberModel> create({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String pin,
    double initialBalanceDue = 0,
  }) async {
    final now = DateTime.now();
    final m = MemberModel(
      id: const Uuid().v4(),
      username: username.trim(),
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      isActive: true,
      isBlocked: false,
      balanceDue: initialBalanceDue,
      isPaid: initialBalanceDue <= 0,
      pin: pin.trim().isEmpty ? '0000' : pin.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await upsert(m);
    return m;
  }

  static Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((x) => x.id == id);
    await _save(items);
  }

  static Future<MemberModel?> login(String username, String pin) async {
    final items = await list();
    final u = username.trim().toLowerCase();
    final found = items.firstWhere(
      (m) => m.username.trim().toLowerCase() == u,
      orElse: () => MemberModel(
        id: '',
        username: '',
        fullName: '',
        email: '',
        phone: '',
        isActive: false,
        isBlocked: false,
        balanceDue: 0,
        isPaid: false,
        pin: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (found.id.isEmpty) return null;
    if (found.isBlocked) return null;
    if (found.pin != pin.trim()) return null;

    return found;
  }

  static Future<void> setPaidStatus(String id, bool paid) async {
    final items = await list();
    final idx = items.indexWhere((x) => x.id == id);
    if (idx < 0) return;
    final current = items[idx];
    items[idx] = current.copyWith(
      isPaid: paid,
      balanceDue: paid ? 0 : current.balanceDue,
      updatedAt: DateTime.now(),
    );
    await _save(items);
  }

  static Future<void> setBlocked(String id, bool blocked) async {
    final items = await list();
    final idx = items.indexWhere((x) => x.id == id);
    if (idx < 0) return;
    items[idx] =
        items[idx].copyWith(isBlocked: blocked, updatedAt: DateTime.now());
    await _save(items);
  }

  static Future<void> setBalance(String id, double balance) async {
    final items = await list();
    final idx = items.indexWhere((x) => x.id == id);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(
      balanceDue: balance,
      isPaid: balance <= 0,
      updatedAt: DateTime.now(),
    );
    await _save(items);
  }

  static Future<void> _save(List<MemberModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }
}
