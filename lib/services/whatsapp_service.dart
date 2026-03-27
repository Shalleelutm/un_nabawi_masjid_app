import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  /// Opens WhatsApp chat using wa.me.
  /// Provide phone in E.164 format WITHOUT spaces, example: +23057478727
  static Future<bool> openChat({
    required String phoneE164,
    String? message,
  }) async {
    final clean = phoneE164.replaceAll(' ', '');
    final text = Uri.encodeComponent(message ?? '');
    final uri = Uri.parse('https://wa.me/$clean?text=$text');

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}