import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/announcement_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementItem> _items = [];
  StreamSubscription<List<AnnouncementItem>>? _sub;
  bool _loading = true;
  bool _started = false;

  List<AnnouncementItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  void start() {
    if (_started) return;
    _started = true;
    
    _sub?.cancel();
    _loading = true;
    notifyListeners();

    _sub = AnnouncementService.streamAnnouncements().listen((data) {
      _items = data;
      _loading = false;
      notifyListeners();
    }, onError: (error) {
      _loading = false;
      _items = [];
      notifyListeners();
    });
  }

  void refresh() {
    _sub?.cancel();
    _started = false;
    start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}