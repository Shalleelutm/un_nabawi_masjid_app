import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dues_member_model.dart';
import '../models/dues_payment_model.dart';
import '../models/dues_settings_model.dart';

class DuesService {
  DuesService._();
  static final instance = DuesService._();

  static const _kSettings = 'dues_settings_v1';
  static const _kMembers = 'dues_members_v1';
  static const _kPayments = 'dues_payments_v1';

  Future<DuesSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettings);
    if (raw == null || raw.trim().isEmpty) return DuesSettingsModel.defaults();
    try {
      return DuesSettingsModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return DuesSettingsModel.defaults();
    }
  }

  Future<void> saveSettings(DuesSettingsModel s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, jsonEncode(s.toJson()));
  }

  Future<List<DuesMemberModel>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMembers);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final out = list.map(DuesMemberModel.fromJson).toList();
      out.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMembers(List<DuesMemberModel> members) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = members.map((e) => e.toJson()).toList();
    await prefs.setString(_kMembers, jsonEncode(payload));
  }

  Future<List<DuesPaymentModel>> loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPayments);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final out = list.map(DuesPaymentModel.fromJson).toList();
      out.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> savePayments(List<DuesPaymentModel> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = payments.map((e) => e.toJson()).toList();
    await prefs.setString(_kPayments, jsonEncode(payload));
  }

  // ---- Helpers ----

  String monthKeyOf(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  List<String> monthKeysBetweenInclusive(DateTime start, DateTime end) {
    final a = DateTime(start.year, start.month, 1);
    final b = DateTime(end.year, end.month, 1);

    final keys = <String>[];
    var cursor = a;
    while (!cursor.isAfter(b)) {
      keys.add(monthKeyOf(cursor));
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return keys;
  }

  int monthlyFeeFor(DuesSettingsModel settings, DuesMemberModel m) {
    return m.type == DuesMemberType.elder
        ? settings.monthlyFeeElder
        : settings.monthlyFeeRegular;
  }

  Future<int> totalDueForMemberUpToNow(DuesMemberModel m) async {
    final settings = await loadSettings();
    final now = DateTime.now();
    final keys = monthKeysBetweenInclusive(m.joinDate, now);
    return keys.length * monthlyFeeFor(settings, m);
  }

  Future<int> totalPaidForMember(DuesMemberModel m) async {
    final payments = await loadPayments();
    return payments
        .where((p) => p.memberId == m.id && p.status == DuesPaymentStatus.confirmed)
        .fold<int>(0, (sum, p) => sum + p.amount);
  }

  Future<int> balanceForMember(DuesMemberModel m) async {
    final due = await totalDueForMemberUpToNow(m);
    final paid = await totalPaidForMember(m);
    return due - paid; // positive = owes, negative = ahead
  }

  Future<List<DuesPaymentModel>> paymentsForMember(String memberId) async {
    final payments = await loadPayments();
    return payments.where((p) => p.memberId == memberId).toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
  }
}