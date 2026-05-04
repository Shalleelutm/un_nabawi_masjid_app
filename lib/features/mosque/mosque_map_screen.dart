import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueMapScreen extends StatefulWidget {
  const MosqueMapScreen({super.key});

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> {
  List<Map<String, dynamic>> _mosques = [];
  bool _loading = true;
  Position? _currentPosition;

  final List<Map<String, dynamic>> _mauritiusMosques = [
    {'name': 'Masjid Al-Aqsa', 'latitude': -20.1649, 'longitude': 57.5055, 'address': 'Curepipe, Mauritius', 'phone': '+230 676 1234'},
    {'name': 'Jummah Mosque', 'latitude': -20.1642, 'longitude': 57.5025, 'address': 'Port Louis, Mauritius', 'phone': '+230 212 1234'},
    {'name': 'Masjid Al-Falah', 'latitude': -20.2184, 'longitude': 57.4946, 'address': 'Quatre Bornes, Mauritius', 'phone': '+230 427 1234'},
    {'name': 'Masjid An-Noor', 'latitude': -20.2747, 'longitude': 57.4845, 'address': 'Curepipe, Mauritius', 'phone': '+230 676 5678'},
    {'name': 'Masjid Bilal', 'latitude': -20.3277, 'longitude': 57.4964, 'address': 'Phoenix, Mauritius', 'phone': '+230 697 1234'},
    {'name': 'Masjid Al-Madina', 'latitude': -20.2195, 'longitude': 57.5205, 'address': 'Beau Bassin, Mauritius', 'phone': '+230 464 1234'},
    {'name': 'Masjid Taqwa', 'latitude': -20.2999, 'longitude': 57.4785, 'address': 'Vacoas, Mauritius', 'phone': '+230 698 5678'},
    {'name': 'Masjid Umar', 'latitude': -20.1884, 'longitude': 57.5125, 'address': 'Rose Hill, Mauritius', 'phone': '+230 465 1234'},
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _loading = false;
        _mosques = _mauritiusMosques;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _loading = false;
          _mosques = _mauritiusMosques;
        });
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _mosques = _mauritiusMosques;
      _loading = false;
    });
  }

  Future<void> _openMap(double lat, double lng, String name) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double lat1Rad = lat1 * (pi / 180);
    double lat2Rad = lat2 * (pi / 180);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Mosques'),
        backgroundColor: Colors.green.shade700,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Unable to get your location'),
                      Text('Please enable location services'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _mosques.length,
                  itemBuilder: (context, index) {
                    final mosque = _mosques[index];
                    final distance = _calculateDistance(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      mosque['latitude'],
                      mosque['longitude'],
                    );
                    
                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          mosque['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mosque['address']),
                            const SizedBox(height: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.directions),
                          onPressed: () => _openMap(
                            mosque['latitude'],
                            mosque['longitude'],
                            mosque['name'],
                          ),
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}