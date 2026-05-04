import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = Provider.of<NotificationSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
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
                'Toggle notifications on/off. Your preferences are saved automatically.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // ✅ PRAYER REMINDERS (WITH ICON)
          SwitchListTile(
            secondary: const Icon(Icons.mosque, color: Colors.green), // 🕌
            title: const Text('Prayer Reminders'),
            subtitle: const Text('Get notified when prayer times begin'),
            value: provider.prayerNotificationsEnabled,
            onChanged: (value) => provider.setPrayerNotificationsEnabled(value),
            activeThumbColor: Colors.green, // ✅ FIXED: activeColor → activeThumbColor
          ),
          
          const Divider(),
          
          // ✅ ANNOUNCEMENTS (WITH ICON)
          SwitchListTile(
            secondary: const Icon(Icons.campaign, color: Colors.orange), // 📢
            title: const Text('Announcements'),
            subtitle: const Text('Events, schedule changes, community news'),
            value: provider.announcementNotificationsEnabled,
            onChanged: (value) => provider.setAnnouncementNotificationsEnabled(value),
            activeThumbColor: Colors.green, // ✅ FIXED: activeColor → activeThumbColor
          ),
          
          const Divider(),
          
          // ✅ CHAT MESSAGES (WITH ICON)
          SwitchListTile(
            secondary: const Icon(Icons.chat_bubble, color: Colors.blue), // 💬
            title: const Text('Chat Messages'),
            subtitle: const Text('Get notified when you receive new messages'),
            value: provider.chatNotificationsEnabled,
            onChanged: (value) => provider.setChatNotificationsEnabled(value),
            activeThumbColor: Colors.green, // ✅ FIXED: activeColor → activeThumbColor
          ),
          
          const Divider(),
          
          // ✅ EVENT UPDATES (WITH ICON)
          SwitchListTile(
            secondary: const Icon(Icons.event, color: Colors.purple), // 📅
            title: const Text('Event Updates'),
            subtitle: const Text('Stay informed about upcoming events'),
            value: provider.eventNotificationsEnabled,
            onChanged: (value) => provider.setEventNotificationsEnabled(value),
            activeThumbColor: Colors.green, // ✅ FIXED: activeColor → activeThumbColor
          ),
          
          const SizedBox(height: 20),
          
          // Info card about notification behavior
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications are delivered instantly when you\'re online. '
                    'You can change these settings anytime.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}