import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasjidModeProvider extends ChangeNotifier {
  static const _k = 'masjid_mode_enabled_v1';

  bool _enabled = false;
  bool get enabled => _enabled;

  MasjidModeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_k) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _enabled = !_enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_k, _enabled);
  }
}
