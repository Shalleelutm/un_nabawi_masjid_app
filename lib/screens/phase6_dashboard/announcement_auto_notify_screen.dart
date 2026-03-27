import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';
import '../../providers/auth_provider.dart';
import '../../services/announcement_service.dart';
import '../../services/local_notification_service.dart';

class AnnouncementAutoNotifyScreen extends StatefulWidget {
  const AnnouncementAutoNotifyScreen({super.key});

  @override
  State<AnnouncementAutoNotifyScreen> createState() =>
      _AnnouncementAutoNotifyScreenState();
}

class _AnnouncementAutoNotifyScreenState
    extends State<AnnouncementAutoNotifyScreen>
    with TickerProviderStateMixin {
  static const _kHistory = 'announcement_history_v2';

  final _title = TextEditingController(text: 'Masjid Announcement');
  final _body = TextEditingController();

  bool _loading = false;
  bool _isImportant = false;
  List<Map<String, dynamic>> history = [];

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistory);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      history = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHistory, jsonEncode(history));
  }

  Future<void> _publish() async {
    final t = _title.text.trim();
    final b = _body.text.trim();
    final auth = context.read<AuthProvider>();

    if (t.isEmpty || b.isEmpty) {
      UIFeedback.errorSnack(context, 'Please enter title and message.');
      return;
    }

    setState(() => _loading = true);

    await AnnouncementService.addAnnouncement(
      title: t,
      message: b,
      isImportant: _isImportant,
      createdBy: auth.email.isEmpty ? 'admin' : auth.email,
    );

    await LocalNotificationService.instance.showNow(
      title: t,
      body: b,
    );

    history.insert(0, {
      'title': t,
      'body': b,
      'important': _isImportant,
      'at': DateTime.now().toIso8601String(),
    });

    if (history.length > 50) {
      history = history.take(50).toList();
    }

    await _saveHistory();

    if (!mounted) return;

    setState(() => _loading = false);
    UIFeedback.successSnack(context, 'Announcement published.');
    UIFeedback.showConfetti(context);
    _body.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement Auto-Notify')),
      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _body,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Message'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _isImportant,
                      title: const Text('Important announcement'),
                      onChanged: (v) => setState(() => _isImportant = v),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.notifications_active),
                      label: Text(_loading ? 'Publishing…' : 'Publish'),
                      onPressed: _loading ? null : _publish,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}