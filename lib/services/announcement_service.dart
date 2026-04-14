import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/announcement_provider.dart';

class AnnouncementService {
  AnnouncementService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _announcements =>
      _db.collection('announcements');

  static CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  static Stream<List<AnnouncementItem>> streamAnnouncements() {
    return _announcements
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return AnnouncementItem(
          id: doc.id,
          title: (data['title'] ?? '').toString(),
          message: (data['message'] ?? '').toString(),
          isImportant: (data['isImportant'] ?? false) == true,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          active: (data['active'] ?? true) == true,
          expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
          imageUrl: (data['imageUrl'] ?? '').toString(),
          videoUrl: (data['videoUrl'] ?? '').toString(),
        );
      }).where((item) {
        if (!item.active) return false;
        if (item.expiryDate == null) return true;
        return item.expiryDate!.isAfter(now);
      }).toList();
    });
  }

  static Future<void> createAnnouncement({
    required String title,
    required String message,
  }) async {
    await _announcements.add({
      'title': title.trim(),
      'message': message.trim(),
      'isImportant': false,
      'createdBy': 'system',
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'imageUrl': '',
      'videoUrl': '',
    });

    await _notifications.add({
      'type': 'announcement',
      'title': title.trim(),
      'message': message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> addAnnouncement({
    required String title,
    required String message,
    required bool isImportant,
    required String createdBy,
  }) async {
    final doc = _announcements.doc();

    await doc.set({
      'title': title.trim(),
      'message': message.trim(),
      'isImportant': isImportant,
      'createdBy': createdBy.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'imageUrl': '',
      'videoUrl': '',
    });

    await _notifications.add({
      'title': title.trim(),
      'message': message.trim(),
      'type': 'announcement',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}