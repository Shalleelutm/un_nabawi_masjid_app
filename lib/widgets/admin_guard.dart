import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login first.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You are not authorized to access this section.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return child;
  }
}