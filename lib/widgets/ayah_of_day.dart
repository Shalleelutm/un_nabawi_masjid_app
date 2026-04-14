// ignore_for_file: prefer_single_quotes

import 'dart:math';
import 'package:flutter/material.dart';

class AyahOfDay extends StatelessWidget {
  const AyahOfDay({super.key});

  static const ayat = [
    "Indeed, Allah is with the patient. (2:153)",
    "So remember Me; I will remember you. (2:152)",
    "Allah does not burden a soul beyond it can bear. (2:286)",
    "And He found you lost and guided you. (93:7)",
  ];

  @override
  Widget build(BuildContext context) {
    final randomAyah = ayat[Random().nextInt(ayat.length)];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        randomAyah,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}