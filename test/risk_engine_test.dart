







import 'package:flutter_test/flutter_test.dart';
import 'package:digital_shield/features/risk_engine/domain/risk_engine.dart';

void main() {
  group('RiskEngine tests', () {
    final engine = RiskEngine();

    test('Low risk calculation', () {
      final risk = engine.calculateRisk(
        keywordMatchScore: 0,
        emotionStressScore: 10,
        callDurationSeconds: 60,
      );
      expect(risk.level, equals('Low'));
      expect(risk.score, lessThan(20));
    });

    test('Critical risk calculation with keyword match', () {
      final risk = engine.calculateRisk(
        keywordMatchScore: 100, // 50 points
        emotionStressScore: 90,  // 27 points
        callDurationSeconds: 300, // 10 points
      );
      // Total: 50 + 27 + 10 = 87
      expect(risk.level, equals('Critical'));
      expect(risk.score, closeTo(87, 0.1));
      expect(risk.triggers, contains('Scam phrases detected'));
    });

    test('High risk calculation with duration', () {
      final risk = engine.calculateRisk(
        keywordMatchScore: 20,
        emotionStressScore: 20,
        callDurationSeconds: 600, // 20 points
      );
      // Total: 10 + 6 + 20 = 36
      expect(risk.level, equals('Medium'));
    });
  });
}
