import 'package:flutter/material.dart';

import '../../core/ui_feedback.dart';
import '../../models/community_request_model.dart';
import '../../services/community_request_service.dart';
import '../../services/local_notification_service.dart';

class CommunityHelpAdminScreen extends StatelessWidget {
  const CommunityHelpAdminScreen({super.key});

  Future<void> _approve(BuildContext context, CommunityRequestModel request) async {
    await CommunityRequestService.setStatus(
      id: request.id,
      status: 'approved',
      adminNote: 'Approved by admin',
    );

    await LocalNotificationService.instance.showNow(
      title: 'Request Approved',
      body: '${request.userName} request approved.',
    );

    if (!context.mounted) return;
    UIFeedback.successSnack(context, 'Request approved');
  }

  Future<void> _reject(BuildContext context, CommunityRequestModel request) async {
    await CommunityRequestService.setStatus(
      id: request.id,
      status: 'rejected',
      adminNote: 'Rejected by admin',
    );

    await LocalNotificationService.instance.showNow(
      title: 'Request Rejected',
      body: '${request.userName} request rejected.',
    );

    if (!context.mounted) return;
    UIFeedback.errorSnack(context, 'Request rejected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Requests')),
      body: StreamBuilder<List<CommunityRequestModel>>(
        stream: CommunityRequestService.stream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(child: Text('Failed to load requests: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No community requests yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final r = items[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Member: ${r.userName}'),
                      Text('Email: ${r.userEmail}'),
                      const SizedBox(height: 6),
                      Text(r.description),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: r.status == 'approved'
                                ? null
                                : () => _approve(context, r),
                            child: const Text('Approve'),
                          ),
                          OutlinedButton(
                            onPressed: r.status == 'rejected'
                                ? null
                                : () => _reject(context, r),
                            child: const Text('Reject'),
                          ),
                          Chip(label: Text(r.status)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}