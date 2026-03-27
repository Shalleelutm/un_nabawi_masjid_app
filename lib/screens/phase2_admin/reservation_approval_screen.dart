// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';

class ReservationApprovalScreen extends StatefulWidget {
  const ReservationApprovalScreen({super.key});

  @override
  State<ReservationApprovalScreen> createState() =>
      _ReservationApprovalScreenState();
}

class _ReservationApprovalScreenState extends State<ReservationApprovalScreen> {
  static const _kKey = 'offline_reservations_v1';

  bool _loading = true;
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    _items.clear();

    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _items.addAll(list);
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_items));
  }

  Future<void> _setStatus(int i, String status) async {
    _items[i]['status'] = status;
    _items[i]['updatedAt'] = DateTime.now().toIso8601String();

    await _save();
    setState(() {});

    UIFeedback.successSnack(context, 'Reservation marked as $status.');
    UIFeedback.showConfetti(context);
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF0E5E4E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — Reservations Approval'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No reservation requests yet.\nUsers will create them in Phase 7 forms.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = _items[i];
                    final status = (r['status'] ?? 'pending').toString();
                    final title =
                        (r['title'] ?? 'Reservation Request').toString();
                    final requester = (r['requester'] ?? 'Unknown').toString();

                    Color c;
                    IconData icon;

                    switch (status) {
                      case 'approved':
                        c = Colors.green;
                        icon = Icons.check_circle;
                        break;
                      case 'rejected':
                        c = Colors.red;
                        icon = Icons.cancel;
                        break;
                      default:
                        c = Colors.orange;
                        icon = Icons.hourglass_bottom;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor:
                                c.withValues(alpha: 0.15), // FIXED HERE
                            child: Icon(icon, color: c),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'By: $requester\nStatus: ${status.toUpperCase()}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (v) => _setStatus(i, v),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'approved',
                                child: Text('✅ Approve'),
                              ),
                              PopupMenuItem(
                                value: 'rejected',
                                child: Text('❌ Reject'),
                              ),
                              PopupMenuItem(
                                value: 'pending',
                                child: Text('⏳ Pending'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
