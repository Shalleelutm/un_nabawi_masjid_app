import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AdhanScreen extends StatefulWidget {
  final String prayerName;
  const AdhanScreen({super.key, this.prayerName = 'Prayer'});

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _play();
  }

  Future<void> _play() async {
    await _player.play(AssetSource('audio/adhan.mp3'));
    await Vibration.vibrate(duration: 2000);
  }

  Future<void> _pause() async {
    await _player.pause();
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
  }

  Future<void> _resume() async {
    await _player.resume();
    setState(() {
      _isPaused = false;
      _isPlaying = true;
    });
  }

  Future<void> _stop() async {
    await _player.stop();
    await Vibration.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _player.dispose();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mosque, color: Colors.amber, size: 100),

            const SizedBox(height: 20),

            Text(
              '${widget.prayerName} Time',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'اللَّهُ أَكْبَرُ',
              style: TextStyle(color: Colors.white, fontSize: 36),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _stop,
                  child: const Text('Stop'),
                ),

                const SizedBox(width: 12),

                if (_isPlaying)
                  ElevatedButton(
                    onPressed: _pause,
                    child: const Text('Pause'),
                  ),

                if (_isPaused)
                  ElevatedButton(
                    onPressed: _resume,
                    child: const Text('Resume'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}