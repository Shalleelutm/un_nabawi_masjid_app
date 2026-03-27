import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
              ? const Center(child: Text('No announcements yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {

                    final item = provider.items[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          item.isImportant
                              ? Icons.priority_high_rounded
                              : Icons.campaign_rounded,
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(item.message),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd MMM yyyy • HH:mm')
                                  .format(item.createdAt),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}