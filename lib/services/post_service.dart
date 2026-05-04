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
        .handleError((error) {
          print('Error loading posts: $error');
          return Stream.empty();
        })
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
    try {
      await _db.collection('posts').add({
        'text': text.trim(),
        'likes': 0,
        'userName': userName.trim().isEmpty ? 'Member' : userName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  static Future<void> likePost(String id) async {
    try {
      await _db.collection('posts').doc(id).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  static Future<void> deletePost(String id) async {
    try {
      await _db.collection('posts').doc(id).delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }
}