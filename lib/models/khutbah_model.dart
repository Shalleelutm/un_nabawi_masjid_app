class Khutbah {
  final String id;
  final String title;
  final String date;
  final String content;
  final String? audioAsset;

  Khutbah({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
    this.audioAsset,
  });
}
