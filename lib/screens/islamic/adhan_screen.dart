import 'package:flutter/material.dart';

class AdhanScreen extends StatelessWidget {
  final String prayer;

  const AdhanScreen({
    super.key,
    required this.prayer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '$prayer\nTime for Salah',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}