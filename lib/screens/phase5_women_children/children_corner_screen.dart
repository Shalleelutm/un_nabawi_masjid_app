import 'package:flutter/material.dart';

class ChildrenCornerScreen extends StatelessWidget {
  const ChildrenCornerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Children Corner')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: cs.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Kids learn fast with short fun lessons.\nUse the Daily Corner + Quiz for now.',
                style: TextStyle(color: cs.onTertiaryContainer, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}