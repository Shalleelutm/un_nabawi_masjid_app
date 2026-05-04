import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyMosqueScreen extends StatefulWidget {
  const NearbyMosqueScreen({super.key});

  @override
  State<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

class _NearbyMosqueScreenState extends State<NearbyMosqueScreen> {
  bool _loading = true;
  Position? _position;

  final List<Map<String, dynamic>> _mauritiusMosques = [
    {'name': 'Masjid Al-Aqsa', 'lat': -20.1649, 'lng': 57.5055, 'address': 'Curepipe', 'phone': '+230 676 1234'},
    {'name': 'Jummah Mosque', 'lat': -20.1642, 'lng': 57.5025, 'address': 'Port Louis', 'phone': '+230 212 1234'},
    {'name': 'Masjid Al-Falah', 'lat': -20.2184, 'lng': 57.4946, 'address': 'Quatre Bornes', 'phone': '+230 427 1234'},
    {'name': 'Masjid An-Noor', 'lat': -20.2747, 'lng': 57.4845, 'address': 'Curepipe', 'phone': '+230 676 5678'},
    {'name': 'Masjid Bilal', 'lat': -20.3277, 'lng': 57.4964, 'address': 'Phoenix', 'phone': '+230 697 1234'},
    {'name': 'Masjid Al-Madina', 'lat': -20.2195, 'lng': 57.5205, 'address': 'Beau Bassin', 'phone': '+230 464 1234'},
    {'name': 'Masjid Taqwa', 'lat': -20.2999, 'lng': 57.4785, 'address': 'Vacoas', 'phone': '+230 698 5678'},
    {'name': 'Masjid Umar', 'lat': -20.1884, 'lng': 57.5125, 'address': 'Rose Hill', 'phone': '+230 465 1234'},
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loading = false);
        return;
      }
    }
    _position = await Geolocator.getCurrentPosition();
    setState(() => _loading = false);
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  Future<void> _openMap(double lat, double lng, String name) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<Map<String, dynamic>> sortedMosques = List.from(_mauritiusMosques);
    if (_position != null) {
      sortedMosques.sort((a, b) {
        double distA = _calculateDistance(_position!.latitude, _position!.longitude, a['lat'], a['lng']);
        double distB = _calculateDistance(_position!.latitude, _position!.longitude, b['lat'], b['lng']);
        return distA.compareTo(distB);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Mosques in Mauritius'), backgroundColor: Colors.green.shade700),
      body: ListView.builder(
        itemCount: sortedMosques.length,
        itemBuilder: (context, index) {
          final m = sortedMosques[index];
          double distance = _position != null ? _calculateDistance(_position!.latitude, _position!.longitude, m['lat'], m['lng']) : 0;
          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.mosque, color: Colors.green, size: 30)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      if (distance > 0) Text('${distance.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(m['address'], style: TextStyle(color: Colors.grey[600]))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openMap(m['lat'], m['lng'], m['name']),
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _makeCall(m['phone']),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}