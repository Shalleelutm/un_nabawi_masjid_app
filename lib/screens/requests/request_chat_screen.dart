import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class RequestChatScreen extends StatefulWidget {
  final String requestId;

  const RequestChatScreen({super.key, required this.requestId});

  @override
  State<RequestChatScreen> createState() => _RequestChatScreenState();
}

class _RequestChatScreenState extends State<RequestChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();

  final user = FirebaseAuth.instance.currentUser;

  bool isSending = false;

  @override
  void initState() {
    super.initState();
    markSeen();
  }

  // ✅ STEP A — ADD FUNCTION markSeen()
  Future<void> markSeen() async {
    if (user == null) return;
    
    final snapshot = await FirebaseFirestore.instance
        .collection('member_requests')
        .doc(widget.requestId)
        .collection('messages')
        .get();

    for (var doc in snapshot.docs) {
      if (doc['senderId'] != user?.uid) {
        doc.reference.update({'seen': true});
      }
    }
  }

  Future<void> sendMessage({String? imageBase64}) async {
    final text = messageController.text.trim();

    if ((text.isEmpty && imageBase64 == null) || user == null) return;

    setState(() => isSending = true);

    final requestRef = FirebaseFirestore.instance
        .collection('member_requests')
        .doc(widget.requestId);

    await requestRef.collection('messages').add({
      'text': text,
      'imageBase64': imageBase64,
      'senderId': user!.uid,
      'senderEmail': user!.email ?? '',
      'senderName': user!.displayName ?? user!.email ?? 'User',
      'createdAt': FieldValue.serverTimestamp(),
      'seen': false,
    });

    // ✅ STEP 3 — ADD NOTIFICATION AFTER FIRESTORE ADD (WITH TOPIC FIELD)
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'New Message',
      'message': text.isNotEmpty ? text : '📷 Image',
      'type': 'chat',
      'topic': 'chat',  // ✅ ADDED TOPIC FIELD FOR FCM
      'requestId': widget.requestId,
      'senderId': user!.uid,
      'senderName': user!.displayName ?? user!.email ?? 'User',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await requestRef.update({
      'lastMessage': text.isNotEmpty ? text : '📷 Image',
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'open',
    });

    messageController.clear();

    if (mounted) setState(() => isSending = false);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
      maxWidth: 700,
    );

    if (picked == null) return;

    final bytes = await File(picked.path).readAsBytes();
    final encoded = base64Encode(bytes);

    if (encoded.length > 850000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image too large. Choose a smaller image.'),
        ),
      );
      return;
    }

    await sendMessage(imageBase64: encoded);
  }

  String formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Uint8List? decodeImage(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ STEP B — CALL markSeen() inside build
    markSeen();
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Login required')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Chat'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
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
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final mine = data['senderId'] == user!.uid;
                    final imageBytes = decodeImage(data['imageBase64']);

                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.76,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? Colors.green : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!mine)
                              Text(
                                mine ? 'You' : (data['senderEmail'] ?? 'User'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if ((data['text'] ?? '').toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  data['text'],
                                  style: TextStyle(
                                    color: mine ? Colors.white : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            if (imageBytes != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    imageBytes,
                                    height: 180,
                                    width: 220,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatTime(data['createdAt'])} ${data['seen'] == true ? '✓ Seen' : ''}',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    mine ? Colors.white70 : Colors.grey.shade700,
                              ),
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
          
          // ✅ STEP D — ADD TYPING UI
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('member_requests')
                .doc(widget.requestId)
                .collection('typing')
                .snapshots(),
            builder: (_, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              
              final docs = snapshot.data!.docs;
              
              bool someoneTyping = docs.any(
                (d) => d['typing'] == true && d.id != user?.uid,
              );
              
              return someoneTyping
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Admin is typing...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : const SizedBox();
            },
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: isSending ? null : pickImage,
                    icon: const Icon(Icons.image, color: Colors.green),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      // ✅ STEP C — REPLACE onChanged with typing indicator
                      onChanged: (text) {
                        FirebaseFirestore.instance
                            .collection('member_requests')
                            .doc(widget.requestId)
                            .collection('typing')
                            .doc(user!.uid)
                            .set({'typing': text.isNotEmpty});
                      },
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isSending ? null : () => sendMessage(),
                    icon: const Icon(Icons.send, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}