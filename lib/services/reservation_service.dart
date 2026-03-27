import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationService {
  ReservationService._();
  static final ReservationService instance = ReservationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamRequests() {
    return _db
        .collection('service_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> submitRequest({
    required String userId,
    required String userEmail,
    required String type,
    required String message,
  }) async {
    await _db.collection('service_requests').add({
      'userId': userId,
      'userEmail': userEmail,
      'type': type,
      'message': message,
      'status': 'pending',
      'adminReply': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRequest({
    required String requestId,
    required String status,
    String adminReply = '',
  }) async {
    await _db.collection('service_requests').doc(requestId).set({
      'status': status,
      'adminReply': adminReply,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}