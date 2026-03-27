import 'package:flutter/material.dart';

import '../services/prayer_auto_scheduler_service.dart';
import '../services/prayer_time_service.dart';

class PrayerProvider extends ChangeNotifier {
  List<PrayerDay> _days = [];
  bool _loaded = false;
  bool _bootstrapped = false;

  List<PrayerDay> get days => List.unmodifiable(_days);
  bool get loaded => _loaded;

  Future<void> load({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;

    await PrayerTimeService.instance.loadFromAssets(forceReload: forceReload);
    _days = PrayerTimeService.instance.all;
    _loaded = true;

    if (!_bootstrapped || forceReload) {
      _bootstrapped = true;
      await PrayerAutoSchedulerService.instance.refreshSchedules();
    }

    notifyListeners();
  }

  PrayerDay? forDate(DateTime date) {
    if (!_loaded) return null;
    return PrayerTimeService.instance.forDate(date);
  }

  PrayerDay? get today {
    if (!_loaded || _days.isEmpty) return null;
    return forDate(DateTime.now()) ?? _days.first;
  }

  List<PrayerDay> month(int year, int month) {
    if (!_loaded) return [];
    return PrayerTimeService.instance.forMonth(year, month);
  }

  Future<void> reloadAndResync() async {
    await load(forceReload: true);
  }
}