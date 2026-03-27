// FILE: lib/screens/phase8_islamic/dashboard_spiritual_screen.dart

import 'package:flutter/material.dart';
import '../../services/hijri_service.dart';
import '../../services/donation_service.dart';

class SpiritualDashboardScreen extends StatefulWidget {
  const SpiritualDashboardScreen({super.key});

  @override
  State<SpiritualDashboardScreen> createState() =>
      _SpiritualDashboardScreenState();
}

class _SpiritualDashboardScreenState
    extends State<SpiritualDashboardScreen> {
  double totalDonations = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    totalDonations = await DonationService.total();
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Spiritual Dashboard')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Card(
                  color: cs.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HijriService.todayHijri(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'May Allah bless this day.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('Total Donations'),
                    subtitle: Text(
                      'Rs ${totalDonations.toStringAsFixed(0)} collected',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Friday Reminder Active'),
                    subtitle: const Text(
                      'Auto Jumuah notification scheduled weekly',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}