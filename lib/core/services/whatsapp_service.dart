import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleaned?text=$encoded');

    if (!await canLaunchUrl(url)) return false;
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

