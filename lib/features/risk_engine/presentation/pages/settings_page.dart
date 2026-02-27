import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final riskSensitivityProvider = StateProvider<double>((ref) => 70.0);
final cameraEmotionEnabledProvider = StateProvider<bool>((ref) => true);
final protectedAppsProvider = StateProvider<List<String>>((ref) => ["Google Pay", "PhonePe", "Paytm"]);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensitivity = ref.watch(riskSensitivityProvider);
    final isCameraEnabled = ref.watch(cameraEmotionEnabledProvider);
    final protectedApps = ref.watch(protectedAppsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader("Security Dashboard"),
          _buildSensitivitySlider(ref, sensitivity),
          const SizedBox(height: 32),
          _buildSectionHeader("Emotion Detection"),
          SwitchListTile(
            title: const Text("Camera Analysis", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Analyze facial cues for anxiety during calls", style: TextStyle(color: Colors.white60)),
            value: isCameraEnabled,
            onChanged: (val) => ref.read(cameraEmotionEnabledProvider.notifier).state = val,
            activeThumbColor: Colors.blueAccent,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("Protected UPI Apps"),
          ...["Google Pay", "PhonePe", "Paytm", "BHIM"].map((app) => CheckboxListTile(
            title: Text(app, style: const TextStyle(color: Colors.white)),
            value: protectedApps.contains(app),
            onChanged: (val) {
              final current = ref.read(protectedAppsProvider);
              if (val == true) {
                ref.read(protectedAppsProvider.notifier).state = [...current, app];
              } else {
                ref.read(protectedAppsProvider.notifier).state = current.where((e) => e != app).toList();
              }
            },
            activeColor: Colors.blueAccent,
            checkColor: Colors.white,
          )),
          const SizedBox(height: 40),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.blueAccent[100],
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSensitivitySlider(WidgetRef ref, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Risk Sensitivity Threshold", style: TextStyle(color: Colors.white, fontSize: 16)),
            Text("${val.toInt()}%", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: 10,
          max: 90,
          divisions: 8,
          onChanged: (newVal) => ref.read(riskSensitivityProvider.notifier).state = newVal,
          activeColor: Colors.blueAccent,
        ),
        const Text(
          "Lower values trigger alerts more frequently.",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Icon(Icons.lock_outline, color: Colors.blueGrey, size: 30),
          SizedBox(height: 12),
          Text(
            "Privacy Shield Active",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "All voice and facial processing happens strictly on-device. No data leaves your phone.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
