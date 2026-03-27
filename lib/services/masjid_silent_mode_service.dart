import 'package:flutter/services.dart';

class MasjidSilentModeService {
  static const MethodChannel _channel = MethodChannel('masjid_silent_mode');

  static Future<void> enableSilentMode() async {
    try {
      await _channel.invokeMethod('enableSilent');
    } catch (e) {
      print(e);
    }
  }

  static Future<void> disableSilentMode() async {
    try {
      await _channel.invokeMethod('disableSilent');
    } catch (e) {
      print(e);
    }
  }
}