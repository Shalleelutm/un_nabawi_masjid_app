import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTrackerScreen extends StatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  State<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> {
  final List<String> _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, bool> _status = {};
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    setState(() {
      for (var prayer in _prayers) {
        _status[prayer] = prefs.getBool('${today}_$prayer') ?? false;
      }
      _streak = prefs.getInt('prayer_streak') ?? 0;
    });
  }

  Future<void> _togglePrayer(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    setState(() {
      _status[prayer] = !(_status[prayer] ?? false);
    });
    
    await prefs.setBool('${today}_$prayer', _status[prayer] ?? false);
    
    // Update streak if all prayers completed
    final allCompleted = _prayers.every((p) => _status[p] == true);
    if (allCompleted) {
      final newStreak = _streak + 1;
      await prefs.setInt('prayer_streak', newStreak);
      setState(() {
        _streak = newStreak;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 $_streak day streak! MashaAllah!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  int _getCompletedCount() {
    return _prayers.where((p) => _status[p] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _getCompletedCount();
    final progress = completed / _prayers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Tracker'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.teal.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  color: Colors.amber,
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed / ${_prayers.length} Prayers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Streak:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_streak days',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _prayers.length,
              itemBuilder: (context, index) {
                final prayer = _prayers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      prayer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    secondary: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPrayerIcon(prayer),
                        color: Colors.green.shade700,
                      ),
                    ),
                    value: _status[prayer] ?? false,
                    onChanged: (value) => _togglePrayer(prayer),
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.sunny;
      case 'Maghrib':
        return Icons.nightlight_round;
      case 'Isha':
        return Icons.nights_stay;
      default:
        return Icons.mosque;
    }
  }
}