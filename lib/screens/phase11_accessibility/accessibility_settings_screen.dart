import 'package:flutter/material.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Settings')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primary.withValues(alpha: 0.14),
                child: Icon(Icons.visibility_rounded, color: cs.primary),
              ),
              title: const Text('High Contrast'),
              subtitle: const Text('Coming soon (safe offline-first).'),
              trailing: const Icon(Icons.lock_outline_rounded),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.14),
                child: const Icon(Icons.record_voice_over_rounded, color: Colors.green),
              ),
              title: const Text('Text-to-Speech'),
              subtitle: const Text('Coming soon (Phase Firebase optional).'),
              trailing: const Icon(Icons.lock_outline_rounded),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'We keep the Masjid app respectful and inclusive: larger tap targets, readable fonts, and calm animations.',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}