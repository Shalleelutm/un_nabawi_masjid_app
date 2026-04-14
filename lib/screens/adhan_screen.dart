// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AdhanScreen extends StatefulWidget {
  final String prayer;
  const AdhanScreen({super.key, required this.prayer});

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.setAsset('assets/audio/adhan.mp3');
    player.play();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "🔔 ${widget.prayer} Adhan",
          style: const TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
    );
  }
}