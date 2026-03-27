import 'package:flutter/material.dart';

import '../../services/quran_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await QuranService.instance.loadAllSurahs();

      if (!mounted) return;

      setState(() {
        _surahs = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
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
    final candidates = <dynamic>[
      surah['nameEnglish'],
      surah['englishName'],
      surah['english'],
      surah['name'],
      surah['title'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return 'Surah ${index + 1}';
  }

  String _surahArabicName(Map<String, dynamic> surah) {
    final candidates = <dynamic>[
      surah['nameArabic'],
      surah['arabicName'],
      surah['arabic'],
      surah['name_ar'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return '';
  }

  String _surahType(Map<String, dynamic> surah) {
    final candidates = <dynamic>[
      surah['revelationType'],
      surah['revelation'],
      surah['type'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return '';
  }

  List<dynamic> _versesOf(Map<String, dynamic> surah) {
    final candidates = <dynamic>[
      surah['ayahs'],
      surah['verses'],
      surah['items'],
      surah['data'],
    ];

    for (final value in candidates) {
      if (value is List) return value;
    }

    return <dynamic>[];
  }

  String _ayahArabic(dynamic verse) {
    if (verse is String) return verse;

    if (verse is Map) {
      final candidates = <dynamic>[
        verse['arabic'],
        verse['text'],
        verse['ayah'],
        verse['content'],
      ];

      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }

    return verse?.toString() ?? '';
  }

  String _ayahEnglish(dynamic verse) {
    if (verse is Map) {
      final candidates = <dynamic>[
        verse['translation'],
        verse['english'],
        verse['translation_en'],
        verse['en'],
      ];

      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }

    return '';
  }

  String _ayahFrench(dynamic verse) {
    if (verse is Map) {
      final candidates = <dynamic>[
        verse['french'],
        verse['translation_fr'],
        verse['fr'],
      ];

      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }

    return '';
  }

  String _ayahTransliteration(dynamic verse) {
    if (verse is Map) {
      final candidates = <dynamic>[
        verse['transliteration'],
        verse['latin'],
        verse['romanized'],
        verse['romanisation'],
      ];

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
        if (transliteration.isNotEmpty && en.isNotEmpty) {
          return '$transliteration\n\nEnglish:\n$en';
        }
        if (transliteration.isNotEmpty) return transliteration;
        if (en.isNotEmpty) return en;
        return 'Transliteration not available.';
      case 'french':
        if (transliteration.isNotEmpty && fr.isNotEmpty) {
          return '$transliteration\n\nFrançais:\n$fr';
        }
        if (transliteration.isNotEmpty) return transliteration;
        if (fr.isNotEmpty) return 'Français:\n$fr';
        return 'Transliteration not available.';
      case 'both':
      default:
        final parts = <String>[];
        if (transliteration.isNotEmpty) parts.add(transliteration);
        if (en.isNotEmpty) parts.add('English:\n$en');
        if (fr.isNotEmpty) parts.add('Français:\n$fr');
        if (parts.isEmpty) return 'Transliteration not available.';
        return parts.join('\n\n');
    }
  }

  void _openSurah(Map<String, dynamic> surah, int index) {
    final verses = _versesOf(surah);
    final englishName = _surahEnglishName(surah, index);
    final arabicName = _surahArabicName(surah);
    final type = _surahType(surah);

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
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Column(
                  children: [
                    WowText(
                      englishName,
                      size: 28,
                      textAlign: TextAlign.center,
                    ),
                    if (arabicName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        arabicName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.6,
                        ),
                      ),
                    ],
                    if (type.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        type,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text(
                            'Arabic + English/French',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: _language == 'both',
                          onSelected: (_) {
                            setState(() => _language = 'both');
                            Navigator.pop(context);
                            _openSurah(surah, index);
                          },
                        ),
                        ChoiceChip(
                          label: const Text(
                            'English',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: _language == 'english',
                          onSelected: (_) {
                            setState(() => _language = 'english');
                            Navigator.pop(context);
                            _openSurah(surah, index);
                          },
                        ),
                        ChoiceChip(
                          label: const Text(
                            'French',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: _language == 'french',
                          onSelected: (_) {
                            setState(() => _language = 'french');
                            Navigator.pop(context);
                            _openSurah(surah, index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: verses.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'This surah loaded successfully but contains no ayah list.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        itemCount: verses.length,
                        itemBuilder: (_, verseIndex) {
                          final verse = verses[verseIndex];
                          return QuranPageCard(
                            surahName: englishName,
                            arabicText: _ayahArabic(verse),
                            translation: _translationFor(verse),
                            ayahNumber: _ayahNumber(verse, verseIndex),
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
    final text = Theme.of(context).textTheme;
    final filtered = <Map<String, dynamic>>[];

    for (var i = 0; i < _surahs.length; i++) {
      if (_matches(_surahs[i], i)) {
        filtered.add(_surahs[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Reader'),
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
                            const Icon(Icons.error_outline_rounded, size: 46),
                            const SizedBox(height: 12),
                            Text(
                              'Quran data failed to load.',
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
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
                          Text(
                            'Read all 114 surahs with Arabic and transliteration.',
                            style: text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _query = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search by surah name or number',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (filtered.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('No surah matched your search.'),
                              ),
                            ),
                          ...List.generate(filtered.length, (visibleIndex) {
                            final surah = filtered[visibleIndex];
                            final realIndex = _surahs.indexOf(surah);
                            final number = _surahNumber(surah, realIndex);
                            final englishName =
                                _surahEnglishName(surah, realIndex);
                            final arabicName = _surahArabicName(surah);
                            final type = _surahType(surah);
                            final verseCount = _versesOf(surah).length;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.96),
                                    const Color(0xFFEFF7F2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                onTap: () => _openSurah(surah, realIndex),
                                minVerticalPadding: 12,
                                leading: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF007A3D),
                                        Color(0xFF111111),
                                        Color(0xFFCE1126),
                                      ],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$number',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  englishName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (arabicName.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        arabicName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        if (type.isNotEmpty) type,
                                        '$verseCount ayahs',
                                      ].join(' • '),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Colors.black.withValues(alpha: 0.68),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing:
                                    const Icon(Icons.arrow_forward_ios_rounded),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}