import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:convert';

class CallOverlay extends StatefulWidget {
  const CallOverlay({super.key});

  @override
  State<CallOverlay> createState() => _CallOverlayState();
}

class _CallOverlayState extends State<CallOverlay> {
  double _riskScore = 0;
  String _riskLevel = "Low";

  @override
  void initState() {
    super.initState();
    // Listen for risk updates from the background service
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data != null) {
        try {
          final Map<String, dynamic> riskData = Map<String, dynamic>.from(data);
          setState(() {
            _riskScore = (riskData['score'] as num).toDouble();
            _riskLevel = riskData['level'] as String;
          });
        } catch (e) {
          debugPrint("Error parsing overlay data: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color riskColor = _getRiskColor(_riskLevel);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: riskColor.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                   Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: riskColor.withValues(alpha: 0.5), width: 1),
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kawach Active",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          _riskScore > 0 ? "Potential threat detected!" : "Monitoring for threats...",
                          style: TextStyle(color: _riskScore > 0 ? riskColor : Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_riskScore > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_riskScore.toInt()}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (_riskScore < 50)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.volume_up_rounded, color: Colors.amberAccent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Enable Speaker Mode for full protection",
                          style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final intent = AndroidIntent(
                          action: 'android.intent.action.MAIN',
                          package: 'com.example.digital_shield',
                          componentName: 'com.example.digital_shield.MainActivity',
                          flags: [268435456], // FLAG_ACTIVITY_NEW_TASK
                        );
                        await intent.launch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("OPEN DASHBOARD"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        return Colors.blueAccent;
    }
  }
}
