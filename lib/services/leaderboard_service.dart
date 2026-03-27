import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  LeaderboardService._();
  static final instance = LeaderboardService._();

  final _db = FirebaseFirestore.instance;

  Future<void> addPoints(String email, int points) async {
    final ref = _db.collection('leaderboard').doc(email);

    final snap = await ref.get();

    int current = 0;

    if (snap.exists) {
      current = snap.data()?['points'] ?? 0;
    }

    await ref.set({
      'points': current + points,
    });
  }
}