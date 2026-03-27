// lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });
}
