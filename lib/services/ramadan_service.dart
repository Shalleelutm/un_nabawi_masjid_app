class RamadanService {
  bool isRamadan = false;

  String get iftarTime => '18:45';
  String get suhoorEnds => '04:45';
  String get taraweehTime => '20:00';

  void toggleRamadan(bool value) {
    isRamadan = value;
  }
}
