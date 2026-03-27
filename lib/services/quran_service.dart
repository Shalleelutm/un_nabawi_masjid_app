import 'dart:convert';
import 'package:flutter/services.dart';

class QuranService {
  QuranService._();
  static final QuranService instance = QuranService._();

  List<Map<String, dynamic>>? _cache;

  Future<List<Map<String, dynamic>>> loadAllSurahs() async {
    if (_cache != null) return _cache!;

    final list = <Map<String, dynamic>>[];

    for (int i = 1; i <= 114; i++) {
      final path = 'assets/quran/surah/surah_$i.json';

      try {
        final raw = await rootBundle.loadString(path);
        final data = jsonDecode(raw);

        if (data is Map<String, dynamic>) {
          list.add(_normalizeSurah(i, data));
        }
      } catch (_) {
        continue;
      }
    }

    _cache = list;
    return list;
  }

  Map<String, dynamic> _normalizeSurah(int number, Map<String, dynamic> raw) {
    final englishName = _pickString(raw, [
      'englishName',
      'nameEnglish',
      'name',
      'title',
      'surahName',
    ], fallback: 'Surah $number');

    final arabicName = _pickString(raw, [
      'nameArabic',
      'arabicName',
      'arabic',
      'name_ar',
    ]);

    final revelationType = _pickString(raw, [
      'revelationType',
      'revelation',
      'type',
    ]);

    final ayahs = _extractAyahs(raw);

    return {
      'number': number,
      'nameEnglish': englishName,
      'nameArabic': arabicName,
      'revelationType': revelationType,
      'ayahs': ayahs,
    };
  }

  List<dynamic> _extractAyahs(Map<String, dynamic> source) {
    if (source['ayahs'] is List) {
      return (source['ayahs'] as List).asMap().entries.map((entry) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          return {
            'number': value['number'] ?? value['id'] ?? (entry.key + 1),
            'arabic': _pickString(value, ['arabic', 'text', 'ayah', 'content']),
            'translation': _pickString(value, [
              'translation',
              'english',
              'translation_en',
              'en',
            ]),
            'french': _pickString(value, [
              'french',
              'translation_fr',
              'fr',
            ]),
            'transliteration': _pickString(value, [
              'transliteration',
              'latin',
              'romanized',
              'romanisation',
            ]),
          };
        }

        final text = value?.toString() ?? '';
        return {
          'number': entry.key + 1,
          'arabic': text,
          'translation': '',
          'french': '',
          'transliteration': _transliterateArabic(text),
        };
      }).toList();
    }

    if (source['verse'] is Map) {
      final verseMap = source['verse'] as Map;
      final ayahs = <Map<String, dynamic>>[];

      int index = 1;
      for (final entry in verseMap.entries) {
        final arabic = entry.value?.toString() ?? '';
        ayahs.add({
          'number': index,
          'arabic': arabic,
          'translation': '',
          'french': '',
          'transliteration': _transliterateArabic(arabic),
        });
        index++;
      }
      return ayahs;
    }

    if (source['verses'] is List) return source['verses'];
    if (source['items'] is List) return source['items'];
    if (source['data'] is List) return source['data'];

    if (source['data'] is Map<String, dynamic>) {
      final nested = source['data'] as Map<String, dynamic>;
      return _extractAyahs(nested);
    }

    return <dynamic>[];
  }

  String _pickString(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = source[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String _transliterateArabic(String input) {
    const map = {
      'ا': 'a',
      'أ': 'a',
      'إ': 'i',
      'آ': 'aa',
      'ء': '\'',
      'ؤ': 'u',
      'ئ': 'i',
      'ب': 'b',
      'ت': 't',
      'ث': 'th',
      'ج': 'j',
      'ح': 'h',
      'خ': 'kh',
      'د': 'd',
      'ذ': 'dh',
      'ر': 'r',
      'ز': 'z',
      'س': 's',
      'ش': 'sh',
      'ص': 's',
      'ض': 'd',
      'ط': 't',
      'ظ': 'z',
      'ع': '\'',
      'غ': 'gh',
      'ف': 'f',
      'ق': 'q',
      'ك': 'k',
      'ل': 'l',
      'م': 'm',
      'ن': 'n',
      'ه': 'h',
      'ة': 'ah',
      'و': 'w',
      'ي': 'y',
      'ى': 'a',
      'ﻻ': 'la',
      'لا': 'la',
      'ٱ': 'a',
      'َ': 'a',
      'ُ': 'u',
      'ِ': 'i',
      'ً': 'an',
      'ٌ': 'un',
      'ٍ': 'in',
      'ْ': '',
      'ّ': '',
      'ٰ': 'a',
    };

    final buffer = StringBuffer();

    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      if (map.containsKey(char)) {
        buffer.write(map[char]);
      } else {
        buffer.write(char);
      }
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void clearCache() {
    _cache = null;
  }
}