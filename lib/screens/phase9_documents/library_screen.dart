import 'package:flutter/material.dart';
import '../../core/ui_feedback.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = <_DocItem>[
      _DocItem(
        title: 'Membership Registration Form',
        subtitle: 'Download & fill to register as a member.',
        icon: Icons.assignment_outlined,
        onTap: () => UIFeedback.successSnack(
          context,
          'Phase 2 offline: placeholder. Phase 4 Firebase: real PDF download.',
        ),
      ),
      _DocItem(
        title: 'Membership Withdrawal Form',
        subtitle: 'Download & fill to withdraw membership.',
        icon: Icons.assignment_return_outlined,
        onTap: () => UIFeedback.successSnack(
          context,
          'Phase 2 offline: placeholder. Phase 4 Firebase: real PDF download.',
        ),
      ),
      _DocItem(
        title: 'Masjid Rules & Regulations',
        subtitle: 'Adab, cleanliness, silence, respect.',
        icon: Icons.rule_folder_outlined,
        onTap: () => _openText(context, 'Rules & Regulations', _rulesText),
      ),
      _DocItem(
        title: 'Yearly Election Date',
        subtitle: 'Official election schedule and process.',
        icon: Icons.event_outlined,
        onTap: () => _openText(context, 'Election Date', _electionText),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Documents & Downloads')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = docs[i];
          return Card(
            child: ListTile(
              leading: Icon(d.icon),
              title: Text(d.title),
              subtitle: Text(d.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: d.onTap,
            ),
          );
        },
      ),
    );
  }

  void _openText(BuildContext context, String title, String body) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TextDocScreen(title: title, body: body),
      ),
    );
  }
}

class _DocItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _DocItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _TextDocScreen extends StatelessWidget {
  final String title;
  final String body;

  const _TextDocScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          body,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ),
    );
  }
}

const String _rulesText = '''
• Keep silence inside the masjid.
• Switch phone to silent mode.
• Dress modestly and respect others.
• Keep the masjid clean (no litter).
• Children must be supervised.
• No loud discussion after prayers.
• Respect the imam and committee.
''';

const String _electionText = '''
Election Process (Phase 2 Offline Draft):
• Committee announces election period.
• Members verify eligibility.
• Candidates are announced publicly.
• Voting must be transparent.

Phase 4 Firebase:
• Verified members only (login + role)
• Secure poll with audit history
• Admin approval before poll opens
''';
