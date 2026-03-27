import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalMasjidNetworkService {
  GlobalMasjidNetworkService._();

  static final GlobalMasjidNetworkService instance =
      GlobalMasjidNetworkService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerMasjid({
    required String name,
    required String city,
    required String country,
  }) async {
    await _db.collection('masjids').add({
      'name': name,
      'city': city,
      'country': country,
      'created': DateTime.now().toIso8601String(),
    });
  }

  Future<void> broadcastAnnouncement({
    required String message,
  }) async {
    await _db.collection('global_announcements').add({
      'message': message,
      'created': DateTime.now().toIso8601String(),
    });
  }
}