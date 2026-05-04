import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  double? _heading;
  double? _qiblaDirection;
  bool _hasLocation = false;
  String _status = 'Waiting for compass...';
  Stream<CompassEvent>? _compassStream;

  static const double kaabaLat = 21.4225;
  static const double kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _initCompass();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _status = 'Please enable location services');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _status = 'Location permission denied');
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    _qiblaDirection = _calculateQibla(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        _hasLocation = true;
        _status = 'Point the arrow towards Makkah';
      });
    }
  }

  double _calculateQibla(double lat, double lon) {
    final phiK = kaabaLat * pi / 180;
    final lambdaK = kaabaLon * pi / 180;
    final phi = lat * pi / 180;
    final lambda = lon * pi / 180;
    final y = sin(lambdaK - lambda);
    final x = cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda);
    final theta = atan2(y, x);
    return (theta * 180 / pi + 360) % 360;
  }

  void _initCompass() {
    _compassStream = FlutterCompass.events;
    _compassStream?.listen((event) {
      if (mounted) {
        setState(() => _heading = event.heading);
      }
    });
  }

  @override
  void dispose() {
    _compassStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle = _heading != null && _qiblaDirection != null
        ? ((_qiblaDirection! - _heading!) * pi / 180) * -1
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: angle,
                  child: const Icon(Icons.navigation, size: 150, color: Colors.green),
                ),
              ),
              const SizedBox(height: 40),
              if (_qiblaDirection != null)
                Text('${_qiblaDirection!.toInt()}°', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(_status, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (!_hasLocation)
                ElevatedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Enable Location'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Text('🕋 Tips for Accuracy', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Move your phone in a figure-8 motion to calibrate\nKeep away from magnetic objects\nHold the phone flat and level', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}