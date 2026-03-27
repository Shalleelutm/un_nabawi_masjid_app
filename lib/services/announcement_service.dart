import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/announcement_provider.dart';

class AnnouncementService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'announcements';

  static Stream<List<AnnouncementItem>> streamAnnouncements() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final ts = data['createdAt'];
            DateTime createdAt = DateTime.now();
            if (ts is Timestamp) {
              createdAt = ts.toDate();
            }

            return AnnouncementItem(
              id: doc.id,
              title: (data['title'] ?? '').toString(),
              message: (data['message'] ?? '').toString(),
              isImportant: (data['isImportant'] ?? false) == true,
              createdAt: createdAt,
            );
          }).toList(),
        );
  }

  static Future<void> addAnnouncement({
    required String title,
    required String message,
    required bool isImportant,
    required String createdBy,
  }) async {
    await _db.collection(_collection).add({
      'title': title.trim(),
      'message': message.trim(),
      'isImportant': isImportant,
      'createdBy': createdBy.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteAnnouncement(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}