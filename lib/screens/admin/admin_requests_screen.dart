import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../requests/request_chat_screen.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  void updateStatus(String id, String status) {
    FirebaseFirestore.instance
        .collection('member_requests')
        .doc(id)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Requests')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('member_requests')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];

              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(d['title']),
                      subtitle: Text(d['description']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RequestChatScreen(requestId: d.id),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: () => updateStatus(d.id, 'open'), child: const Text('Open')),
                        TextButton(onPressed: () => updateStatus(d.id, 'resolved'), child: const Text('Resolve')),
                        TextButton(onPressed: () => updateStatus(d.id, 'cancelled'), child: const Text('Cancel')),
                      ],
                    )
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