import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComplaintProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendComplaint({
    required String uid,
    required String name,
    required String message,
  }) async {
    await _db.collection('complaints').add({
      'uid': uid,
      'name': name.trim(),
      'message': message.trim(),
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllComplaints() {
    return _db
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
