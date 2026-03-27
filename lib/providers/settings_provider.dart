import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {

  bool simpleMode = false;

  bool prayerNotificationsEnabled = true;

  bool muteAudio = false;

  void setSimpleMode(bool value) {
    simpleMode = value;
    notifyListeners();
  }

  void setPrayerNotificationsEnabled(bool value) {
    prayerNotificationsEnabled = value;
    notifyListeners();
  }

  void setMuteAudio(bool value) {
    muteAudio = value;
    notifyListeners();
  }
}