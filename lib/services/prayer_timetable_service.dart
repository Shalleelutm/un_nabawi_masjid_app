import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerTimetableService {
  PrayerTimetableService._();
  static final instance = PrayerTimetableService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamTimes() {
    return _db
        .collection('prayer_times')
        .orderBy('date')
        .snapshots();
  }

  Future<void> updatePrayer({
    required String docId,
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) async {
    await _db.collection('prayer_times').doc(docId).update({
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    });
  }
}