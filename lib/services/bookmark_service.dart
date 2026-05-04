import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _key = 'bookmarks';
  
  static Future<void> add(String ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarks = prefs.getStringList(_key) ?? [];
    if (!bookmarks.contains(ayah)) {
      bookmarks.add(ayah);
      await prefs.setStringList(_key, bookmarks);
    }
  }
  
  static Future<List<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}