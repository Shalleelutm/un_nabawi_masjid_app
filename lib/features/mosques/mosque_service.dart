import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MosqueService {
  static Future<List<dynamic>> fetchNearby(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=[out:json];node["amenity"="place_of_worship"](around:5000,$lat,$lon);out;'
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['elements'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching mosques: $e');
      return [];
    }
  }
}