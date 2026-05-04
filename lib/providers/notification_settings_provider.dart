import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fcm_service.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool _loaded = false;

  bool _prayerNotificationsEnabled = true;
  bool _jumuahNotificationsEnabled = true;
  bool _announcementNotificationsEnabled = true;
  bool _eventNotificationsEnabled = true;
  bool _countdownEnabled = true;
  
  // ✅ ADDED CHAT NOTIFICATIONS VARIABLE
  bool _chatNotificationsEnabled = true;

  bool get loaded => _loaded;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get jumuahNotificationsEnabled => _jumuahNotificationsEnabled;
  bool get announcementNotificationsEnabled => _announcementNotificationsEnabled;
  bool get eventNotificationsEnabled => _eventNotificationsEnabled;
  bool get countdownEnabled => _countdownEnabled;
  
  // ✅ ADDED CHAT GETTER
  bool get chatNotificationsEnabled => _chatNotificationsEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _prayerNotificationsEnabled =
        prefs.getBool('prayerNotificationsEnabled') ?? true;
    _jumuahNotificationsEnabled =
        prefs.getBool('jumuahNotificationsEnabled') ?? true;
    _announcementNotificationsEnabled =
        prefs.getBool('announcementNotificationsEnabled') ?? true;
    _eventNotificationsEnabled =
        prefs.getBool('eventNotificationsEnabled') ?? true;
    _countdownEnabled = prefs.getBool('countdownEnabled') ?? true;
    
    // ✅ ADDED CHAT LOAD FROM PREFS
    _chatNotificationsEnabled =
        prefs.getBool('chatNotificationsEnabled') ?? true;

    _loaded = true;

    await _applyFcmSettings();

    notifyListeners();
  }

  // 🔥 APPLY FCM SUBSCRIPTIONS
  Future<void> _applyFcmSettings() async {
    final fcm = FcmService.instance;

    if (_announcementNotificationsEnabled) {
      await fcm.subscribe('announcements');
    } else {
      await fcm.unsubscribe('announcements');
    }

    if (_eventNotificationsEnabled) {
      await fcm.subscribe('events');
    } else {
      await fcm.unsubscribe('events');
    }
    
    // ✅ ADDED CHAT SUBSCRIPTION
    if (_chatNotificationsEnabled) {
      await fcm.subscribe('chat');
    } else {
      await fcm.unsubscribe('chat');
    }
  }

  // =========================
  // 🔥 FIXED METHODS (ALL BACK)
  // =========================

  Future<void> setPrayerNotificationsEnabled(bool value) async {
    _prayerNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayerNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setJumuahNotificationsEnabled(bool value) async {
    _jumuahNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('jumuahNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setAnnouncementNotificationsEnabled(bool value) async {
    _announcementNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('announcementNotificationsEnabled', value);

    await _applyFcmSettings();

    notifyListeners();
  }

  Future<void> setEventNotificationsEnabled(bool value) async {
    _eventNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eventNotificationsEnabled', value);

    await _applyFcmSettings();

    notifyListeners();
  }

  Future<void> setCountdownEnabled(bool value) async {
    _countdownEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('countdownEnabled', value);
    notifyListeners();
  }

  // ✅ UPDATED CHAT METHOD (FINAL VERSION)
  Future<void> setChatNotificationsEnabled(bool value) async {
    _chatNotificationsEnabled = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chatNotificationsEnabled', value);

    // 🔥 NEW: unify all topic logic
    await _applyFcmSettings();

    notifyListeners();
  }
}