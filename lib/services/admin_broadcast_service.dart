import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AdminBroadcastService {
  AdminBroadcastService._();
  static final instance = AdminBroadcastService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendBroadcast({
    required String title,
    required String body,
  }) async {
    await _db.collection('broadcasts').add({
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseMessaging.instance.subscribeToTopic('members');
  }
}