// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AdhanScreen extends StatefulWidget {
  const AdhanScreen({super.key});

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playAdhan();
  }

  Future<void> _playAdhan() async {
    await _player.play(AssetSource('audio/adhan.mp3'));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mosque_rounded,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 30),
            const Text(
              "Allahu Akbar",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Prayer Time",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Dismiss"),
            )
          ],
        ),
      ),
    );
  }
}