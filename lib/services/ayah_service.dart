// ignore_for_file: prefer_single_quotes

class AyahService {
  static List<String> ayahs = [
    "Indeed, Allah is with the patient. (2:153)",
    "So remember Me; I will remember you. (2:152)",
    "Allah does not burden a soul beyond it can bear. (2:286)"
  ];

  static String getDailyAyah() {
    final day = DateTime.now().day;
    return ayahs[day % ayahs.length];
  }
}