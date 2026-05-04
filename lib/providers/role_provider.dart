import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { guest, member, admin }

class RoleProvider extends ChangeNotifier {
  UserRole _role = UserRole.guest;
  
  // List of admin emails (hardcoded for security)
  static const List<String> adminEmails = [
    'iqbal.elahee@gmail.com',
    'shalleel.mohamud@umail.utm.ac.mu',
    'admin@test.com',  // Your admin email
  ];

  UserRole get role => _role;

  Future<void> loadRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _role = UserRole.guest;
      notifyListeners();
      return;
    }

    final userEmail = user.email?.toLowerCase() ?? '';
    
    // Check if email is in admin list
    if (adminEmails.contains(userEmail)) {
      _role = UserRole.admin;
    } else {
      _role = UserRole.member;
    }

    notifyListeners();
  }

  bool get isGuest => _role == UserRole.guest;
  bool get isMember => _role == UserRole.member;
  bool get isAdmin => _role == UserRole.admin;
}