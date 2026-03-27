import 'package:audioplayers/audioplayers.dart';

class QuranAudioService {
  QuranAudioService._();
  static final instance = QuranAudioService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSurah(int surah) async {
    final url =
        'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${surah.toString().padLeft(3, '0')}.mp3';

    await _player.play(UrlSource(url));
  }

  Future<void> stop() async {
    await _player.stop();
  }
}