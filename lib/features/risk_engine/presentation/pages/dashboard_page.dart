import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_shield/features/risk_engine/domain/risk_engine.dart';
import 'package:digital_shield/features/risk_engine/presentation/pages/settings_page.dart';
import 'package:digital_shield/core/util/permission_service.dart';
import 'package:digital_shield/features/emergency_blocker/presentation/pages/alert_overlay.dart';
import 'package:digital_shield/features/speech_detection/domain/speech_scanner.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:android_intent_plus/android_intent.dart';

final riskProvider = StateProvider<RiskScore>((ref) => RiskScore(
      score: 0,
      level: "Low",
      triggers: [],
    ));

final isMonitoringProvider = StateProvider<bool>((ref) => false);
final isSpeechTestActiveProvider = StateProvider<bool>((ref) => false);
final recognizedTextProvider = StateProvider<String>((ref) => "No speech detected yet...");

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final SpeechScanner _scanner = SpeechScanner();

  @override
  void initState() {
    super.initState();
    _requestInitialPermissions();
  }

  Future<void> _requestInitialPermissions() async {
    await PermissionService.requestAllPermissions();
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = ref.watch(riskProvider);
    final isMonitoring = ref.watch(isMonitoringProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildRiskMeter(risk),
                    const SizedBox(height: 40),
                    _buildStatusCard(isMonitoring),
                    const SizedBox(height: 24),
                    _buildTriggerList(risk.triggers),
                    const SizedBox(height: 20),
                    _buildSpeakerPrompt(),
                    const SizedBox(height: 40),
                    _buildDrillButton(ref),
                    const SizedBox(height: 12),
                    _buildReportButton(context),
                    const SizedBox(height: 12),
                    _buildSpeechTestButton(ref),
                    const SizedBox(height: 16),
                    _buildActionButtons(ref, context),
                  ],
                ),
              ),
            ),
          ),
          if (risk.level == "Critical")
            AlertOverlay(riskScore: risk.score),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KAWACH",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              "SECURE GUARD",
              style: TextStyle(
                color: Colors.blueGrey[400],
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskMeter(RiskScore risk) {
    Color meterColor = _getRiskColor(risk.level);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              value: risk.score / 100,
              strokeWidth: 12,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(meterColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${risk.score.toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                risk.level.toUpperCase(),
                style: TextStyle(
                  color: meterColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isMonitoring) {
    final isSpeechTesting = ref.watch(isSpeechTestActiveProvider);
    final recognizedText = ref.watch(recognizedTextProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: (isMonitoring || isSpeechTesting) ? Colors.greenAccent : Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: (isMonitoring || isSpeechTesting)
                      ? [
                          BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.5),
                              blurRadius: 8)
                        ]
                      : [],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                isSpeechTesting 
                    ? "Speech Test Active" 
                    : isMonitoring ? "Monitoring Active" : "Kawach Paused",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const Spacer(),
              Icon(
                isMonitoring ? Icons.shield_outlined : Icons.shield_moon_outlined,
                color: Colors.blueGrey[400],
              ),
            ],
          ),
        ),
        if (isSpeechTesting) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recognized Speech:", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Text(recognizedText, style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
        if (isMonitoring && !isSpeechTesting) ...[
          const SizedBox(height: 12),
          Text(
            "For protection, enable speaker mode.",
            style: TextStyle(color: Colors.blueAccent[100], fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  Widget _buildSpeakerPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up_rounded, color: Colors.amberAccent, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "App listens to ambient audio. For best results during calls, use Speaker Mode.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerList(List<String> triggers) {
    if (triggers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Active Indicators",
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...triggers.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(t, style: const TextStyle(color: Colors.white60)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final intent = AndroidIntent(
            action: 'android.intent.action.DIAL',
            data: 'tel:1930',
          );
          await intent.launch();
        },
        icon: const Icon(Icons.phone_in_talk, color: Colors.white),
        label: const Text("REPORT SCAM (CALL 1930)"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDrillButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(riskProvider.notifier).state = RiskScore(
            score: 85.0,
            level: "Critical",
            triggers: ["SIMULATED: Scam phrases detected", "SIMULATED: High vocal stress"],
          );
        },
        icon: const Icon(Icons.security_update_warning_rounded, color: Colors.orangeAccent),
        label: const Text("RUN SECURITY DRILL", style: TextStyle(color: Colors.orangeAccent, letterSpacing: 1.1)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.orangeAccent),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSpeechTestButton(WidgetRef ref) {
    final isTesting = ref.watch(isSpeechTestActiveProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (!isTesting) {
            bool initialized = await _scanner.initialize();
            if (initialized) {
              ref.read(isSpeechTestActiveProvider.notifier).state = true;
              ref.read(recognizedTextProvider.notifier).state = "Listening...";
              _scanner.startListening((text, score) {
                ref.read(recognizedTextProvider.notifier).state = text;
                if (score > 0) {
                   ref.read(riskProvider.notifier).state = RiskScore(
                    score: score,
                    level: score > 70 ? "Critical" : score > 30 ? "Medium" : "Low",
                    triggers: ["Keyword match detected in test"],
                  );
                }
              });
            } else {
              ref.read(recognizedTextProvider.notifier).state = "Failed to initialize mic";
            }
          } else {
            _scanner.stopListening();
            ref.read(isSpeechTestActiveProvider.notifier).state = false;
          }
        },
        icon: Icon(isTesting ? Icons.mic_off : Icons.mic, color: Colors.white),
        label: Text(isTesting ? "STOP SPEECH TEST" : "START SPEECH TEST"),
        style: ElevatedButton.styleFrom(
          backgroundColor: isTesting ? Colors.redAccent[700] : Colors.blueGrey[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, BuildContext context) {
    final risk = ref.watch(riskProvider);
    return Row(
      children: [
        if (risk.score > 0) ...[
          IconButton(
            onPressed: () {
              ref.read(riskProvider.notifier).state = RiskScore(
                score: 0,
                level: "Low",
                triggers: [],
              );
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Toggle monitoring
              ref.read(isMonitoringProvider.notifier).state =
                  !ref.read(isMonitoringProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("TOGGLE KAWACH"),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          icon: const Icon(Icons.settings, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white10,
            padding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case "Critical":
        return Colors.redAccent;
      case "High":
        return Colors.orangeAccent;
      case "Medium":
        return Colors.yellowAccent;
      default:
        return Colors.greenAccent;
    }
  }
}
