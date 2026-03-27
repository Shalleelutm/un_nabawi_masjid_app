import 'dart:math';

class QuizAIService {
  int difficulty = 1;
  int correct = 0;
  int wrong = 0;
  final Random _random = Random();

  void registerAnswer(bool isCorrect) {
    if (isCorrect) {
      correct++;
      wrong = 0;
      if (correct >= 3 && difficulty < 5) {
        difficulty++;
        correct = 0;
      }
    } else {
      wrong++;
      correct = 0;
      if (wrong >= 2 && difficulty > 1) {
        difficulty--;
        wrong = 0;
      }
    }
  }

  Map<String, Object> generateQuestion() {
    final List<Map<String, Object>> pool = <Map<String, Object>>[
      <String, Object>{
        'question': 'Which Surah is the first in the Quran?',
        'options': <String>['Al-Fatiha', 'Al-Baqarah', 'Al-Ikhlas', 'An-Nas'],
        'answer': 0,
        'difficulty': 1,
      },
      <String, Object>{
        'question': 'How many daily obligatory prayers are there?',
        'options': <String>['3', '4', '5', '6'],
        'answer': 2,
        'difficulty': 1,
      },
      <String, Object>{
        'question': 'Which prayer comes after Maghrib?',
        'options': <String>['Fajr', 'Asr', 'Isha', 'Dhuhr'],
        'answer': 2,
        'difficulty': 2,
      },
      <String, Object>{
        'question': 'What is the night prayer called?',
        'options': <String>['Ishraq', 'Tahajjud', 'Istikhara', 'Duha'],
        'answer': 1,
        'difficulty': 3,
      },
      <String, Object>{
        'question': 'What is the Friday congregational prayer called?',
        'options': <String>['Tarawih', 'Jumuah', 'Tahajjud', 'Witr'],
        'answer': 1,
        'difficulty': 2,
      },
    ];

    final List<Map<String, Object>> filtered = pool.where((Map<String, Object> item) {
      return item['difficulty'] == difficulty;
    }).toList();

    final List<Map<String, Object>> source =
        filtered.isEmpty ? pool : filtered;

    return source[_random.nextInt(source.length)];
  }
}