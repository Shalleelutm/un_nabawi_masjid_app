import 'package:flutter/material.dart';

class DualCalendarScreen extends StatelessWidget {
  const DualCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic & Gregorian Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gregorian Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('${now.day}-${now.month}-${now.year}'),
            const SizedBox(height: 24),
            const Text(
              'Islamic Date (Approximate)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Hijri calendar will be auto-calculated later\n(Admin + Cloud controlled)',
            ),
          ],
        ),
      ),
    );
  }
}
