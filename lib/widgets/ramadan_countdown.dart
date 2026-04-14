import 'dart:async';
import 'package:flutter/material.dart';

class RamadanCountdown extends StatefulWidget {
  const RamadanCountdown({super.key});

  @override
  State<RamadanCountdown> createState() => _RamadanCountdownState();
}

class _RamadanCountdownState extends State<RamadanCountdown> {
  Timer? _timer;
  String _label = '';

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    final now = DateTime.now();
    final iftar = DateTime(now.year, now.month, now.day, 18, 0);
    final target = now.isBefore(iftar)
        ? iftar
        : DateTime(now.year, now.month, now.day + 1, 18, 0);

    final diff = target.difference(now);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');

    if (!mounted) return;
    setState(() {
      _label = '$h h $m m until iftar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.nights_stay_rounded,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _label.isEmpty ? 'Ramadan countdown' : _label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}