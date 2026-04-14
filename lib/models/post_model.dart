// ignore_for_file: unnecessary_type_check

class PostModel {
  final String id;
  final String text;
  final int likes;
  final String userName;
  final DateTime? createdAt;

  const PostModel({
    required this.id,
    required this.text,
    required this.likes,
    required this.userName,
    required this.createdAt,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> data) {
    return PostModel(
      id: id,
      text: (data['text'] ?? '').toString(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      userName: (data['userName'] ?? 'Member').toString(),
      createdAt: data['createdAt'] is dynamic && data['createdAt'] != null
          ? data['createdAt'].toDate()
          : null,
    );
  }
}