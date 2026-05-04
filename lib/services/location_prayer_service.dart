import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPrayerService {
  static Future<Map<String, dynamic>> fetch() async {
    final pos = await Geolocator.getCurrentPosition();

    final url =
        'http://api.aladhan.com/v1/timings?latitude=${pos.latitude}&longitude=${pos.longitude}&method=2';

    final res = await http.get(Uri.parse(url));

    return json.decode(res.body);
  }
}