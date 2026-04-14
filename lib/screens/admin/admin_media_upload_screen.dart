// ignore_for_file: prefer_single_quotes

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/upload_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminMediaUploadScreen extends StatefulWidget {
  const AdminMediaUploadScreen({super.key});

  @override
  State<AdminMediaUploadScreen> createState() =>
      _AdminMediaUploadScreenState();
}

class _AdminMediaUploadScreenState extends State<AdminMediaUploadScreen> {
  File? file;
  bool loading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => file = File(picked.path));
    }
  }

  Future<void> upload() async {
    if (file == null) return;

    setState(() => loading = true);

    final url = await UploadService.upload(file!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Uploaded: $url")),
    );

    setState(() {
      loading = false;
      file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(child: Text("ACCESS DENIED")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Upload")),
      body: Column(
        children: [
          if (file != null)
            Image.file(file!, height: 200),

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
    );
  }
}