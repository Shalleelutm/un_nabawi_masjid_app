import 'package:flutter/material.dart';
import '../../services/blocked_time_service.dart';

class BlockedTimesScreen extends StatelessWidget {
  const BlockedTimesScreen({super.key});

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Forbidden Times')),
      body: FutureBuilder<List<BlockedTimeItem>>(
        future: BlockedTimeService().getBlockedTimes(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final blocked = snap.data ?? <BlockedTimeItem>[];

          if (blocked.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No forbidden times available for today.\n(If your JSON does not include forbidden windows, update it.)',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Card(
                color: Colors.red.withValues(alpha: 0.10),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    '⚠ Forbidden windows are important.\nAvoid voluntary prayers in these periods.',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...blocked.map((b) {
                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading:
                        const Icon(Icons.block_rounded, color: Colors.red),
                    title: Text(
                      b.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle:
                        Text('${b.reason}\n${_fmt(b.start)} → ${_fmt(b.end)}'),
                    isThreeLine: true,
                    trailing:
                        Icon(Icons.warning_rounded, color: cs.error),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}