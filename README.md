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
3. Get your config files (they are **not** in the repo for security):
   - Run **`flutterfire configure`** in the project root (recommended), or
   - Download from Firebase Console: **iOS** `GoogleService-Info.plist` → `ios/Runner/`; **Android** `google-services.json` → `android/app/`
4. Enable the following Firebase services:
   - **Authentication**: Enable Email/Password and Google sign-in
   - **Firestore Database**: Create database in production mode  
   (Health reports are stored **locally on device** only—no Firebase Storage needed.)

### 3. Configure Gemini API

1. Get your API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Pass it at run time (do **not** commit the key):
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```
   Or set it in your IDE run configuration (e.g. VS Code/Cursor: add `--dart-define=GEMINI_API_KEY=your_key_here` to the run args).

### 4. iOS Setup

Camera and photo library permissions are in `ios/Runner/Info.plist` (camera, photo library read/add). No extra steps if you used the project as-is.

### 5. Android Setup

Camera and storage permissions are in `android/app/src/main/AndroidManifest.xml` (camera, read/write external storage, read media images/video). No extra steps if you used the project as-is.

### 6. Run the App

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
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

## Security (public repos)

Do **not** commit Firebase config files or API keys. See [SECURITY.md](SECURITY.md) for what to keep local and what to do if you already pushed secrets.

## License

MIT License
