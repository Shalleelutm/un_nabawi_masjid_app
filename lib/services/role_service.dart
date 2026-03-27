import '../models/user_role.dart';

class RoleService {
  UserRole _currentRole = UserRole.visitor;

  UserRole get currentRole => _currentRole;

  bool get isAdmin => _currentRole == UserRole.admin;
  bool get isMember => _currentRole == UserRole.member;

  void setRole(UserRole role) {
    _currentRole = role;
  }
}
