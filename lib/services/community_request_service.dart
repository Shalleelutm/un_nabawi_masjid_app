import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_request_model.dart';

class CommunityRequestService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'community_requests';

  static Stream<List<CommunityRequestModel>> stream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;

            final createdAt = data['createdAt'];
            if (createdAt is Timestamp) {
              data['createdAt'] = createdAt.toDate().toIso8601String();
            }

            final eventDate = data['eventDate'];
            if (eventDate is Timestamp) {
              data['eventDate'] = eventDate.toDate().toIso8601String();
            }

            return CommunityRequestModel.fromJson(data);
          }).toList(),
        );
  }

  static Future<List<CommunityRequestModel>> load() async {
    final snapshot = await _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;

      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        data['createdAt'] = createdAt.toDate().toIso8601String();
      }

      final eventDate = data['eventDate'];
      if (eventDate is Timestamp) {
        data['eventDate'] = eventDate.toDate().toIso8601String();
      }

      return CommunityRequestModel.fromJson(data);
    }).toList();
  }

  static Future<void> submit(CommunityRequestModel request) async {
    final data = Map<String, dynamic>.from(request.toJson());
    data.remove('id');
    data['createdAt'] = Timestamp.fromDate(request.createdAt);
    data['eventDate'] = Timestamp.fromDate(request.eventDate);

    await _db.collection(_collection).add(data);
  }

  static Future<void> setStatus({
    required String id,
    required String status,
    required String adminNote,
  }) async {
    await _db.collection(_collection).doc(id).update({
      'status': status,
      'adminNote': adminNote,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}