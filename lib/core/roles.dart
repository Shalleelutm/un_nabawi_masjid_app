enum AppRole { visitor, user, admin }

extension RoleName on AppRole {
  String get label {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.user:
        return 'Member';
      case AppRole.visitor:
        return 'Visitor';
    }
  }
}
