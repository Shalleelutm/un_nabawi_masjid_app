class QuranAyah {
  final int number;
  final String arabic;
  final String translation;

  const QuranAyah({
    required this.number,
    required this.arabic,
    required this.translation,
  });
}

class QuranSurah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final List<QuranAyah> ayahs;

  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.ayahs,
  });

  int get verseCount => ayahs.length;
}