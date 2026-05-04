import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../requests/request_chat_screen.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'open':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('member_requests')
        .doc(id)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRequest(String id) async {
    await FirebaseFirestore.instance
        .collection('member_requests')
        .doc(id)
        .delete();
  }

  String formatTime(dynamic ts) {
    if (ts is! Timestamp) return '';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Requests CRM'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('member_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;

              final title = data['title']?.toString() ?? 'No Title';
              final desc = data['description']?.toString() ?? '';
              final status = data['status']?.toString() ?? 'pending';
              final email = data['userEmail']?.toString() ??
                  data['email']?.toString() ??
                  data['userId']?.toString() ??
                  'Unknown user';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ ADDED PopupMenuButton as trailing in a Row
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: statusColor(status),
                            child: Text(title.isNotEmpty ? title[0] : '?'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: statusColor(status),
                          ),
                          // ✅ POPUP MENU BUTTON ADDED HERE
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              FirebaseFirestore.instance
                                  .collection('member_requests')
                                  .doc(d.id)
                                  .update({
                                'status': value,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'pending', child: Text('Pending')),
                              const PopupMenuItem(value: 'open', child: Text('Open')),
                              const PopupMenuItem(value: 'resolved', child: Text('Resolved')),
                              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(desc),
                      const SizedBox(height: 8),
                      Text(
                        'User: $email',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('Created: ${formatTime(data['createdAt'])}'),
                      if (data['lastMessage'] != null)
                        Text('Last: ${data['lastMessage']}'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RequestChatScreen(requestId: d.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Reply'),
                          ),
                          OutlinedButton(
                            onPressed: () => updateStatus(d.id, 'open'),
                            child: const Text('Open'),
                          ),
                          OutlinedButton(
                            onPressed: () => updateStatus(d.id, 'resolved'),
                            child: const Text('Resolved'),
                          ),
                          OutlinedButton(
                            onPressed: () => updateStatus(d.id, 'cancelled'),
                            child: const Text('Cancel'),
                          ),
                          IconButton(
                            onPressed: () => deleteRequest(d.id),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
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