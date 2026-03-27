import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/prayer_time_service.dart';
import '../../widgets/flip_card_3d.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/palestine_gradient_background.dart';
import '../../widgets/wow_text.dart';

class NextSalahScreen extends StatefulWidget {
  const NextSalahScreen({super.key});

  @override
  State<NextSalahScreen> createState() => _NextSalahScreenState();
}

class _NextSalahScreenState extends State<NextSalahScreen> {
  Timer? _timer;
  bool _loading = true;
  PrayerDay? _today;
  String _nextPrayerName = '--';
  DateTime? _nextPrayerDateTime;
  Duration _remaining = Duration.zero;

  static const List<String> _orderedPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _refreshCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerData() async {
    await PrayerTimeService.instance.loadFromAssets();
    _refreshCountdown();

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  void _refreshCountdown() {
    final now = DateTime.now();
    final today = PrayerTimeService.instance.today(now: now);
    final tomorrow = PrayerTimeService.instance.tomorrow(now: now);

    final prayerName =
        PrayerTimeService.instance.nextPrayerName(now: now) ?? '--';
    final prayerDateTime =
        PrayerTimeService.instance.nextPrayerDateTime(now: now);

    if (today == null && tomorrow == null) {
      if (!mounted) return;
      setState(() {
        _today = null;
        _nextPrayerName = '--';
        _nextPrayerDateTime = null;
        _remaining = Duration.zero;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _today = today;
      _nextPrayerName = prayerName;
      _nextPrayerDateTime = prayerDateTime;
      _remaining = prayerDateTime == null
          ? Duration.zero
          : prayerDateTime.difference(now);
    });
  }

  Map<String, String> _todayPrayerTimes() {
    if (_today == null) return {};
    return {
      'Fajr': _today!.fajrIqama.isNotEmpty ? _today!.fajrIqama : _today!.fajrAdhan,
      'Dhuhr': _today!.zohrIqama.isNotEmpty ? _today!.zohrIqama : _today!.zohrAdhan,
      'Asr': _today!.asrIqama.isNotEmpty ? _today!.asrIqama : _today!.asrAdhan,
      'Maghrib': _today!.maghribIqama.isNotEmpty ? _today!.maghribIqama : _today!.maghribAdhan,
      'Isha': _today!.eshaIqama.isNotEmpty ? _today!.eshaIqama : _today!.eshaAdhan,
    };
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatDuration(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    return '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
  }

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '--';
    return '${_two(dt.hour)}:${_two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final prayers = _todayPrayerTimes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Salah'),
      ),
      body: PalestineGradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  children: [
                    const WowText('Prayer Countdown', size: 30),
                    const SizedBox(height: 16),
                    FlipCard3D(
                      front: _CountdownCard(
                        prayerName: _nextPrayerName,
                        remaining: _formatDuration(_remaining),
                        timeLabel: _timeLabel(_nextPrayerDateTime),
                      ),
                      back: _PrayerListCard(
                        prayers: prayers,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today at a glance',
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._orderedPrayers.map((name) {
                            final value = prayers[name] ?? '--';
                            final isNext = name == _nextPrayerName;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: isNext
                                    ? cs.primary.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.55),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    color: isNext ? cs.primary : cs.onSurface,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: isNext ? cs.primary : cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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

class _CountdownCard extends StatelessWidget {
  final String prayerName;
  final String remaining;
  final String timeLabel;

  const _CountdownCard({
    required this.prayerName,
    required this.remaining,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.96),
            const Color(0xFFEFF7F2),
            const Color(0xFFFBEFF1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WowText('Next Prayer', size: 28),
            const SizedBox(height: 12),
            Text(
              prayerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scheduled at $timeLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: const Color(0xFF111111),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Countdown',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        remaining,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerListCard extends StatelessWidget {
  final Map<String, String> prayers;

  const _PrayerListCard({
    required this.prayers,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.96),
              const Color(0xFFF7F2EA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WowText('Today Prayer Times', size: 26),
              const SizedBox(height: 18),
              ...ordered.map((name) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        prayers[name] ?? '--',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Spacer(),
              Text(
                'Tap card to flip',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}