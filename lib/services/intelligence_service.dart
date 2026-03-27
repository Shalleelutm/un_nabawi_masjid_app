class IntelligenceService {
  IntelligenceService._();

  /// ✅ Safe offline “AI stub” (NO fatwa, no risky answers)
  /// It guides users to verified sources and local Imam/Scholar.
  static String safeIslamicAnswer(String question) {
    final q = question.trim().toLowerCase();

    if (q.isEmpty) {
      return 'Please type your question. For serious matters, consult a trusted local Imam or qualified scholar.';
    }

    if (q.contains('zakat') || q.contains('zakaat')) {
      return 'Zakat depends on your nisab and your holdings over a lunar year. For an exact calculation, use the Zakat calculator in the app (Phase Finance), and confirm with a qualified scholar.';
    }

    if (q.contains('wudu') || q.contains('wudhu')) {
      return 'Wudu is performed by: intention, washing face, arms to elbows, wiping head, washing feet to ankles—maintaining order. If unsure in a specific case, consult a trusted Imam.';
    }

    if (q.contains('prayer') || q.contains('salah') || q.contains('salat')) {
      return 'For prayer questions, the safest path is to follow authentic sources and your local Masjid’s guidance. If this concerns missed prayers, travel, illness, or special situations—please consult a qualified scholar.';
    }

    return 'This offline assistant gives only general guidance. For rulings (fatwa) and sensitive issues, consult a qualified scholar or your Masjid Imam. You can also check trusted sources like authentic Hadith collections and reputable fiqh references.';
  }
}