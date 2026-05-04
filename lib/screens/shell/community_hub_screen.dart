import 'package:flutter/material.dart';
import '../../core/masjid_background.dart';

class CommunityHubScreen extends StatelessWidget {
  const CommunityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: MasjidBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Text(
                'المجتمع الروحي',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.handshake_rounded, color: cs.primary),
                ),
                title: const Text(
                  'Community Help Corner',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Submit help requests, see help offers'),
                onTap: () {
                  Navigator.pushNamed(context, '/communityHelp');
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondary.withValues(alpha: 0.15),
                  child: Icon(Icons.history_edu_rounded, color: cs.secondary),
                ),
                title: const Text(
                  'Masjid History & Milestones',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Legacy, projects, forest-side masjid story'),
                onTap: () {
                  // Add history screen route
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.tertiary.withValues(alpha: 0.15),
                  child: Icon(Icons.people_alt_rounded, color: cs.tertiary),
                ),
                title: const Text(
                  'Committee & Contact',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Who to contact for services'),
                onTap: () {
                  // Add committee screen route
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondary.withValues(alpha: 0.15),
                  child: Icon(Icons.chat_bubble_outline_rounded, color: cs.secondary),
                ),
                title: const Text(
                  'Islamic Q&A Assistant',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Ask fiqh / daily life questions to the Imam'),
                onTap: () {
                  Navigator.pushNamed(context, '/qaAssistant');
                },
              ),
            ),
            // ✅ GALLERY BUTTON ADDED HERE
            const SizedBox(height: 12),
            Card(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pink.withValues(alpha: 0.15),
                  child: const Icon(Icons.photo_library, color: Colors.pink),
                ),
                title: const Text(
                  'Masjid Gallery',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('View photos from masjid events'),
                onTap: () {
                  Navigator.pushNamed(context, '/gallery');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}