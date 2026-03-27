import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';

class PrayerEditorScreen extends StatefulWidget {
  const PrayerEditorScreen({super.key});

  @override
  State<PrayerEditorScreen> createState() => _PrayerEditorScreenState();
}

class _PrayerEditorScreenState extends State<PrayerEditorScreen> {
  static const _kKey = 'official_prayer_times_v1';

  final Map<String, TimeOfDay> _times = {
    'Fajr': const TimeOfDay(hour: 5, minute: 0),
    'Sunrise': const TimeOfDay(hour: 6, minute: 15),
    'Dhuhr': const TimeOfDay(hour: 12, minute: 10),
    'Asr': const TimeOfDay(hour: 15, minute: 30),
    'Maghrib': const TimeOfDay(hour: 18, minute: 5),
    'Isha': const TimeOfDay(hour: 19, minute: 25),
    'Tahajjud': const TimeOfDay(hour: 3, minute: 30),
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final v = entry.value as String;
        final parts = v.split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          _times[entry.key] = TimeOfDay(hour: h, minute: m);
        }
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, String>{};
    for (final e in _times.entries) {
      map[e.key] = _fmt(e.value);
    }
    await prefs.setString(_kKey, jsonEncode(map));
    if (!mounted) return;
    UIFeedback.successSnack(context, 'Official prayer timetable saved.');
    UIFeedback.showConfetti(context);
  }

  Future<void> _pick(String key) async {
    final current = _times[key]!;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    setState(() => _times[key] = picked);
  }

  String _fmt(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF0E5E4E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — Prayer Timetable'),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save),
            onPressed: _loading ? null : _save,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Official Masjid Times (Offline-first)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'These times override calculated times later.\nUsed for notifications after Phase 3/4.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._times.entries.map((e) {
                  final isSpecial = e.key == 'Sunrise' || e.key == 'Tahajjud';
                  final icon = e.key == 'Fajr'
                      ? Icons.wb_twilight
                      : e.key == 'Dhuhr'
                          ? Icons.wb_sunny_outlined
                          : e.key == 'Asr'
                              ? Icons.wb_cloudy_outlined
                              : e.key == 'Maghrib'
                                  ? Icons.nights_stay_outlined
                                  : e.key == 'Isha'
                                      ? Icons.dark_mode_outlined
                                      : isSpecial
                                          ? Icons.auto_awesome
                                          : Icons.access_time;

                  final color = isSpecial ? Colors.deepPurple : primaryGreen;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.14),
                        child: Icon(icon, color: color),
                      ),
                      title: Text(
                        e.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Time: ${_fmt(e.value)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _pick(e.key),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Timetable'),
                  onPressed: _save,
                ),
              ],
            ),
    );
  }
}
