import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';

class PostService {
  PostService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<PostModel>> streamPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((e) => PostModel.fromMap(e.id, e.data()))
              .toList(),
        );
  }

  static Future<void> addPost(
    String text, {
    String userName = 'Member',
  }) async {
    await _db.collection('posts').add({
      'text': text.trim(),
      'likes': 0,
      'userName': userName.trim().isEmpty ? 'Member' : userName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> likePost(String id) async {
    await _db.collection('posts').doc(id).update({
      'likes': FieldValue.increment(1),
    });
  }
}