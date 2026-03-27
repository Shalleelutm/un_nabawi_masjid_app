import 'package:flutter/material.dart';
import '../../core/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            title: 'Continue',
            subtitle: 'Choose language, settings, then enter the app',
            icon: Icons.arrow_forward,
            onTap: () => Navigator.pushNamed(context, AppRoutes.language),
          ),
          const SizedBox(height: 12),
          _tile(
            context,
            title: 'Simple Mode (Elders)',
            subtitle: 'Large buttons + calmer layout',
            icon: Icons.accessibility_new,
            onTap: () => Navigator.pushNamed(context, AppRoutes.simple),
          ),
          const SizedBox(height: 12),
          _tile(
            context,
            title: 'Settings',
            subtitle: 'Language, mute adhan, preferences',
            icon: Icons.settings,
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
