import 'package:flutter/material.dart';

class MemberSyncProvider extends ChangeNotifier {
  bool _syncing = false;
  bool get syncing => _syncing;

  Future<void> syncMembersToCloud() async {
    _syncing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _syncing = false;
    notifyListeners();
  }
}