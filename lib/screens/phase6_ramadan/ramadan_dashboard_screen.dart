import 'package:flutter/material.dart';

class RamadanDashboardScreen extends StatelessWidget {
  const RamadanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ramadan Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(
              child: ListTile(
                  title: Text('Sehri Time'),
                  subtitle: Text('04:30 AM - 05:00 AM'))),
          Card(
              child: ListTile(
                  title: Text('Iftar Time'),
                  subtitle: Text('06:30 PM - 07:00 PM'))),
          Card(
              child: ListTile(
                  title: Text('Quran Reading'),
                  subtitle: Text('After Isha Prayer'))),
        ],
      ),
    );
  }
}
