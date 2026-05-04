import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class IbadahTrackerScreen extends StatefulWidget {
  const IbadahTrackerScreen({super.key});

  @override
  State<IbadahTrackerScreen> createState() => _IbadahTrackerScreenState();
}

class _IbadahTrackerScreenState extends State<IbadahTrackerScreen> {
  // Prayer tracking
  Map<String, bool> _prayers = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };
  
  // Other Ibadah
  int _quranPages = 0;
  int _fastingDays = 0;
  int _charity = 0;
  int _dhikr = 0;
  int _streak = 0;
  int _totalPoints = 0;
  
  final List<Map<String, dynamic>> _badges = [
    {'name': 'Prayer Warrior', 'icon': Icons.mosque, 'color': Colors.green, 'unlocked': false},
    {'name': 'Quran Reader', 'icon': Icons.menu_book, 'color': Colors.blue, 'unlocked': false},
    {'name': 'Fasting Hero', 'icon': Icons.nights_stay, 'color': Colors.purple, 'unlocked': false},
    {'name': 'Charity Giver', 'icon': Icons.favorite, 'color': Colors.red, 'unlocked': false},
    {'name': 'Streak Master', 'icon': Icons.local_fire_department, 'color': Colors.orange, 'unlocked': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    setState(() {
      for (var prayer in _prayers.keys) {
        _prayers[prayer] = prefs.getBool('${today}_$prayer') ?? false;
      }
      _quranPages = prefs.getInt('quran_pages') ?? 0;
      _fastingDays = prefs.getInt('fasting_days') ?? 0;
      _charity = prefs.getInt('charity') ?? 0;
      _dhikr = prefs.getInt('dhikr') ?? 0;
      _streak = prefs.getInt('streak') ?? 0;
      _totalPoints = prefs.getInt('total_points') ?? 0;
    });
    
    _updateBadges();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    for (var prayer in _prayers.keys) {
      await prefs.setBool('${today}_$prayer', _prayers[prayer]!);
    }
    await prefs.setInt('quran_pages', _quranPages);
    await prefs.setInt('fasting_days', _fastingDays);
    await prefs.setInt('charity', _charity);
    await prefs.setInt('dhikr', _dhikr);
    await prefs.setInt('streak', _streak);
    await prefs.setInt('total_points', _totalPoints);
  }

  void _togglePrayer(String prayer) {
    setState(() {
      _prayers[prayer] = !_prayers[prayer]!;
      if (_prayers[prayer]!) {
        _totalPoints += 10;
        _updateStreak();
      }
    });
    _saveData();
  }

  void _updateStreak() {
    final allCompleted = _prayers.values.every((v) => v == true);
    if (allCompleted) {
      setState(() {
        _streak++;
        _totalPoints += 50;
      });
      _showSnackbar('🎉 $_streak day streak! MashaAllah!');
    }
    _saveData();
  }

  void _addQuranPage() {
    setState(() {
      _quranPages++;
      _totalPoints += 5;
    });
    _saveData();
    _updateBadges();
  }

  void _addFast() {
    setState(() {
      _fastingDays++;
      _totalPoints += 20;
    });
    _saveData();
    _updateBadges();
  }

  void _addCharity() {
    setState(() {
      _charity += 100;
      _totalPoints += 10;
    });
    _saveData();
    _updateBadges();
  }

  void _addDhikr() {
    setState(() {
      _dhikr++;
      _totalPoints += 2;
    });
    _saveData();
  }

  void _updateBadges() {
    setState(() {
      _badges[0]['unlocked'] = _totalPoints >= 50;  // Prayer Warrior
      _badges[1]['unlocked'] = _quranPages >= 10;    // Quran Reader
      _badges[2]['unlocked'] = _fastingDays >= 5;    // Fasting Hero
      _badges[3]['unlocked'] = _charity >= 500;      // Charity Giver
      _badges[4]['unlocked'] = _streak >= 7;         // Streak Master
    });
    _saveData();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  int get _completedPrayers => _prayers.values.where((v) => v == true).length;
  double get _progress => _completedPrayers / _prayers.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ibadah Journey'),
        backgroundColor: Colors.green.shade700,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '$_totalPoints',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Daily Prayer Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.teal.shade600],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Today\'s Prayers',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    color: Colors.amber,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_completedPrayers / ${_prayers.length} Completed',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _prayers.keys.map((prayer) {
                      return FilterChip(
                        label: Text(prayer),
                        selected: _prayers[prayer]!,
                        onSelected: (_) => _togglePrayer(prayer),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        selectedColor: Colors.amber,
                        labelStyle: TextStyle(
                          color: _prayers[prayer]! ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Streak Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '$_streak days',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (_streak >= 7)
                    const Icon(Icons.verified, color: Colors.amber, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Good Deeds Grid
            const Text(
              'Track Your Good Deeds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _DeedCard(
                  title: 'Quran Pages',
                  value: _quranPages,
                  icon: Icons.menu_book,
                  color: Colors.blue,
                  onTap: _addQuranPage,
                ),
                _DeedCard(
                  title: 'Fasting Days',
                  value: _fastingDays,
                  icon: Icons.nights_stay,
                  color: Colors.purple,
                  onTap: _addFast,
                ),
                _DeedCard(
                  title: 'Charity (Rs)',
                  value: _charity,
                  icon: Icons.favorite,
                  color: Colors.red,
                  onTap: _addCharity,
                ),
                _DeedCard(
                  title: 'Dhikr Count',
                  value: _dhikr,
                  icon: Icons.sentiment_satisfied,
                  color: Colors.teal,
                  onTap: _addDhikr,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Badges Section
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _badges.map((badge) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: badge['unlocked'] 
                          ? badge['color'].withValues(alpha: 0.2) 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: badge['unlocked'] ? badge['color'] : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          badge['icon'],
                          size: 40,
                          color: badge['unlocked'] ? badge['color'] : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badge['unlocked'] ? badge['color'] : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DeedCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DeedCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}