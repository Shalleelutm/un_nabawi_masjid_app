import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/roles.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final isAdmin = auth.role == AppRole.admin;

    return Scaffold(
      appBar: AppBar(title: const Text('Users (Phase 5)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isAdmin
                  ? 'Admin view: Phase 5 will show members list, dues status, block/unblock.'
                  : 'Member view: Phase 5 will show your profile, dues balance, and history.',
              style: const TextStyle(height: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}
