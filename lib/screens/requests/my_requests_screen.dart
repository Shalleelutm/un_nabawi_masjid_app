import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'request_chat_screen.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  Color getColor(String status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('member_requests')
            .where('userId', isEqualTo: uid) // 🔥 FIXED PRIVACY
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];

              return ListTile(
                title: Text(d['title']),
                subtitle: Text(d['description']),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: getColor(d['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    d['status'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RequestChatScreen(requestId: d.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}