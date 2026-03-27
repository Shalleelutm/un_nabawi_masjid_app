import 'package:flutter/material.dart';

class CommunityMilestonesScreen extends StatelessWidget {
  const CommunityMilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Community Milestones')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: cs.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Celebrate achievements with humility.\nMilestones build connection and attendance.',
                style: TextStyle(color: cs.onSecondaryContainer, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text('Offline-first timeline'),
              subtitle: Text('Later, admin can post milestones in Firebase.'),
            ),
          ),
        ],
      ),
    );
  }
}