import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
              ? const Center(child: Text('No announcements yet'))

              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.items.length,
                  itemBuilder: (_, i) {

                    final item = provider.items[i];

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          item.isImportant
                              ? Icons.priority_high
                              : Icons.campaign,
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.message),
                      ),
                    );
                  },
                ),
    );
  }
}