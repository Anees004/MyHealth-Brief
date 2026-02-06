# MyHealth Brief

An AI-powered health report assistant built with Flutter. MyHealth Brief helps patients understand their medical reports using Gemini's multimodal capabilities.

## Features

- **Scan or Upload Reports**: Capture medical reports using your camera or upload PDF files
- **AI-Powered Analysis**: Gemini analyzes your reports and provides easy-to-understand summaries
- **Detailed Findings**: View your test results with visual indicators (Low/Normal/Borderline/High)
- **Doctor Questions**: AI-generated questions to discuss with your healthcare provider
- **Simple & Clinical Views**: Toggle between patient-friendly and detailed clinical views
- **Timeline**: Track your health reports over time
- **Secure Cloud Sync**: Your data synced securely with Firebase

## Architecture

The app follows **Clean Architecture with MVVM + BLoC** pattern:

```
lib/
├── core/
│   ├── constants/      # App constants and strings
│   ├── di/             # Dependency injection (get_it)
│   ├── errors/         # Failures and exceptions
│   ├── router/         # Navigation (go_router)
│   ├── theme/          # App theme, colors, text styles
│   └── utils/          # Extensions, validators, usecase base
├── features/
│   ├── auth/           # Authentication feature
│   ├── health_brief/   # Main feature - document analysis
│   ├── home/           # Home screen and shell
│   ├── profile/        # User profile and settings
│   └── timeline/       # Health briefs timeline
└── shared/
    └── widgets/        # Reusable widgets
```

## Setup Instructions

### Prerequisites

- Flutter SDK >= 3.9.0
- Dart SDK >= 3.9.0
- Firebase project
- Gemini API key

### 1. Clone and Install Dependencies

```bash
cd myhealth_brief
flutter pub get
```

### 2. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add iOS and Android apps to your Firebase project
3. Download configuration files:
   - **iOS**: `GoogleService-Info.plist` → place in `ios/Runner/`
   - **Android**: `google-services.json` → place in `android/app/`
4. Enable the following Firebase services:
   - **Authentication**: Enable Email/Password and Google sign-in
   - **Firestore Database**: Create database in production mode  
   (Health reports are stored **locally on device** only—no Firebase Storage needed.)

### 3. Configure Gemini API

1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Open `lib/main.dart` and replace:
   ```dart
   await initializeDependencies(geminiApiKey: 'YOUR_GEMINI_API_KEY');
   ```

### 4. iOS Setup

Add camera and photo library permissions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your medical reports</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload your medical reports</string>
```

### 5. Android Setup

Add camera permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### 6. Run the App

```bash
flutter run
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `firebase_*` | Backend services |
| `google_generative_ai` | Gemini AI integration |
| `image_picker` | Camera capture |
| `file_picker` | PDF upload |
| `go_router` | Navigation |
| `dartz` | Functional programming |

## Disclaimer

This app is designed to help patients understand their health reports. It is **not intended to diagnose, treat, or replace professional medical advice**. Always consult a qualified healthcare provider for medical decisions.

## License

MIT License
