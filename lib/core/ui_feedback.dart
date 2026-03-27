import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class UIFeedback {
  static void successSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void errorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ $message'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showConfetti(BuildContext context) {
    final controller = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: controller,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.15,
                  numberOfParticles: 20,
                  gravity: 0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);
    controller.play();

    Future.delayed(const Duration(milliseconds: 1200), () async {
      entry.remove();
      await Future.delayed(const Duration(milliseconds: 120));
      controller.dispose();
    });
  }
}