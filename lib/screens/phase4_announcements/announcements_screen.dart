import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../services/announcement_service.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.items.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        item.isImportant
                            ? Icons.priority_high_rounded
                            : Icons.campaign_rounded,
                        color: item.isImportant ? Colors.red : Colors.green,
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite, color: Colors.red.shade400),
                            onPressed: () => AnnouncementService.like(item.id),
                            tooltip: 'Like',
                          ),
                          Text('${item.likes}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green.shade600),
                            onPressed: () => AnnouncementService.attend(item.id),
                            tooltip: 'I will attend',
                          ),
                          Text('${item.attending} attending', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}