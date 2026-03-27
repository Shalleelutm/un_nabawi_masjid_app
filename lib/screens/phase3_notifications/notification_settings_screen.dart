// FILE: lib/screens/phase3_notifications/notification_settings_screen.dart
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool adhanEnabled = true;
  bool quranEnabled = true;
  bool hadithEnabled = true;
  bool announcementsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
            child: const ListTile(
              title: Text(
                'Control which alerts you receive',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'Local-only for now. Later we connect to Firebase & admin panel.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Adhan Reminders'),
            subtitle: const Text('Play Adhan sound or alert before prayer'),
            value: adhanEnabled,
            onChanged: (v) => setState(() => adhanEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Daily Quran Reminder'),
            subtitle: const Text('Ayah / short recitation reminder'),
            value: quranEnabled,
            onChanged: (v) => setState(() => quranEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Daily Hadith Reminder'),
            subtitle: const Text('Short authentic reminder'),
            value: hadithEnabled,
            onChanged: (v) => setState(() => hadithEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Announcements'),
            subtitle: const Text('Events, schedule changes, community news'),
            value: announcementsEnabled,
            onChanged: (v) => setState(() => announcementsEnabled = v),
          ),
        ],
      ),
    );
  }
}