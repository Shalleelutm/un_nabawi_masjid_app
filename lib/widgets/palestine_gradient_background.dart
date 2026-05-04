import 'package:flutter/material.dart';

class PalestineGradientBackground extends StatelessWidget {
  final Widget child;

  const PalestineGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF7F2EA),
            Color(0xFFEFF7F2),
            Color(0xFFFBEFF1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -40,
            child: _circle(180, const Color(0xFF007A3D)),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _circle(170, const Color(0xFFCE1126)),
          ),
          Positioned(
            top: 150,
            left: -50,
            child: _circle(140, Colors.black),
          ),
          child,
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}