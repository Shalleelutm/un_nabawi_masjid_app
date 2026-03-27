import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum HelpStatus { pending, approved, rejected, handled }

HelpStatus _parseStatus(String s) {
  switch (s.toLowerCase().trim()) {
    case 'approved':
      return HelpStatus.approved;
    case 'rejected':
      return HelpStatus.rejected;
    case 'handled':
      return HelpStatus.handled;
    default:
      return HelpStatus.pending;
  }
}

String _statusToString(HelpStatus s) {
  switch (s) {
    case HelpStatus.approved:
      return 'approved';
    case HelpStatus.rejected:
      return 'rejected';
    case HelpStatus.handled:
      return 'handled';
    case HelpStatus.pending:
      return 'pending';
  }
}

class HelpRequest {
  final String id;
  final String name;
  final String phone;
  final String message;

  final HelpStatus status;
  final String adminNote;

  final DateTime createdAt;
  final DateTime? updatedAt;

  HelpRequest({
    required this.id,
    required this.name,
    required this.phone,
    required this.message,
    required this.status,
    required this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'message': message,
        'status': _statusToString(status),
        'adminNote': adminNote,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static HelpRequest fromJson(Map<String, dynamic> j) {
    final createdRaw = (j['createdAt'] ?? '').toString();
    DateTime created;
    try {
      created = DateTime.parse(createdRaw);
    } catch (_) {
      created = DateTime.now();
    }

    final updatedRaw = (j['updatedAt'] ?? '').toString();
    DateTime? updated;
    if (updatedRaw.isNotEmpty) {
      try {
        updated = DateTime.parse(updatedRaw);
      } catch (_) {
        updated = null;
      }
    }

    return HelpRequest(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
      status: _parseStatus((j['status'] ?? 'pending').toString()),
      adminNote: (j['adminNote'] ?? '').toString(),
      createdAt: created,
      updatedAt: updated,
    );
  }

  HelpRequest copyWith({
    HelpStatus? status,
    String? adminNote,
    DateTime? updatedAt,
  }) {
    return HelpRequest(
      id: id,
      name: name,
      phone: phone,
      message: message,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommunityHelpService {
  CommunityHelpService._();

  static const _k = 'community_help_requests_v2';

  static Future<List<HelpRequest>> all() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_k);
    raw ??= prefs.getString('community_help_requests_v1');

    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final list = decoded
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList()
          .cast<Map<String, dynamic>>();
      return list.map(HelpRequest.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<HelpRequest> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_k, raw);
  }

  static Future<int> pendingCount() async {
    final items = await all();
    return items.where((e) => e.status == HelpStatus.pending).length;
  }

  static Future<void> submit({
    required String name,
    required String phone,
    required String message,
  }) async {
    final n = name.trim();
    final p = phone.trim();
    final m = message.trim();
    if (n.isEmpty || p.isEmpty || m.isEmpty) return;

    final items = await all();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    items.insert(
      0,
      HelpRequest(
        id: id,
        name: n,
        phone: p,
        message: m,
        status: HelpStatus.pending,
        adminNote: '',
        createdAt: DateTime.now(),
        updatedAt: null,
      ),
    );

    await saveAll(items);
  }

  static Future<void> setStatus(String id, String status) async {
    await setStatusWithNote(
      id: id,
      status: _parseStatus(status),
      adminNote: null,
    );
  }

  static Future<void> setStatusWithNote({
    required String id,
    required HelpStatus status,
    String? adminNote,
  }) async {
    final items = await all();
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final old = items[idx];
    items[idx] = old.copyWith(
      status: status,
      adminNote: adminNote ?? old.adminNote,
      updatedAt: DateTime.now(),
    );

    await saveAll(items);
  }

  static Future<void> deleteById(String id) async {
    final items = await all();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
  }

  static Future<void> clearAll() async {
    await saveAll([]);
  }
}