import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Mute Adhan Audio'),
            subtitle: const Text('If ON: no startup adhan sound'),
            value: s.muteAudio,
            onChanged: (v) => s.setMuteAudio(v),
          ),
          SwitchListTile(
            title: const Text('Simple Mode'),
            subtitle: const Text('For elders: bigger UI'),
            value: s.simpleMode,
            onChanged: (v) => s.setSimpleMode(v),
          ),
          const SizedBox(height: 12),
          const Text(
            'Language is selected in Language screen.\nFull translations come in Phase 4.',
          ),
        ],
      ),
    );
  }
}
