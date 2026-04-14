import 'dart:math';
import 'package:flutter/material.dart';

class KaabaLoader extends StatefulWidget {
  final double size;
  final String message;

  const KaabaLoader({
    super.key,
    this.size = 100,
    this.message = '',
  });

  @override
  State<KaabaLoader> createState() => _KaabaLoaderState();
}

class _KaabaLoaderState extends State<KaabaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edge = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(_controller.value * 2 * pi),
              child: Container(
                width: edge,
                height: edge,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(edge * 0.12),
                  border: Border.all(
                    color: Colors.amber,
                    width: edge * 0.04,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.45),
                      blurRadius: edge * 0.22,
                      spreadRadius: edge * 0.03,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: edge * 0.08,
                      left: edge * 0.08,
                      right: edge * 0.08,
                      child: Container(
                        height: edge * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(edge * 0.03),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: edge * 0.26,
                        height: edge * 0.26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.message.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}