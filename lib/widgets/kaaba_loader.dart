import 'package:flutter/material.dart';

class KaabaLoader extends StatefulWidget {
  final double size;
  final String? message;

  const KaabaLoader({
    super.key,
    this.size = 80,
    this.message,
  });

  @override
  State<KaabaLoader> createState() => _KaabaLoaderState();
}

class _KaabaLoaderState extends State<KaabaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _controller,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.12),
                  cs.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/Kaaba/kaaba.png',
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.mosque_rounded,
                    size: widget.size * 0.55,
                    color: cs.primary,
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}