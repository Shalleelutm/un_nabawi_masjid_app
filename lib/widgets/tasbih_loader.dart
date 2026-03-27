import 'dart:math';
import 'package:flutter/material.dart';

class TasbihLoader extends StatefulWidget {
  const TasbihLoader({super.key});

  @override
  State<TasbihLoader> createState() => _TasbihLoaderState();
}

class _TasbihLoaderState extends State<TasbihLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double angle = controller.value * 2 * pi;

        return Transform.rotate(
          angle: angle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              12,
              (int i) => Container(
                margin: const EdgeInsets.all(4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}