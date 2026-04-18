import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Direct import

class GeminiService {
  GeminiService();

  // Pulls directly from the .env file loaded in memory
  bool get isConfigured => (dotenv.env['GEMINI_API_KEY'] ?? '').isNotEmpty;

  Future<String> askText(String prompt) async {
    if (!isConfigured) {
      return 'AI Error: GEMINI_API_KEY not found in .env file.';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // Using Flash for hackathon speed
        apiKey: dotenv.env['GEMINI_API_KEY']!,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 512,
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'AI could not generate a response.';
    } catch (e) {
      return 'AI Service Error: ${e.toString()}';
    }
  }
}