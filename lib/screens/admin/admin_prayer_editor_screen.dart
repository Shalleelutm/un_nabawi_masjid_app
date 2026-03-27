import 'package:flutter/material.dart';
import '../../services/prayer_timetable_service.dart';

class AdminPrayerEditorScreen extends StatelessWidget {
  const AdminPrayerEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PrayerTimetableService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Timetable Editor')),
      body: StreamBuilder(
        stream: service.streamTimes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No timetable found'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];

              return Card(
                child: ListTile(
                  title: Text(d['date']),
                  subtitle: Text(
                    'Fajr ${d['fajr']} | Dhuhr ${d['dhuhr']} | Asr ${d['asr']} | Maghrib ${d['maghrib']} | Isha ${d['isha']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _edit(context, d),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _edit(BuildContext context, dynamic doc) {
    final fajr = TextEditingController(text: doc['fajr']);
    final dhuhr = TextEditingController(text: doc['dhuhr']);
    final asr = TextEditingController(text: doc['asr']);
    final maghrib = TextEditingController(text: doc['maghrib']);
    final isha = TextEditingController(text: doc['isha']);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Prayer Times'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fajr, decoration: const InputDecoration(labelText: 'Fajr')),
              TextField(controller: dhuhr, decoration: const InputDecoration(labelText: 'Dhuhr')),
              TextField(controller: asr, decoration: const InputDecoration(labelText: 'Asr')),
              TextField(controller: maghrib, decoration: const InputDecoration(labelText: 'Maghrib')),
              TextField(controller: isha, decoration: const InputDecoration(labelText: 'Isha')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await PrayerTimetableService.instance.updatePrayer(
                  docId: doc.id,
                  fajr: fajr.text,
                  dhuhr: dhuhr.text,
                  asr: asr.text,
                  maghrib: maghrib.text,
                  isha: isha.text,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}