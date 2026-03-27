import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value;

  const AnimatedProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 300),
      builder: (_, val, __) {
        return LinearProgressIndicator(
          value: val,
          color: Colors.green,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
        );
      },
    );
  }
}