import 'package:google_generative_ai/google_generative_ai.dart';

import '../constants/env.dart';

class GeminiService {
  GeminiService();

  bool get isConfigured => Env.geminiApiKey.trim().isNotEmpty;

  Future<String> askText(String prompt) async {
    if (!isConfigured) {
      return 'Gemini is not configured. Provide GEMINI_API_KEY.';
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Env.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
    );

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}

