import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:digital_shield/core/util/ai_service.dart';

class GeminiScanner implements AIScanner {
  final GenerativeModel model;

  GeminiScanner({required String apiKey})
      : model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  @override
  Future<bool> analyzeConversationSnippet(String text) async {
    final prompt = '''
    Analyze the following snippet from a phone call conversation in India. 
    Determine if it contains patterns typical of "Digital Arrest" scams (threatening legal action, pretending to be CBI/Police, asking for money transfers for verification).
    
    Snippet: "$text"
    
    Respond with ONLY "TRUE" if it's a scam or "FALSE" if it's not.
    ''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text?.trim().toUpperCase() == "TRUE";
  }

  @override
  Future<List<String>> getUpdatedScamKeywords() async {
    final prompt = "List 10 common phrases used in Indian digital arrest scams. Respond with a comma-separated list.";
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text?.split(',').map((e) => e.trim()).toList() ?? [];
  }
}
