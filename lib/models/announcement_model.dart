class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String category;
  final DateTime createdAt;
  final String createdBy;
  final bool approved;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    required this.createdBy,
    required this.approved,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      category: map['category'] ?? 'general',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      approved: map['approved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'approved': approved,
    };
  }
}
