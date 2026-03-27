import 'package:flutter/material.dart';

class MasjidHistoryScreen extends StatelessWidget {
  const MasjidHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Masjid History')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add a short history of Masjid Un Nabawi here.\nIn Phase Firebase, admin can edit and publish updates.',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.85)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}