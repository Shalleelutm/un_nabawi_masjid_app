import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberRequest {
  final String id;
  final String type;
  final String message;
  final String status;

  MemberRequest({
    required this.id,
    required this.type,
    required this.message,
    required this.status,
  });

  factory MemberRequest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MemberRequest(
      id: doc.id,
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }
}

class RequestProvider extends ChangeNotifier {
  final _collection =
      FirebaseFirestore.instance.collection('member_requests');

  List<MemberRequest> _requests = [];

  List<MemberRequest> get requests => _requests;

  Future<void> load() async {
    final snapshot = await _collection.get();

    _requests =
        snapshot.docs.map((doc) => MemberRequest.fromDoc(doc)).toList();

    notifyListeners();
  }

  Future<void> createRequest(String type, String message) async {
    await _collection.add({
      'type': type,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await load();
  }

  Future<void> updateStatus(String id, String status) async {
    await _collection.doc(id).update({'status': status});

    await load();
  }
}