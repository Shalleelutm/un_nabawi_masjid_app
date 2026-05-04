import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgressService {
  static const String _key = 'last_read_surah';
  
  static Future<void> save(int surahIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, surahIndex);
  }
  
  static Future<int?> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }
}