import 'package:flutter/material.dart';
import '../services/whatsapp_service.dart';

class WhatsAppFab extends StatelessWidget {
  final String phoneE164;
  final String message;

  /// Keep it out of the way
  final EdgeInsets margin;

  const WhatsAppFab({
    super.key,
    required this.phoneE164,
    required this.message,
    this.margin = const EdgeInsets.only(right: 14, bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Positioned(
      right: margin.right,
      bottom: margin.bottom,
      child: Tooltip(
        message: 'WhatsApp Admin',
        child: FloatingActionButton(
          heroTag: 'whatsapp_fab',
          onPressed: () async {
            await WhatsAppService.openChat(
              phoneE164: phoneE164,
              message: message,
            );
          },
          backgroundColor: const Color(0xFF25D366), // WhatsApp green
          foregroundColor: Colors.white,
          elevation: 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.chat_rounded),
              Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.star_rounded,
                    size: 10, color: cs.surface.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}