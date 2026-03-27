import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../core/app_routes.dart';

class SimpleModeScreen extends StatelessWidget {
  const SimpleModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Simple Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Simple Mode'),
              subtitle: const Text('Large buttons, easy navigation'),
              value: s.simpleMode,
              onChanged: (v) => s.setSimpleMode(v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.memberHome),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}