import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_shield/features/risk_engine/presentation/pages/dashboard_page.dart';
import 'package:digital_shield/features/risk_engine/domain/risk_engine.dart';

class AlertOverlay extends ConsumerWidget {
  final double riskScore;

  const AlertOverlay({super.key, required this.riskScore});

  void triggerAlert() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000, amplitude: 255);
    }
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/alert.mp3'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.red.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 100),
            const SizedBox(height: 24),
            const Text(
              "POSSIBLE SCAM DETECTED",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Risk Score: ${riskScore.toInt()}%",
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Logic to disconnect call
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text("DISCONNECT IMMEDIATELY"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(riskProvider.notifier).state = RiskScore(
                  score: 0,
                  level: "Low",
                  triggers: [],
                );
              },
              child: const Text(
                "DISMISS (TEST ONLY)",
                style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "UPI Apps are temporarily locked for your safety.",
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
