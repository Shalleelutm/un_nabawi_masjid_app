import 'package:flutter/material.dart';
import '../models/khutbah_model.dart';

class KhutbahProvider extends ChangeNotifier {
  final List<Khutbah> _khutbahs = [
    Khutbah(
      id: '1',
      title: 'Importance of Salah',
      date: 'Friday 12 Feb 2026',
      content:
          'Salah is the pillar of Islam. It strengthens our connection with Allah...',
      audioAsset: null,
    ),
  ];

  List<Khutbah> get khutbahs => _khutbahs;

  void addKhutbah(Khutbah k) {
    _khutbahs.insert(0, k);
    notifyListeners();
  }
}
