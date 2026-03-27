import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DonationEntry {
  final String id;
  final String name;
  final double amount;
  final String note;
  final DateTime createdAt;

  DonationEntry({
    required this.id,
    required this.name,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  static DonationEntry fromMap(Map<String, dynamic> m) => DonationEntry(
        id: (m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        amount: (m['amount'] is num) ? (m['amount'] as num).toDouble() : 0.0,
        note: (m['note'] ?? '').toString(),
        createdAt: DateTime.tryParse((m['createdAt'] ?? '').toString()) ??
            DateTime.now(),
      );
}

class DonationService {
  DonationService._();

  static const _kKey = 'donations_v1';

  static Future<List<DonationEntry>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final items = decoded
        .whereType<Map>()
        .map((m) => DonationEntry.fromMap(m.cast<String, dynamic>()))
        .toList();

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> add(DonationEntry e) async {
    final items = await list();
    items.insert(0, e);
    await _save(items);
  }

  static Future<void> remove(String id) async {
    final items = await list();
    items.removeWhere((x) => x.id == id);
    await _save(items);
  }

  static Future<double> total() async {
    final items = await list();
    // ✅ This is pure sync fold => returns double (no FutureOr)
    return items.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  static Future<void> _save(List<DonationEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }
}
