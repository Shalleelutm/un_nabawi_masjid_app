import 'package:flutter/material.dart';
import '../../services/notification_test_service.dart';

class NotificationTestLabScreen extends StatefulWidget {
  const NotificationTestLabScreen({super.key});

  @override
  State<NotificationTestLabScreen> createState() =>
      _NotificationTestLabScreenState();
}

class _NotificationTestLabScreenState
    extends State<NotificationTestLabScreen> {
  bool sending = false;

  Future<void> _run(Future<void> Function() task) async {
    if (sending) return;

    setState(() {
      sending = true;
    });

    try {
      await task();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification test sent')),
      );
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test Lab'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Instant Notification Test'),
            onTap: () {
              _run(() {
                return NotificationTestService.sendInstantTest(
                  title: 'Masjid Test',
                  body: 'Notification system working',
                );
              });
            },
          ),
          ListTile(
            title: const Text('Prayer Change Test'),
            onTap: () {
              _run(() {
                return NotificationTestService.sendPrayerChangePreview(
                  prayerName: 'Asr',
                  oldTime: '15:25',
                  newTime: '15:30',
                );
              });
            },
          ),
        ],
      ),
    );
  }
}