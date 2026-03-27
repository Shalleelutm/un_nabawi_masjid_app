import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSpiritualScreen extends StatefulWidget {
  const HomeSpiritualScreen({super.key});

  @override
  State<HomeSpiritualScreen> createState() => _HomeSpiritualScreenState();
}

class _HomeSpiritualScreenState extends State<HomeSpiritualScreen>
    with SingleTickerProviderStateMixin {
  static const _kKey = 'official_prayer_times_v1';

  Map<String, TimeOfDay> _times = {};
  Timer? _timer;
  String _nextPrayer = '';
  Duration _remaining = Duration.zero;

  late final AnimationController _fade =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
        ..forward();

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateNext());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);

    // ✅ Robust parse:
    // Accepts JSON like: {"Fajr":"05:00","Dhuhr":"12:15"...}
    Map<String, TimeOfDay> parsed = {};

    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          final v = entry.value?.toString() ?? '';
          final parts = v.split(':');
          if (parts.length == 2) {
            final h = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            if (h != null && m != null) {
              parsed[entry.key] = TimeOfDay(hour: h, minute: m);
            }
          }
        }
      } catch (_) {}
    }

    // fallback default if none loaded
    parsed = parsed.isNotEmpty
        ? parsed
        : {
            'Fajr': const TimeOfDay(hour: 5, minute: 0),
            'Dhuhr': const TimeOfDay(hour: 12, minute: 15),
            'Asr': const TimeOfDay(hour: 15, minute: 30),
            'Maghrib': const TimeOfDay(hour: 18, minute: 5),
            'Isha': const TimeOfDay(hour: 19, minute: 25),
          };

    if (!mounted) return;
    setState(() => _times = parsed);
    _calculateNext();
  }

  void _calculateNext() {
    if (_times.isEmpty) return;

    final now = DateTime.now();
    DateTime? nextTime;
    String? nextName;

    // Ensure stable order
    final orderedKeys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final entries = <MapEntry<String, TimeOfDay>>[];

    for (final k in orderedKeys) {
      if (_times.containsKey(k)) entries.add(MapEntry(k, _times[k]!));
    }
    // add any extra keys at end
    for (final e in _times.entries) {
      if (!orderedKeys.contains(e.key)) entries.add(e);
    }

    for (final e in entries) {
      final dt = DateTime(now.year, now.month, now.day, e.value.hour, e.value.minute);
      if (dt.isAfter(now)) {
        nextTime = dt;
        nextName = e.key;
        break;
      }
    }

    if (nextTime == null) {
      final first = entries.first;
      nextTime = DateTime(now.year, now.month, now.day + 1, first.value.hour, first.value.minute);
      nextName = first.key;
    }

    if (!mounted) return;
    setState(() {
      _nextPrayer = nextName ?? '';
      _remaining = nextTime!.difference(now);
    });
  }

  String _format(Duration d) {
    final s = d.inSeconds.clamp(0, 999999);
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }

  String _timeFmt(TimeOfDay t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Spiritual Home')),
      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // WOW HEADER
            Card(
              color: cs.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(Icons.mosque_rounded, color: cs.onPrimaryContainer, size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stay connected to Salah.\nPrivate tools • Offline-first.',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // NEXT PRAYER CARD
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Prayer',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, color: cs.primary, size: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _nextPrayer.isEmpty ? 'Loading…' : _nextPrayer,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _format(_remaining),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ NEW BUTTON CARDS (as you requested)
            Card(
              child: ListTile(
                leading: Icon(Icons.menu_book_rounded, color: cs.primary),
                title: const Text('Quran Reader', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Read Arabic + English meaning • bookmarks • progress'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pushNamed(context, '/quran'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.volunteer_activism_rounded, color: cs.tertiary),
                title: const Text('Spiritual Rewards', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Private streak • sincere habit tool • no leaderboard'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pushNamed(context, '/spiritualReward'),
              ),
            ),

            const SizedBox(height: 12),

            // PRAYER TIMES LIST
            Text(
              'Today’s Times',
              style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            ..._times.entries.map((e) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.access_time_rounded, color: cs.primary.withValues(alpha: 0.85)),
                  title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w900)),
                  trailing: Text(
                    _timeFmt(e.value),
                    style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface.withValues(alpha: 0.85)),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'May Allah accept your prayers 🤍',
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface.withValues(alpha: 0.85)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}