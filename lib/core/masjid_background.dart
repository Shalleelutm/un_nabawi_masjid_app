import 'package:flutter/material.dart';

class MasjidBackground extends StatelessWidget {
  final Widget child;

  const MasjidBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.12),
            cs.secondary.withValues(alpha: 0.08),
            cs.surface.withValues(alpha: 0.98),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}