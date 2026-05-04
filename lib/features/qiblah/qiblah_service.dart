import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class QiblahService {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  static Future<double> getDirection() async {
    try {
      final pos = await Geolocator.getCurrentPosition();

      final lat1 = pos.latitude * pi / 180;
      final lon1 = pos.longitude * pi / 180;
      final lat2 = kaabaLat * pi / 180;
      final lon2 = kaabaLng * pi / 180;

      final dLon = lon2 - lon1;
      final y = sin(dLon) * cos(lat2);
      final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
      final bearing = atan2(y, x);

      return (bearing * 180 / pi + 360) % 360;
    } catch (e) {
      debugPrint('Error calculating Qibla direction: $e');
      return 294; // Default Mauritius direction
    }
  }
}