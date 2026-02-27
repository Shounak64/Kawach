abstract class AIScanner {
  Future<bool> analyzeConversationSnippet(String text);
  Future<List<String>> getUpdatedScamKeywords();
}

class AIService {
  final AIScanner scanner;

  AIService(this.scanner);

  Future<bool> isScam(String text) async {
    return await scanner.analyzeConversationSnippet(text);
  }
}
