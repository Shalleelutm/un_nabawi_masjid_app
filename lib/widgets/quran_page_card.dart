import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';

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

  bool bookmarked = false;

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

  void toggleBookmark() {
    BookmarkService.add(widget.arabicText);

    setState(() {
      bookmarked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayah bookmarked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _highlight,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE7C55B).withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.surahName} • Ayah ${widget.ayahNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.orange,
                    ),
                    onPressed: toggleBookmark,
                  )
                ],
              ),

              const SizedBox(height: 12),

              // 🔥 ARABIC TEXT (WOW STYLE FIXED)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.arabicText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1.8,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // TRANSLATION
              Text(
                widget.translation,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}