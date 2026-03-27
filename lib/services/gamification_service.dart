import '../models/achievement_model.dart';

class GamificationService {
  GamificationService._();

  static int levelFromXp(int xp) {
    if (xp <= 0) return 1;
    return (xp ~/ 150) + 1;
    }

  static int progressToNextLevel(int xp) {
    return xp % 150;
  }

  static List<Achievement> defaultAchievements() {
    return const <Achievement>[
      Achievement(
        id: 'fajr_7',
        title: 'Fajr Champion',
        description: 'Complete 7 Fajr prayers on time',
        xp: 100,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Steady Worshipper',
        description: 'Reach a 30 day prayer streak',
        xp: 250,
      ),
      Achievement(
        id: 'quran_10',
        title: 'Quran Companion',
        description: 'Read 10 Quran sessions',
        xp: 120,
      ),
    ];
  }
}