import 'dart:ui';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:digital_shield/features/speech_detection/domain/speech_scanner.dart';
import 'package:digital_shield/features/risk_engine/domain/risk_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: (service) {},
      onBackground: (service) => false,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Initialize utilities
  final scanner = SpeechScanner();
  final riskEngine = RiskEngine();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Handle data updates from native side
  service.on('onDataReceived').listen((data) {
    if (data != null && data.containsKey('action')) {
      final action = data['action'];
      if (action == 'CALL_STARTED') {
        service.invoke('CALL_STARTED');
      } else if (action == 'CALL_ENDED') {
        service.invoke('CALL_ENDED');
      } else if (action == 'CALL_RINGING') {
        service.invoke('CALL_RINGING');
      }
    }
  });

  service.on('CALL_RINGING').listen((event) async {
    // Show Overlay for incoming call
    if (!await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Kawach Incoming Call",
        overlayContent: "Monitoring before answering...",
        flag: OverlayFlag.defaultFlag,
        width: WindowSize.matchParent,
        height: WindowSize.matchParent,
      );
    }
  });

  // Listen for call events from native side (mocked via service event for now)
  // In a real implementation, you'd use a platform channel or a broadcast receiver plugin
  service.on('CALL_STARTED').listen((event) async {
    // Show Overlay
    if (!await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Kawach Monitoring",
        overlayContent: "Ongoing call protection active",
        flag: OverlayFlag.defaultFlag,
        width: WindowSize.matchParent,
        height: WindowSize.matchParent, // Full screen for the overlay container, widget handles center
      );
    }

    await scanner.initialize();
    scanner.startListening((text, score) async {
      final currentRisk = riskEngine.calculateRisk(
        keywordMatchScore: score,
        emotionStressScore: 10.0, // Mock
        callDurationSeconds: 0, // Should be tracked
      );

      // Save to shared preferences for native access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('risk_score', currentRisk.score);
      await prefs.setString('risk_level', currentRisk.level);

      service.invoke('updateRisk', {
        'score': currentRisk.score,
        'level': currentRisk.level,
        'triggers': currentRisk.triggers,
      });

      // Update Overlay if active
      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.shareData({
          'score': currentRisk.score,
          'level': currentRisk.level,
        });
      }
    });
  });

  service.on('CALL_ENDED').listen((event) async {
    scanner.stopListening();
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Here we would call the native telephony APIs to check call state
        // For now, it's a heartbeat
        service.setForegroundNotificationInfo(
          title: "Kawach Active",
          content: "Monitoring for suspicious call activity...",
        );
      }
    }
    
    // logic to trigger speech detection if in call
  });
}
