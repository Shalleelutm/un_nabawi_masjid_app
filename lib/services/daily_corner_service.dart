import 'package:shared_preferences/shared_preferences.dart';

class DailyCornerPack {
  final String sunnah;
  final String duaTitle;
  final String duaText;
  final String audioAsset; // stub
  final String kidsQuestion;
  final List<String> kidsChoices;
  final int kidsAnswer;

  DailyCornerPack({
    required this.sunnah,
    required this.duaTitle,
    required this.duaText,
    required this.audioAsset,
    required this.kidsQuestion,
    required this.kidsChoices,
    required this.kidsAnswer,
  });
}

class DailyCornerService {
  DailyCornerService._();

  static const _kDone = 'daily_corner_done_v1';

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static Future<bool> isDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDone) == _dayKey(DateTime.now());
  }

  static Future<void> markDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDone, _dayKey(DateTime.now()));
  }

  // Deterministic daily selection (same for everyone each day, offline-first)
  static DailyCornerPack todayPack() {
    final d = DateTime.now();
    final seed = (d.year * 10000 + d.month * 100 + d.day) % 7;

    final sunnah = [
      'Smile — it is charity.',
      'Say Bismillah before eating.',
      'Keep wudu as much as possible.',
      'Pray 2 rak‘ah before Fajr (Sunnah).',
      'Make dhikr after salah.',
      'Speak good or remain silent.',
      'Help your neighbour quietly.',
    ][seed];

    final duaTitle = [
      'Morning remembrance',
      'Entering home',
      'Leaving home',
      'Before sleep',
      'After salah',
      'For parents',
      'For guidance',
    ][seed];

    final duaText = [
      'Allahumma bika asbahna wa bika amsayna… (short)',
      'Bismillahi walajna wa bismillahi kharajna… (short)',
      'Bismillah, tawakkaltu ‘alallah… (short)',
      'Bismika Allahumma amutu wa ahya.',
      'Astaghfirullah • SubhanAllah • Alhamdulillah • Allahu Akbar',
      'Rabbirhamhuma kama rabbayani saghira.',
      'Allahumma ihdina siratal mustaqim.',
    ][seed];

    final kidsQ = [
      'How many daily prayers are there?',
      'What do we say before eating?',
      'Which month do Muslims fast?',
      'What is the direction of prayer called?',
      'What do we call charity in Islam?',
      'Who is the final Prophet?',
      'What book was revealed to Prophet Muhammad ﷺ?',
    ][seed];

    final kidsChoices = [
      ['3', '5', '7', '10'],
      ['Alhamdulillah', 'Bismillah', 'SubhanAllah', 'Allahu Akbar'],
      ['Muharram', 'Ramadan', 'Safar', 'Rajab'],
      ['Qibla', 'Salah', 'Wudu', 'Zakat'],
      ['Zakat', 'Hajj', 'Umrah', 'Eid'],
      ['Musa', 'Isa', 'Muhammad ﷺ', 'Ibrahim'],
      ['Bible', 'Torah', 'Quran', 'Psalms'],
    ][seed];

    final kidsAnswer = [1, 1, 1, 0, 0, 2, 2][seed];

    return DailyCornerPack(
      sunnah: sunnah,
      duaTitle: duaTitle,
      duaText: duaText,
      audioAsset: 'assets/audio/dua_stub.mp3',
      kidsQuestion: kidsQ,
      kidsChoices: kidsChoices,
      kidsAnswer: kidsAnswer,
    );
  }
}
