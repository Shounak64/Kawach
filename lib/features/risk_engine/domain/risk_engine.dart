class RiskScore {
  final double score;
  final String level; // Low, Medium, High, Critical
  final List<String> triggers;

  RiskScore({
    required this.score,
    required this.level,
    required this.triggers,
  });
}

class RiskEngine {
  static const double keywordWeight = 0.5;
  static const double emotionWeight = 0.3;
  static const double durationWeight = 0.2;

  RiskScore calculateRisk({
    required double keywordMatchScore, // 0 to 100
    required double emotionStressScore, // 0 to 100
    required int callDurationSeconds,
  }) {
    // Duration risk: increases over time, caps at some point (e.g., 10 mins = 100)
    double durationScore = (callDurationSeconds / 600.0) * 100.0;
    if (durationScore > 100) durationScore = 100;

    double finalScore = (keywordMatchScore * keywordWeight) +
        (emotionStressScore * emotionWeight) +
        (durationScore * durationWeight);

    String level = "Low";
    if (finalScore > 80) {
      level = "Critical";
    } else if (finalScore > 60) {
      level = "High";
    } else if (finalScore > 30) {
      level = "Medium";
    }

    List<String> triggers = [];
    if (keywordMatchScore > 50) triggers.add("Scam phrases detected");
    if (emotionStressScore > 70) triggers.add("High vocal stress/anxiety");
    if (callDurationSeconds > 300) triggers.add("Prolonged suspicious call");

    return RiskScore(
      score: finalScore,
      level: level,
      triggers: triggers,
    );
  }
}
