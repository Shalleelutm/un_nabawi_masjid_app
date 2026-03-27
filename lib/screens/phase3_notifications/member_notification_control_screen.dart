import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_settings_provider.dart';

class MemberNotificationControlScreen extends StatelessWidget {
  const MemberNotificationControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationSettingsProvider provider =
        context.watch<NotificationSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notifications'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable Prayer Notifications'),
            subtitle: const Text('Get automatic adhan and prayer reminders'),
            value: provider.prayerNotificationsEnabled,
            onChanged: (bool value) {
              provider.setPrayerNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Jumuah Reminders'),
            subtitle: const Text('Get Friday khutbah and Jumuah reminders'),
            value: provider.jumuahNotificationsEnabled,
            onChanged: (bool value) {
              provider.setJumuahNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Announcements'),
            subtitle: const Text('Receive community news and important alerts'),
            value: provider.announcementNotificationsEnabled,
            onChanged: (bool value) {
              provider.setAnnouncementNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Event Reminders'),
            subtitle: const Text('Receive reminders for classes and events'),
            value: provider.eventNotificationsEnabled,
            onChanged: (bool value) {
              provider.setEventNotificationsEnabled(value);
            },
          ),
        ],
      ),
    );
  }
}