// ignore_for_file: prefer_single_quotes

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/role_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminMediaUploadScreen extends StatefulWidget {
  const AdminMediaUploadScreen({super.key});

  @override
  State<AdminMediaUploadScreen> createState() =>
      _AdminMediaUploadScreenState();
}

class _AdminMediaUploadScreenState extends State<AdminMediaUploadScreen> {
  Uint8List? imageBytes;
  bool loading = false;
  final TextEditingController captionController = TextEditingController();

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (picked == null) return;

    final bytes = await File(picked.path).readAsBytes();

    setState(() => imageBytes = bytes);
  }

  Future<void> upload() async {
    if (imageBytes == null) return;

    setState(() => loading = true);

    try {
      final base64Image = base64Encode(imageBytes!);

      await FirebaseFirestore.instance.collection('gallery').add({
        'imageBase64': base64Image,
        'caption': captionController.text.trim(),
        'likes': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'uploadedBy': FirebaseAuth.instance.currentUser?.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Uploaded to gallery!")),
      );

      setState(() {
        loading = false;
        imageBytes = null;
        captionController.clear();
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>();

    if (!role.isAdmin) {
      return const Scaffold(
        body: Center(child: Text("ACCESS DENIED")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("📸 Admin Upload")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageBytes != null)
              Image.memory(imageBytes!, height: 200),

            const SizedBox(height: 16),

            TextField(
              controller: captionController,
              decoration: const InputDecoration(labelText: "Caption"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            ElevatedButton(
              onPressed: upload,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}