import 'package:flutter/material.dart';

class ServicesListScreen extends StatelessWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Services')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.event_available_rounded),
              title: Text('Reservations'),
              subtitle: Text('Already implemented in Phase 7 screens.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.volunteer_activism_rounded),
              title: Text('Community Help'),
              subtitle: Text('Already available from Dashboard.'),
            ),
          ),
        ],
      ),
    );
  }
}