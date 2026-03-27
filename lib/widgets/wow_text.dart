import 'package:flutter/material.dart';

class WowText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const WowText(
    this.text, {
    super.key,
    this.size = 28,
    this.fontWeight = FontWeight.w900,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF007A3D),
            Color(0xFF000000),
            Color(0xFFCE1126),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: size,
          fontWeight: fontWeight,
          letterSpacing: -0.3,
          color: Colors.white,
          height: 1.08,
        ),
      ),
    );
  }
}