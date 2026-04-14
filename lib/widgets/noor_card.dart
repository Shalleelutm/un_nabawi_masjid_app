// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NoorCard extends StatelessWidget {
  final Widget child;

  const NoorCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.8),
            Colors.black
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.6),
            blurRadius: 25,
          )
        ],
      ),
      child: child,
    );
  }
}