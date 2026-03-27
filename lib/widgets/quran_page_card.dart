import 'package:flutter/material.dart';

class QuranPageCard extends StatefulWidget {
  final String surahName;
  final String arabicText;
  final String translation;
  final int ayahNumber;

  const QuranPageCard({
    super.key,
    required this.surahName,
    required this.arabicText,
    required this.translation,
    required this.ayahNumber,
  });

  @override
  State<QuranPageCard> createState() => _QuranPageCardState();
}

class _QuranPageCardState extends State<QuranPageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _highlight;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _highlight = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _highlight,
      builder: (BuildContext context, Widget? child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE7C55B).withValues(alpha: 0.35),
            ),
            gradient: LinearGradient(
              colors: <Color>[
                const Color(0xFFE7C55B).withValues(alpha: 0.05),
                cs.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _highlight.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7C55B).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${widget.surahName} • Ayah ${widget.ayahNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.arabicText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.translation,
                    style: TextStyle(
                      fontSize: 15,
                      color: cs.onSurface.withValues(alpha: 0.82),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}