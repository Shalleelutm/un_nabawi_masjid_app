import 'package:just_audio/just_audio.dart';

class SoundService {
  SoundService._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAzanPreview() async {
    await _player.setAsset('assets/audio/azan_preview.mp3');
    await _player.play();
  }

  static Future<void> playCelebration() async {
    await _player.setAsset('assets/audio/celebration.mp3');
    await _player.play();
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}