import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playAdhanAsset({double volume = 1.0}) async {
    // ✅ Plays your existing file:
    // assets/audio/azaan_audio.mp3
    await _player.stop();
    await _player.setVolume(volume);
    await _player.play(AssetSource('audio/azaan_audio.mp3'));
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
