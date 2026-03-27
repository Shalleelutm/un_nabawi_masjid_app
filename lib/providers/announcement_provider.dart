import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/announcement_service.dart';

class AnnouncementItem {
  final String id;
  final String title;
  final String message;
  final bool isImportant;
  final DateTime createdAt;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isImportant,
    required this.createdAt,
  });
}

class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementItem> _items = [];
  StreamSubscription<List<AnnouncementItem>>? _sub;
  bool _loading = true;

  List<AnnouncementItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  void start() {
    _sub?.cancel();
    _loading = true;
    notifyListeners();

    _sub = AnnouncementService.streamAnnouncements().listen((data) {
      _items = data;
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}