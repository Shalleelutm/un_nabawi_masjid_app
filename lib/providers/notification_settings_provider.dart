import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool _loaded = false;

  bool _prayerNotificationsEnabled = true;
  bool _jumuahNotificationsEnabled = true;
  bool _announcementNotificationsEnabled = true;
  bool _eventNotificationsEnabled = true;
  bool _countdownEnabled = true;

  bool get loaded => _loaded;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get jumuahNotificationsEnabled => _jumuahNotificationsEnabled;
  bool get announcementNotificationsEnabled => _announcementNotificationsEnabled;
  bool get eventNotificationsEnabled => _eventNotificationsEnabled;
  bool get countdownEnabled => _countdownEnabled;

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

    _loaded = true;
    notifyListeners();
  }

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
    notifyListeners();
  }

  Future<void> setEventNotificationsEnabled(bool value) async {
    _eventNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eventNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setCountdownEnabled(bool value) async {
    _countdownEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('countdownEnabled', value);
    notifyListeners();
  }
}