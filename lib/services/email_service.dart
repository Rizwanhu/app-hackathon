import 'package:url_launcher/url_launcher.dart';

class EmailService {

  static Future<void> sendFinancialReport(String reportData) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bscs22090@itu.edu.pk', // Yahan user ki email aye gi
      queryParameters: {
        'subject': 'SME Daily Cash Flow Report',
        'body': reportData,
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}