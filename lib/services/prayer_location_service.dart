import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PrayerLocationService {
  static Future<Map<String, dynamic>> fetchTodayTimes() async {
    final pos = await Geolocator.getCurrentPosition();

    final url =
        'https://api.aladhan.com/v1/timings?latitude=${pos.latitude}&longitude=${pos.longitude}&method=2';

    final res = await http.get(Uri.parse(url));

    final data = json.decode(res.body);

    return data['data']['timings'];
  }
}