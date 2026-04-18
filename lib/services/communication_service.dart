import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  
  // 1. Email Functionality
  static Future<void> sendEmail(String reportData) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bscs22090@itu.edu.pk',
      queryParameters: {
        'subject': 'SME Daily Cash Flow Report',
        'body': reportData,
      },
    );
    // mode: LaunchMode.externalApplication taakay browser ki jagah app khulay
    await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
  }

  // 2. WhatsApp Functionality
  static Future<void> sendWhatsApp(String message) async {
    // Phone number 92 ke sath set kar diya hai (0331... ko 92331... kar diya)
    String phone = "923316635794";
    final String url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 3. SMS Functionality
  static Future<void> sendSMS(String message) async {
    // Default SMS app kholnay ke liye
    String phone = "03316635794";
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}