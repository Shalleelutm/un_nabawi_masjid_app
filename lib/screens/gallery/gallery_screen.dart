// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/role_provider.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Gallery'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gallery')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No images yet'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;

              return _GalleryCard(
                id: d.id,
                url: data['url'] ?? '',
                caption: data['caption'] ?? '',
                likes: data['likes'] ?? 0,
                role: role,
              );
            },
          );
        },
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final String id;
  final String url;
  final String caption;
  final int likes;
  final RoleProvider role;

  const _GalleryCard({
    required this.id,
    required this.url,
    required this.caption,
    required this.likes,
    required this.role,
  });

  Future<void> like() async {
    final ref = FirebaseFirestore.instance.collection('gallery').doc(id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap['likes'] ?? 0) as int;
      tx.update(ref, {'likes': current + 1});
    });
  }

  void openFull(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullImageScreen(url: url, caption: caption),
      ),
    );
  }

  void openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CommentSheet(imageId: id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => openFull(context),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: url,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 60),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  caption,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 6),
                        Text('$likes'),
                      ],
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () => openComments(context),
                        ),

                        if (!role.isGuest)
                          ElevatedButton.icon(
                            onPressed: like,
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Like'),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentSheet extends StatelessWidget {
  final String imageId;

  const CommentSheet({super.key, required this.imageId});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            const Text('Comments', style: TextStyle(fontSize: 18)),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('gallery')
                    .doc(imageId)
                    .collection('comments')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final docs = snapshot.data!.docs;

                  return ListView(
                    children: docs
                        .map((d) => ListTile(
                              title: Text(d['text']),
                            ))
                        .toList(),
                  );
                },
              ),
            ),

            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(hintText: 'Write comment...'),
            ),

            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('gallery')
                    .doc(imageId)
                    .collection('comments')
                    .add({
                  'text': controller.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                controller.clear();
              },
              child: const Text('Send'),
            )
          ],
        ),
      ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String url;
  final String caption;

  const FullImageScreen({
    super.key,
    required this.url,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              caption,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}