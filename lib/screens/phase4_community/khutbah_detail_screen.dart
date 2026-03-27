import 'package:flutter/material.dart';
import '../../models/khutbah_model.dart';
import '../../services/audio_service.dart';

class KhutbahDetailScreen extends StatelessWidget {
  final Khutbah khutbah;

  const KhutbahDetailScreen({super.key, required this.khutbah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(khutbah.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              khutbah.date,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  khutbah.content,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ),
            if (khutbah.audioAsset != null)
              ElevatedButton.icon(
                onPressed: () {
                  AudioService.instance.playAdhanAsset();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Khutbah Audio'),
              ),
          ],
        ),
      ),
    );
  }
}
