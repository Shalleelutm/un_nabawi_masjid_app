import 'package:flutter/material.dart';

class CommitteeScreen extends StatelessWidget {
  const CommitteeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Committee')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primary.withValues(alpha: 0.14),
                child: Icon(Icons.groups_rounded, color: cs.primary),
              ),
              title: const Text('Committee Members'),
              subtitle: const Text('This will become live via Firebase (Phase Members).'),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Keep committee details accurate and respectful.\nIn Phase Firebase, admin can manage roles and publish official committee list.',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}