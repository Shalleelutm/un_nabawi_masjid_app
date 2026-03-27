import 'package:flutter/foundation.dart';

class IslamicQuestion {
  final String id;
  final String question;
  String? answer;
  final DateTime createdAt;

  IslamicQuestion({
    required this.id,
    required this.question,
    this.answer,
    required this.createdAt,
  });

  bool get isAnswered => answer != null && answer!.trim().isNotEmpty;
}

class IslamicQaService extends ChangeNotifier {
  final List<IslamicQuestion> _questions = [];

  List<IslamicQuestion> get questions =>
      List.unmodifiable(_questions.reversed);

  void addQuestion(String text) {
    final q = IslamicQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      question: text.trim(),
      createdAt: DateTime.now(),
    );
    _questions.add(q);
    notifyListeners();
  }

  void answerQuestion(String id, String answerText) {
    final idx = _questions.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    _questions[idx].answer = answerText.trim();
    notifyListeners();
  }
}