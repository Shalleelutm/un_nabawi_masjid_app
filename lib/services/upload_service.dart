import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  UploadService._();

  static Future<String> upload(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}