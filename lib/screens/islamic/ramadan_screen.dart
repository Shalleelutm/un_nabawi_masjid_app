import 'package:flutter/material.dart';

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final iftar = DateTime(now.year, now.month, now.day, 18, 30);

    final diff = iftar.difference(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Ramadan')),
      body: Center(
        child: Text(
          '${diff.inHours}h ${diff.inMinutes % 60}m left for Iftar',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}