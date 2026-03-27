import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/khutbah_provider.dart';
import 'khutbah_detail_screen.dart';

class KhutbahListScreen extends StatelessWidget {
  const KhutbahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KhutbahProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Friday Khutbah')),
      body: ListView.builder(
        itemCount: provider.khutbahs.length,
        itemBuilder: (context, index) {
          final k = provider.khutbahs[index];
          return Card(
            child: ListTile(
              title: Text(k.title),
              subtitle: Text(k.date),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KhutbahDetailScreen(khutbah: k),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
