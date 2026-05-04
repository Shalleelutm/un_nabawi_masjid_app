import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  SoundService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playAdhan() async {
    try {
      await stop();
      _isPlaying = true;
      
      // Fix for fast playback - set normal speed
      await _player.setSpeed(1.0);
      await _player.setAsset('assets/audio/adhan.mp3');
      await _player.play();
      
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(pattern: [500, 500, 500, 500, 1000]);
      }
    } catch (e) {
      print('Error playing adhan: $e');
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 2000);
      }
    }
  }

  static Future<void> playAzanPreview() async {
    await playAdhan();
  }

  static Future<void> playCelebration() async {
    try {
      await stop();
      _isPlaying = true;
      await _player.setSpeed(1.0);
      await _player.setAsset('assets/audio/celebration.mp3');
      await _player.play();
    } catch (e) {
      print('Error playing celebration: $e');
    }
  }

  static Future<void> stop() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}