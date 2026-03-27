import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsService {
  AdminAnalyticsService._();
  static final instance = AdminAnalyticsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> totalMembers() async {
    final snap = await _db.collection('members').get();
    return snap.docs.length;
  }

  Future<int> totalAnnouncements() async {
    final snap = await _db.collection('announcements').get();
    return snap.docs.length;
  }

  Future<int> totalRequests() async {
    final snap = await _db.collection('service_requests').get();
    return snap.docs.length;
  }
}