import 'package:flutter/material.dart';

class WomenCornerScreen extends StatelessWidget {
  const WomenCornerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Women Corner')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.14),
                child: const Icon(Icons.favorite_rounded, color: Colors.purple),
              ),
              title: const Text('Daily Corner is the main entry'),
              subtitle: const Text('Later: women programs/events + reminders via Firebase.'),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Respectful content, privacy-first.\nNo public “showing off” features.',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}