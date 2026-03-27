import 'package:flutter/material.dart';

import '../phase6_dashboard/dashboard_screen.dart';
import '../phase1/home_spiritual_screen.dart';
import '../phase7_settings/settings_screen.dart';
import '../../core/masjid_background.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    HomeSpiritualScreen(),
    CommunityHubScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_rounded),
            label: 'Spiritual',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_rounded),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

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
                subtitle:
                    const Text('Submit help requests, see help offers'),
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
                  child:
                      Icon(Icons.history_edu_rounded, color: cs.secondary),
                ),
                title: const Text(
                  'Masjid History & Milestones',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                    'Legacy, projects, forest-side masjid story'),
                onTap: () {
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.tertiary.withValues(alpha: 0.15),
                  child:
                      Icon(Icons.people_alt_rounded, color: cs.tertiary),
                ),
                title: const Text(
                  'Committee & Contact',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Who to contact for services'),
                onTap: () {
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondary.withValues(alpha: 0.15),
                  child: Icon(Icons.chat_bubble_outline_rounded,
                      color: cs.secondary),
                ),
                title: const Text(
                  'Islamic Q&A Assistant',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                    'Ask fiqh / daily life questions to the Imam'),
                onTap: () {
                  Navigator.pushNamed(context, '/qaAssistant');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}