import 'package:shared_preferences/shared_preferences.dart';

class MasjidModeService {
  MasjidModeService._();

  static const String _kEnabled = 'masjid_mode_enabled_v1';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  static Future<void> setEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, v);
  }

  /// ✅ In Masjid Mode, allow ONLY critical channels (prayer + jumuah)
  static Future<bool> allowChannel(String channelId) async {
    final enabled = await isEnabled();
    if (!enabled) return true;

    const allowed = {
      'prayer_reminders',
      'jumuah_reminder',
      'masjid_important', // keep announcements allowed (you can remove if you want silence)
    };

    return allowed.contains(channelId);
  }
}