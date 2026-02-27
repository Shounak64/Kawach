# DigitalShield - Anti-Scam Protection

DigitalShield is a production-ready Flutter app designed to protect users from "Digital Arrest" scams in India using real-time call monitoring, on-device speech-to-text, AI-powered pattern matching, and Accessibility-based UPI protection.

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- An Android device (API 29+)

### 2. Configuration
- Get a Gemini API Key from [Google AI Studio](https://aistudio.google.com/).
- Use `GeminiScanner(apiKey: 'YOUR_KEY')` in your initialization logic.
- Ensure `android/app/src/main/res/xml/accessibility_service_config.xml` is present.

### 3. Permissions
On first launch, the app will request:
- Microphone (for speech analysis)
- Phone (for call state monitoring)
- Camera (for emotion/anxiety detection)
- System Overlay (for risk meter and alerts)
- **Accessibility Service**: Must be manually enabled in Android Settings > Accessibility > DigitalShield.

### 4. Running
```bash
flutter pub get
flutter run
```

## Architecture
This project follows **Clean Architecture**:
- `core/`: Utilities, services, and shared constants.
- `features/`: Modular components (Call Monitor, Speech Detection, Emotion Engine, Risk Engine, Emergency Blocker).
- `lib/main.dart`: App entry and service initialization.

## Safety & Privacy
- **Processing is On-Device**: Raw audio never leaves the phone.
- **Gemini Usage**: Gemini is used only for high-level pattern refinement of detected text snippets, not for raw audio processing.

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
<img width="714" height="1599" alt="image_2026-02-28_022710786" src="https://github.com/user-attachments/assets/55bf814a-414e-45a0-a97c-434d1c6373c6" />
<img width="714" height="1599" alt="image_2026-02-28_022655678" src="https://github.com/user-attachments/assets/62e33bb5-ca62-4ddc-b2aa-9383ed8e4e3e" />
<img width="714" height="1599" alt="image_2026-02-28_022641782" src="https://github.com/user-attachments/assets/ef89cb10-ceec-4498-88bc-499e7af9875b" />
