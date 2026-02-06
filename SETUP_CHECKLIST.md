# MyHealth Brief – Setup Checklist

You only need to configure things in the **Firebase Console** and **one API key** in code. No extra “keys” to copy for Auth—everything is already in your `GoogleService-Info.plist` and `google-services.json`.

---

## ✅ 1. Firebase Authentication (you did this)

- **Where:** [Firebase Console](https://console.firebase.google.com) → your project → **Authentication** → **Sign-in method**
- **Enable:** Email/Password and **Google**
- **Google:** Add a support email and save. No extra keys needed; the app uses the OAuth client from your config files.

**iOS:** Your `Info.plist` already has the URL scheme and `GIDClientID` from `GoogleService-Info.plist`. No further Auth config needed on iOS.

---

## ✅ 2. Firestore Database (needed for app data)

The app stores **user profiles** and **health briefs** in Firestore.

- **Where:** Firebase Console → **Firestore Database**
- **Do:** Click **Create database** → choose **Start in production mode** (we’ll add rules next) → pick a region.
- **Rules:** In **Rules**, replace with something like this so only signed-in users can read/write their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /health_briefs/{briefId} {
      allow read, write: if request.auth != null
        && resource == null ? request.auth.uid == request.resource.data.userId
        : resource.data.userId == request.auth.uid;
    }
  }
}
```

Publish the rules.

---

## ✅ 3. Health reports: local only (no Firebase Storage)

**Health report files (PDFs and images) are stored only on your device**, not in the cloud. This keeps personal health data private and avoids compliance issues (e.g. HIPAA, GDPR) from uploading reports online.

- You **do not** need to enable or configure Firebase Storage.
- Optional backup (e.g. “Back up to cloud”) can be added later if users want it.

---

## ✅ 4. Gemini API key (needed for AI summaries)

This is **not** in Firebase. It’s a separate key for the Gemini API.

- **Where:** [Google AI Studio](https://aistudio.google.com/app/apikey) (or [makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey))
- **Do:** Create an API key (use the same Google account as Firebase if you want).
- **In the app:** Open `lib/main.dart` and replace the placeholder:

```dart
await initializeDependencies(geminiApiKey: 'YOUR_GEMINI_API_KEY');
```

with your real key, e.g.:

```dart
await initializeDependencies(geminiApiKey: 'AIza...your-key...');
```

**Security:** For production, don’t commit the key. Use environment variables or a secrets manager and pass the key into `initializeDependencies` at runtime.

---

## Summary

| What              | Where to configure        | Extra keys? |
|------------------|---------------------------|-------------|
| Auth (Email + Google) | Firebase Console → Authentication | No – config is in plist/json |
| Firestore        | Firebase Console → Firestore + Rules | No |
| Reports          | Stored locally on device only; no Firebase Storage | — |
| Gemini AI        | Google AI Studio → API key → `lib/main.dart` | Yes – one Gemini API key |

After Auth, Firestore, and the Gemini key are set, the app has everything it needs. Reports stay on the device.
