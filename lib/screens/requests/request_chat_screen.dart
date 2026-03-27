import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RequestChatScreen extends StatefulWidget {
  final String requestId;

  const RequestChatScreen({super.key, required this.requestId});

  @override
  State<RequestChatScreen> createState() => _RequestChatScreenState();
}

class _RequestChatScreenState extends State<RequestChatScreen> {
  final controller = TextEditingController();
  final picker = ImagePicker();

  Future<void> sendMessage({String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('member_requests')
        .doc(widget.requestId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'message': controller.text.trim(),
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
    });

    controller.clear();
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance
        .ref('request_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await sendMessage(imageUrl: url);
  }

  bool isMe(String senderId) {
    return FirebaseAuth.instance.currentUser?.uid == senderId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('member_requests')
                  .doc(widget.requestId)
                  .collection('messages')
                  .orderBy('createdAt')
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
                    final mine = isMe(d['senderId']);

                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: mine
                              ? Colors.green.shade600
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d['message'] != null &&
                                d['message'].toString().isNotEmpty)
                              Text(
                                d['message'],
                                style: TextStyle(
                                  color:
                                      mine ? Colors.white : Colors.black,
                                ),
                              ),
                            if (d['imageUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Image.network(d['imageUrl']),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: 'Type message...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => sendMessage(),
              )
            ],
          )
        ],
      ),
    );
  }
}