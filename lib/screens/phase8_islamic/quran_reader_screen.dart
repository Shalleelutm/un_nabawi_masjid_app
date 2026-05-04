// ignore_for_file: unused_element, unused_local_variable, prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/quran_service.dart';
import '../../services/bookmark_service.dart';
import '../../services/reading_progress_service.dart';
import '../../widgets/palestine_gradient_background.dart';
import '../../widgets/quran_page_card.dart';
import '../../widgets/wow_text.dart';

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  List<Map<String, dynamic>> _surahs = <Map<String, dynamic>>[];
  bool _loading = true;
  String _query = '';
  String _language = 'both';
  String? _error;

  final List<Map<String, String>> _availableLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'ur', 'name': 'Urdu', 'flag': '🇵🇰'},
    {'code': 'bn', 'name': 'Bengali', 'flag': '🇧🇩'},
    {'code': 'tr', 'name': 'Turkish', 'flag': '🇹🇷'},
    {'code': 'id', 'name': 'Indonesian', 'flag': '🇮🇩'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
  ];
  
  String _selectedTranslationLang = 'en';
  bool _showTafsir = false;
  bool _showWordByWord = false;

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  void _showAyahMeaning(dynamic verse, int surahIndex) {
    final arabic = _ayahArabic(verse);
    final transliteration = _ayahTransliteration(verse);
    final english = _ayahEnglish(verse);
    final french = _ayahFrench(verse);
    final urdu = _ayahUrdu(verse);
    final bengali = _ayahBengali(verse);
    final turkish = _ayahTurkish(verse);
    final indonesian = _ayahIndonesian(verse);
    final spanish = _ayahSpanish(verse);
    final german = _ayahGerman(verse);
    final tafsir = _ayahTafsir(verse);
    final wordByWord = _ayahWordByWord(verse);
    final verseNumber = _ayahNumber(verse, 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ayah $verseNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.translate, color: _showTafsir ? Colors.green : Colors.grey),
                                  onPressed: () => setSheetState(() => _showTafsir = !_showTafsir),
                                  tooltip: 'Show Tafsir',
                                ),
                                IconButton(
                                  icon: Icon(Icons.text_fields, color: _showWordByWord ? Colors.green : Colors.grey),
                                  onPressed: () => setSheetState(() => _showWordByWord = !_showWordByWord),
                                  tooltip: 'Word by Word',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _availableLanguages.map((lang) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text('${lang['flag']} ${lang['name']}', style: TextStyle(fontSize: 12)),
                                  selected: _selectedTranslationLang == lang['code'],
                                  onSelected: (_) => setSheetState(() => _selectedTranslationLang = lang['code']!),
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.green.shade100,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          arabic,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.8,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (transliteration.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            transliteration,
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_showWordByWord && wordByWord.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📖 Word by Word', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 8),
                          Text(wordByWord, style: const TextStyle(height: 1.5, color: Colors.black87)),
                        ],
                      ),
                    ),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📖 ${_getLanguageName(_selectedTranslationLang)} Translation', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                        const SizedBox(height: 8),
                        Text(_getTranslationForLanguage(verse, _selectedTranslationLang), 
                            style: const TextStyle(height: 1.5, color: Colors.black87)),
                      ],
                    ),
                  ),
                  
                  if (_showTafsir && tafsir.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📚 Tafsir (Explanation)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 8),
                          Text(tafsir, style: const TextStyle(height: 1.5, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // ✅ ROW WITH BOOKMARK + SHARE + CLOSE
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ✅ BOOKMARK BUTTON ADDED
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            BookmarkService.add(arabic);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ayah bookmarked!')),
                            );
                          },
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Bookmark'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ✅ SHARE BUTTON FIXED
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final shareText = '$arabic\n\n${_getTranslationForLanguage(verse, _selectedTranslationLang)}';
                            Share.share(shareText);
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLanguageName(String code) {
    final lang = _availableLanguages.firstWhere((l) => l['code'] == code, orElse: () => {'name': 'English'});
    return lang['name']!;
  }

  String _getTranslationForLanguage(dynamic verse, String langCode) {
    switch (langCode) {
      case 'en': return _ayahEnglish(verse);
      case 'fr': return _ayahFrench(verse);
      case 'ur': return _ayahUrdu(verse);
      case 'bn': return _ayahBengali(verse);
      case 'tr': return _ayahTurkish(verse);
      case 'id': return _ayahIndonesian(verse);
      case 'es': return _ayahSpanish(verse);
      case 'de': return _ayahGerman(verse);
      default: return _ayahEnglish(verse);
    }
  }

  // ✅ FIXED: Changed from loadQuran() to loadAllSurahs()
  Future<void> _loadQuran() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await QuranService.instance.loadAllSurahs();
      if (!mounted) return;
      setState(() { _surahs = data; _loading = false; });
      print('✅ Quran loaded: ${data.length} surahs');
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
      print('❌ Quran load error: $e');
    }
  }

  Future<void> _reload() async {
    QuranService.instance.clearCache();
    await _loadQuran();
  }

  int _surahNumber(Map<String, dynamic> surah, int index) {
    final value = surah['number'] ?? surah['id'] ?? surah['surahNumber'];
    return int.tryParse(value?.toString() ?? '') ?? (index + 1);
  }

  String _surahEnglishName(Map<String, dynamic> surah, int index) {
    final candidates = [surah['nameEnglish'], surah['englishName'], surah['english'], surah['name'], surah['title']];
    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return 'Surah ${index + 1}';
  }

  String _surahArabicName(Map<String, dynamic> surah) {
    final candidates = [surah['nameArabic'], surah['arabicName'], surah['arabic'], surah['name_ar']];
    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _surahType(Map<String, dynamic> surah) {
    final candidates = [surah['revelationType'], surah['revelation'], surah['type']];
    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  List<dynamic> _versesOf(Map<String, dynamic> surah) {
    final candidates = [surah['ayahs'], surah['verses'], surah['items'], surah['data']];
    for (final value in candidates) {
      if (value is List) return value;
    }
    return [];
  }

  String _ayahArabic(dynamic verse) {
    if (verse is String) return verse;
    if (verse is Map) {
      final candidates = [verse['arabic'], verse['text'], verse['ayah'], verse['content']];
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
    return verse?.toString() ?? '';
  }

  String _ayahEnglish(dynamic verse) {
    if (verse is Map) {
      final candidates = [verse['translation'], verse['english'], verse['translation_en'], verse['en']];
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  String _ayahFrench(dynamic verse) {
    if (verse is Map) {
      final candidates = [verse['french'], verse['translation_fr'], verse['fr']];
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  String _ayahUrdu(dynamic verse) {
    if (verse is Map) {
      return verse['urdu']?.toString() ?? verse['translation_ur']?.toString() ?? '';
    }
    return '';
  }

  String _ayahBengali(dynamic verse) {
    if (verse is Map) {
      return verse['bengali']?.toString() ?? verse['translation_bn']?.toString() ?? '';
    }
    return '';
  }

  String _ayahTurkish(dynamic verse) {
    if (verse is Map) {
      return verse['turkish']?.toString() ?? verse['translation_tr']?.toString() ?? '';
    }
    return '';
  }

  String _ayahIndonesian(dynamic verse) {
    if (verse is Map) {
      return verse['indonesian']?.toString() ?? verse['translation_id']?.toString() ?? '';
    }
    return '';
  }

  String _ayahSpanish(dynamic verse) {
    if (verse is Map) {
      return verse['spanish']?.toString() ?? verse['translation_es']?.toString() ?? '';
    }
    return '';
  }

  String _ayahGerman(dynamic verse) {
    if (verse is Map) {
      return verse['german']?.toString() ?? verse['translation_de']?.toString() ?? '';
    }
    return '';
  }

  String _ayahTafsir(dynamic verse) {
    if (verse is Map) {
      return verse['tafsir']?.toString() ?? verse['explanation']?.toString() ?? '';
    }
    return '';
  }

  String _ayahWordByWord(dynamic verse) {
    if (verse is Map) {
      return verse['wordByWord']?.toString() ?? verse['word_for_word']?.toString() ?? '';
    }
    return '';
  }

  String _ayahTransliteration(dynamic verse) {
    if (verse is Map) {
      final candidates = [verse['transliteration'], verse['latin'], verse['romanized'], verse['romanisation']];
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  int _ayahNumber(dynamic verse, int index) {
    if (verse is Map) {
      final value = verse['number'] ?? verse['id'] ?? verse['verseNumber'];
      return int.tryParse(value?.toString() ?? '') ?? (index + 1);
    }
    return index + 1;
  }

  bool _matches(Map<String, dynamic> surah, int index) {
    if (_query.trim().isEmpty) return true;
    final q = _query.trim().toLowerCase();
    final english = _surahEnglishName(surah, index).toLowerCase();
    final arabic = _surahArabicName(surah).toLowerCase();
    final num = _surahNumber(surah, index).toString();
    return english.contains(q) || arabic.contains(q) || num.contains(q);
  }

  String _translationFor(dynamic verse) {
    final transliteration = _ayahTransliteration(verse);
    final en = _ayahEnglish(verse);
    final fr = _ayahFrench(verse);
    switch (_language) {
      case 'english':
        if (transliteration.isNotEmpty) return '$transliteration\n\nEnglish:\n$en';
        if (en.isNotEmpty) return en;
        return 'Translation not available.';
      case 'french':
        if (transliteration.isNotEmpty) return '$transliteration\n\nFrançais:\n$fr';
        if (fr.isNotEmpty) return fr;
        return 'Translation not available.';
      default:
        final parts = <String>[];
        if (transliteration.isNotEmpty) parts.add(transliteration);
        if (en.isNotEmpty) parts.add('English:\n$en');
        if (fr.isNotEmpty) parts.add('Français:\n$fr');
        if (parts.isEmpty) return 'Translation not available.';
        return parts.join('\n\n');
    }
  }

  void _openSurah(Map<String, dynamic> surah, int index) async {
    final verses = _versesOf(surah);
    final englishName = _surahEnglishName(surah, index);
    final arabicName = _surahArabicName(surah);
    final type = _surahType(surah);
    
    // ✅ SAVE READING PROGRESS
    await ReadingProgressService.save(index);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F3EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 46, height: 5, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.black.withValues(alpha: 0.18))),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Column(
                  children: [
                    WowText(englishName, size: 28, textAlign: TextAlign.center),
                    if (arabicName.isNotEmpty) ...[const SizedBox(height: 8), Text(arabicName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.6, color: Colors.black))],
                    if (type.isNotEmpty) ...[const SizedBox(height: 6), Text(type, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87))],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ChoiceChip(label: const Text('Arabic + English/French'), selected: _language == 'both', onSelected: (_) => setState(() => _language = 'both')),
                        ChoiceChip(label: const Text('English'), selected: _language == 'english', onSelected: (_) => setState(() => _language = 'english')),
                        ChoiceChip(label: const Text('French'), selected: _language == 'french', onSelected: (_) => setState(() => _language = 'french')),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: verses.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('This surah loaded successfully but contains no ayah list.')))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        itemCount: verses.length,
                        itemBuilder: (_, verseIndex) {
                          final verse = verses[verseIndex];
                          return GestureDetector(
                            onTap: () => _showAyahMeaning(verse, index),
                            child: QuranPageCard(
                              surahName: englishName,
                              arabicText: _ayahArabic(verse),
                              translation: _translationFor(verse),
                              ayahNumber: _ayahNumber(verse, verseIndex),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔴 QuranScreen build - surahs: ${_surahs.length}, loading: $_loading, error: $_error');
    final text = Theme.of(context).textTheme;
    
    final filtered = _surahs.where((surah) => _matches(surah, _surahs.indexOf(surah))).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Reader', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        actions: [
          // ✅ NIGHT MODE BUTTON
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Night mode coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('About Quran Reader'),
                  content: const Text(
                    '• Tap any ayah to see detailed meaning\n'
                    '• Multiple language translations available\n'
                    '• Toggle Tafsir for deeper understanding\n'
                    '• Word by word translation available\n'
                    '• Search by surah name or number\n'
                    '• Bookmark ayahs\n'
                    '• Share ayahs\n'
                    '• Continue reading from last position',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: PalestineGradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 46, color: Colors.red),
                            const SizedBox(height: 12),
                            Text('Quran data failed to load.', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.black)),
                            const SizedBox(height: 8),
                            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        children: [
                          const WowText('Holy Quran', size: 30),
                          const SizedBox(height: 8),
                          Text('Read all 114 surahs with Arabic and translation. Tap any ayah for detailed meaning with multiple translations, Tafsir, and word-by-word analysis.', 
                              style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(height: 14),
                          
                          // ✅ CONTINUE READING BUTTON ADDED
                          FutureBuilder<int?>(
                            future: ReadingProgressService.get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const SizedBox.shrink();
                              }
                              final lastSurahIndex = snapshot.data!;
                              if (lastSurahIndex >= _surahs.length) {
                                return const SizedBox.shrink();
                              }
                              final lastSurah = _surahs[lastSurahIndex];
                              final lastSurahName = _surahEnglishName(lastSurah, lastSurahIndex);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final surah = _surahs[lastSurahIndex];
                                    _openSurah(surah, lastSurahIndex);
                                  },
                                  icon: const Icon(Icons.history),
                                  label: Text('Continue Reading: $lastSurahName'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade100,
                                    foregroundColor: Colors.green.shade900,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          TextField(
                            onChanged: (value) => setState(() => _query = value),
                            decoration: const InputDecoration(
                              hintText: 'Search by surah name or number',
                              prefixIcon: Icon(Icons.search_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (filtered.isEmpty) 
                            const Padding(
                              padding: EdgeInsets.all(24), 
                              child: Center(child: Text('No surah matched your search.')),
                            ),
                          ...filtered.map((surah) {
                            final realIndex = _surahs.indexOf(surah);
                            final number = _surahNumber(surah, realIndex);
                            final englishName = _surahEnglishName(surah, realIndex);
                            final arabicName = _surahArabicName(surah);
                            final type = _surahType(surah);
                            final verseCount = _versesOf(surah).length;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.96), const Color(0xFFEFF7F2)]),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                              ),
                              child: ListTile(
                                onTap: () => _openSurah(surah, realIndex),
                                minVerticalPadding: 12,
                                leading: Container(
                                  width: 52, height: 52,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [Color(0xFF007A3D), Color(0xFF111111), Color(0xFFCE1126)]),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                ),
                                title: Text(englishName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (arabicName.isNotEmpty) ...[const SizedBox(height: 4), Text(arabicName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.5, color: Colors.black87))],
                                    const SizedBox(height: 4),
                                    Text('${type.isNotEmpty ? "$type • " : ""}$verseCount ayahs', 
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black.withValues(alpha: 0.68))),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.menu_book, color: Colors.green),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reload,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.refresh),
        label: const Text("Reload Quran"),
      ),
    );
  }
}