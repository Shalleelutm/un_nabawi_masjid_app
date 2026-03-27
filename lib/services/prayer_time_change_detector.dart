import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_notification_service.dart';

class PrayerTimeChangeDetector {
  PrayerTimeChangeDetector._();

  static final PrayerTimeChangeDetector instance =
      PrayerTimeChangeDetector._();

  static const String _fingerprintKey = 'prayer_times_override_fingerprint_v1';

  Future<void> detectChanges() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('prayer_timetable_overrides')
          .orderBy(FieldPath.documentId)
          .get();

      final normalized = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      final currentFingerprint = jsonEncode(normalized);

      final prefs = await SharedPreferences.getInstance();
      final previousFingerprint = prefs.getString(_fingerprintKey);

      if (previousFingerprint == null) {
        await prefs.setString(_fingerprintKey, currentFingerprint);
        return;
      }

      if (previousFingerprint != currentFingerprint) {
        await prefs.setString(_fingerprintKey, currentFingerprint);

        await LocalNotificationService.instance.showNow(
          notificationId: 5001,
          title: 'Prayer Time Updated',
          body: 'The masjid has updated the prayer timetable. Please check the app.',
          channelId: LocalNotificationService.generalChannelId,
        );
      }
    } catch (_) {
      // Keep app safe. No crash if offline or Firestore fails.
    }
  }
}