import 'package:flutter/material.dart';
import '../../core/app_routes.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Home'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open Dashboard'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.nextSalah,
            );
          },
        ),
      ),
    );
  }
}