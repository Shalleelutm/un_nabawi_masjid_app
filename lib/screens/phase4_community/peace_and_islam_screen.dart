import 'package:flutter/material.dart';

class PeaceAndIslamScreen extends StatelessWidget {
  const PeaceAndIslamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Peace & Islam')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Islam encourages peace, mercy, and justice.\nThis section can hold verified short articles.',
                style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tip: Keep content short, referenced, and respectful.\nIn Phase Firebase, admin can publish weekly themes.',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}