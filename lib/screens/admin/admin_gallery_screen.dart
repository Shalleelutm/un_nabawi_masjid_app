import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminGalleryScreen extends StatelessWidget {
  const AdminGalleryScreen({super.key});

  Uint8List decode(String base64Str) {
    return base64Decode(base64Str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/adminUpload');
        },
        child: const Icon(Icons.add),
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

          return GridView.builder(
            itemCount: docs.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              final base64 = data['imageBase64'];

              if (base64 == null) {
                return const Icon(Icons.broken_image);
              }

              return Image.memory(
                decode(base64),
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
    );
  }
}