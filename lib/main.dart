import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_shield/features/risk_engine/presentation/pages/dashboard_page.dart';
import 'package:digital_shield/core/util/background_service_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digital_shield/core/presentation/pages/splash_page.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:digital_shield/features/emergency_blocker/presentation/pages/call_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service
  await initializeBackgroundService();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CallOverlay(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kawach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
