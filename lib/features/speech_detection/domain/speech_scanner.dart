import 'package:speech_to_text/speech_to_text.dart';

class SpeechScanner {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  final List<String> scamKeywords = [
    "police",
    "cbi",
    "fbi",
    "customs",
    "narcotics",
    "crime branch",
    "enforcement directorate",
    "inspector",
    "commissioner",
    "warrant",
    "arrest",
    "digital arrest",
    "fir",
    "jail",
    "thana",
    "kanooni",
    "drugs",
    "mdma",
    "illegal",
    "parcel",
    "package",
    "passport",
    "aadhar card",
    "sim card",
    "pornography",
    "money laundering",
    "terror funding",
    "smuggling",
    "kaala dhan",
    "otp",
    "pin",
    "cvv",
    "password",
    "bank account",
    "upi",
    "transfer",
    "verify",
    "link",
    "anydesk",
    "teamviewer",
    "screen share",
    "security deposit",
    "bail",
    "fine",
    "penalty",
    "refund",
    "khata",
    "rishwat",
    "immediate",
    "emergency",
    "quickly",
    "confidential",
    "secret",
    "stay on call",
    "don't hang up",
    "don’t hang up",
    "silent",
    "don't tell family",
    "don’t tell family",
    "last warning",
    "deadline",
    "galti",
    "legal",
    "court",
    "notice",
    "investigation",
    "compliance",
    "suspended",
    "expired",
    "warning",
    "lottery",
    "prize",
    "crypto",
    "investment",
    "section 144",
    "kyc suspension",
    "suspicious transaction",
    "reserve bank",
  ];

  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  void startListening(Function(String, double) onResult) async {
    if (!_isListening) {
      await _speech.listen(
        onResult: (result) {
          String text = result.recognizedWords.toLowerCase();
          double matchScore = _calculateMatchScore(text);
          onResult(text, matchScore);
        },
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 10),
        listenOptions: SpeechListenOptions(partialResults: true),
      );
      _isListening = true;
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }

  double _calculateMatchScore(String text) {
    int matches = 0;
    for (var keyword in scamKeywords) {
      if (text.contains(keyword)) {
        matches++;
      }
    }
    // Simple heuristic: 1 match = 30%, 2 = 70%, 3+ = 100%
    if (matches == 0) return 0;
    if (matches == 1) return 30;
    if (matches == 2) return 70;
    return 100;
  }
}
