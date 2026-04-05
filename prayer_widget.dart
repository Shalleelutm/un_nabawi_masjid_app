import 'package:flutter/material.dart';

class PrayerTimesWidget extends StatelessWidget {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  
  const PrayerTimesWidget({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(title: Text('Fajr'), trailing: Text(fajr)),
          ListTile(title: Text('Dhuhr'), trailing: Text(dhuhr)),
          ListTile(title: Text('Asr'), trailing: Text(asr)),
          ListTile(title: Text('Maghrib'), trailing: Text(maghrib)),
          ListTile(title: Text('Isha'), trailing: Text(isha)),
        ],
      ),
    );
  }
}