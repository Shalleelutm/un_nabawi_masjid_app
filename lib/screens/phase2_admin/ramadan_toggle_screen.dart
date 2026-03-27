// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui_feedback.dart';

class RamadanToggleScreen extends StatefulWidget {
  const RamadanToggleScreen({super.key});

  @override
  State<RamadanToggleScreen> createState() => _RamadanToggleScreenState();
}

class _RamadanToggleScreenState extends State<RamadanToggleScreen> {
  static const _kKey = 'ramadan_mode_enabled';
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kKey) ?? false;
    setState(() => _loading = false);
  }

  Future<void> _set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, v);
    setState(() => _enabled = v);
    UIFeedback.successSnack(
      context,
      v ? 'Ramadan mode ENABLED.' : 'Ramadan mode DISABLED.',
    );
    UIFeedback.showConfetti(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Ramadan Mode')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🌙 Ramadan Mode',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'Enables Ramadan dashboard, daily duas, iftar/sehri focus.\nOffline-first now. Firebase sync later.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable Ramadan Mode'),
                    subtitle: Text(_enabled
                        ? 'Members will see Ramadan experience.'
                        : 'Members see normal experience.'),
                    value: _enabled,
                    onChanged: _set,
                  ),
                ),
              ],
            ),
    );
  }
}
