import 'package:flutter/material.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dhikr')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count', style: const TextStyle(fontSize: 60)),
            ElevatedButton(
              onPressed: () => setState(() => count++),
              child: const Text('SubhanAllah'),
            ),
            TextButton(
              onPressed: () => setState(() => count = 0),
              child: const Text('Reset'),
            )
          ],
        ),
      ),
    );
  }
}