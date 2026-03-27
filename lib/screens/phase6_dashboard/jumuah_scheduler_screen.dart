import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';
import '../../services/prayer_notification_service.dart';

class JumuahSchedulerScreen extends StatefulWidget {
  const JumuahSchedulerScreen({super.key});

  @override
  State<JumuahSchedulerScreen> createState() => _JumuahSchedulerScreenState();
}

class _JumuahSchedulerScreenState extends State<JumuahSchedulerScreen> {
  static const _kTimeH = 'jumuah_time_h_v1';
  static const _kTimeM = 'jumuah_time_m_v1';
  static const _kEnabled = 'jumuah_enabled_v1';

  TimeOfDay time = const TimeOfDay(hour: 10, minute: 30);
  bool enabled = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final h = prefs.getInt(_kTimeH);
    final m = prefs.getInt(_kTimeM);
    final e = prefs.getBool(_kEnabled);

    if (!mounted) return;

    setState(() {
      if (h != null && m != null) {
        time = TimeOfDay(hour: h, minute: m);
      }
      enabled = e ?? true;
      loading = false;
    });
  }

  Future<void> _saveAndSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_kTimeH, time.hour);
    await prefs.setInt(_kTimeM, time.minute);
    await prefs.setBool(_kEnabled, enabled);

    if (!enabled) {
      await PrayerNotificationService.instance.cancelJumuah();

      if (!mounted) return;
      UIFeedback.successSnack(context, 'Jumu’ah reminder disabled.');
      return;
    }

    final now = DateTime.now();
    final todayReminder = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    int daysUntilFriday = (DateTime.friday - now.weekday) % 7;

    DateTime first = todayReminder.add(Duration(days: daysUntilFriday));

    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 7));
    }

    final second = first.add(const Duration(minutes: 30));

    await PrayerNotificationService.instance.cancelJumuah();
    await PrayerNotificationService.instance.scheduleWeeklyJumuah(
      first: first,
      second: second,
    );

    if (!mounted) return;

    UIFeedback.successSnack(context, 'Weekly Jumu’ah reminder scheduled.');
    UIFeedback.showConfetti(context);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (picked == null || !mounted) return;

    setState(() {
      time = picked;
    });
  }

  String _fmt(TimeOfDay value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jumu’ah Scheduler'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Weekly reminder every Friday. First alert uses your selected time. A second alert is scheduled 30 minutes later.',
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: enabled,
            title: const Text('Enable Jumu’ah Reminder'),
            subtitle: const Text('Schedules recurring local reminders'),
            onChanged: (value) => setState(() => enabled = value),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(_fmt(time)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickTime,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveAndSchedule,
            child: const Text('Save & Schedule'),
          ),
        ],
      ),
    );
  }
}