class HadithModel {
  final String id;
  final String title;
  final String arabic;
  final String translation;
  final String source; // e.g. Bukhari, Muslim, etc.
  final String grade;  // e.g. Sahih, Hasan
  final List<String> tags;

  const HadithModel({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    required this.source,
    required this.grade,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'arabic': arabic,
        'translation': translation,
        'source': source,
        'grade': grade,
        'tags': tags,
      };

  factory HadithModel.fromJson(Map<String, dynamic> j) => HadithModel(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        arabic: (j['arabic'] ?? '').toString(),
        translation: (j['translation'] ?? '').toString(),
        source: (j['source'] ?? '').toString(),
        grade: (j['grade'] ?? '').toString(),
        tags: (j['tags'] is List) ? (j['tags'] as List).map((e) => e.toString()).toList() : const [],
      );
}