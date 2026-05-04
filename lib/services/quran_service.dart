import 'dart:convert';
import 'package:flutter/services.dart';

class QuranService {
  QuranService._();
  static final QuranService instance = QuranService._();

  List<Map<String, dynamic>>? _cache;

  void clearCache() {
    _cache = null;
  }

  Future<List<Map<String, dynamic>>> loadAllSurahs() async {
    if (_cache != null) return _cache!;

    final translitRaw =
        await rootBundle.loadString('assets/quran/quran_transliteration.json');

    final englishRaw =
        await rootBundle.loadString('assets/quran/quran_en.json');

    final frenchRaw =
        await rootBundle.loadString('assets/quran/quran_fr.json');

    final translitJson = jsonDecode(translitRaw);
    final englishJson = jsonDecode(englishRaw);
    final frenchJson = jsonDecode(frenchRaw);

    final translitSurahs = translitJson['data']['surahs'];
    final englishSurahs = englishJson['data']['surahs'];
    final frenchSurahs = frenchJson['data']['surahs'];

    final result = <Map<String, dynamic>>[];

    for (int surahNumber = 1; surahNumber <= 114; surahNumber++) {
      final raw = await rootBundle
          .loadString('assets/quran/surah/surah_$surahNumber.json');

      final surahFile = jsonDecode(raw);
      final verseMap = surahFile['verse'];

      final translitSurah =
          translitSurahs.firstWhere((s) => s['number'] == surahNumber);

      final translitAyahs = translitSurah['ayahs'];
      final englishAyahs = englishSurahs[surahNumber - 1]['ayahs'];
      final frenchAyahs = frenchSurahs[surahNumber - 1]['ayahs'];

      final ayahs = <Map<String, dynamic>>[];

      for (int i = 1; i <= verseMap.length; i++) {
        final key = 'verse_$i';

        ayahs.add({
          'number': i,
          'arabic': verseMap[key] ?? '',
          'transliteration': translitAyahs[i - 1]['text'],
          'translation_en': englishAyahs[i - 1]['text'],
          'translation_fr': frenchAyahs[i - 1]['text'],
        });
      }

      result.add({
        'number': surahNumber,
        'name': surahFile['name'],
        'englishName': translitSurah['englishName'],
        'ayahs': ayahs,
      });
    }

    _cache = result;
    return result;
  }
}