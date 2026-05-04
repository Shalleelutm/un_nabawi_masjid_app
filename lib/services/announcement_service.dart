import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementItem {
  final String id;
  final String title;
  final String message;
  final bool isImportant;
  final DateTime createdAt;
  final bool active;
  final DateTime? expiryDate;
  final String imageUrl;
  final String videoUrl;
  final int likes;
  final int attending;

  AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isImportant,
    required this.createdAt,
    required this.active,
    this.expiryDate,
    required this.imageUrl,
    required this.videoUrl,
    this.likes = 0,
    this.attending = 0,
  });
}

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
        .limit(20)
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
          likes: (data['likes'] ?? 0) as int,
          attending: (data['attending'] ?? 0) as int,
        );
      }).where((item) {
        if (!item.active) return false;
        if (item.expiryDate == null) return true;
        return item.expiryDate!.isAfter(now);
      }).toList();
    });
  }

  static Future<void> like(String id) async {
    final doc = _announcements.doc(id);
    await doc.update({
      'likes': FieldValue.increment(1),
    });
  }

  static Future<void> attend(String id) async {
    final doc = _announcements.doc(id);
    await doc.update({
      'attending': FieldValue.increment(1),
    });
  }

  // ✅ FIX #1: createAnnouncement() - USED IN NORMAL ADMIN SCREEN
  static Future<void> createAnnouncement({
    required String title,
    required String message,
  }) async {
    final now = FieldValue.serverTimestamp();

    await _announcements.add({
      'title': title.trim(),
      'message': message.trim(),
      'createdAt': now,
      'active': true,
      'isImportant': false,
      'imageUrl': '',
      'videoUrl': '',
      'likes': 0,
      'attending': 0,
    });

    // ✅ FIXED: Added 'topic' field for FCM push notifications
    await _notifications.add({
      'title': title.trim(),
      'message': message.trim(),
      'type': 'announcement',
      'topic': 'announcements',  // ✅ CRITICAL ADDITION
      'createdAt': now,
    });
  }

  // ✅ FIX #2: addAnnouncement() - USED IN ADVANCED/ADMIN SCREEN
  static Future<void> addAnnouncement({
    required String title,
    required String message,
    required bool isImportant,
    required String createdBy,
  }) async {
    final now = FieldValue.serverTimestamp();

    await _announcements.add({
      'title': title.trim(),
      'message': message.trim(),
      'isImportant': isImportant,
      'createdBy': createdBy.trim(),
      'createdAt': now,
      'active': true,
      'imageUrl': '',
      'videoUrl': '',
      'likes': 0,
      'attending': 0,
    });

    // ✅ FIXED: Added 'topic' field for FCM push notifications
    await _notifications.add({
      'title': title.trim(),
      'message': message.trim(),
      'type': 'announcement',
      'topic': 'announcements',  // ✅ CRITICAL ADDITION
      'createdAt': now,
    });
  }
}