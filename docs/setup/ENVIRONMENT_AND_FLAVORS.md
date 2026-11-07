# IronFlow — Environment Setup & Flavor Configuration

**Version:** 2.0.0  
**Target Audience:** Flutter Developers, CI/CD Engineers

---

## 1. Developer Day-1 Setup

### System Prerequisites
1. Install Flutter 3.24+ and Dart 3.5+.
2. Verify toolchain setup:
   ```bash
   flutter doctor
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Verify tests and static analysis:
   ```bash
   flutter analyze lib/
   flutter test --no-pub
   ```

---

## 2. Environment Variables & App Configuration

IronFlow uses compile-time `--dart-define` arguments rather than brittle local `.env` files. This ensures that sensitive values cannot be accidentally leaked into source repositories.

### Core Configuration Flags

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `AI_PROXY_URL` | Empty string | The HTTPS URL of your deployed Firebase Cloud Functions proxy (`functions/aiGenerate`). |
| `DIRECT_AI_KEYS_OPT_IN` | `false` | Debug-only developer flag allowing direct Gemini API keys for rapid local iteration. **Hard-disabled in release builds**. |
| `APP_CHECK_STAGE` | `monitor` | Controls App Check enforcement mode (`off`, `monitor`, `enforce`). |
| `USE_FIREBASE_AUTH` | `true` | When true, routes authentication through Firebase Auth. (In debug tests, test doubles can be injected via Riverpod overrides). |

---

## 3. Launching the App Locally

### Local Debug Development (Connecting to Deployed Proxy)
```bash
flutter run -d chrome --dart-define=AI_PROXY_URL="https://<region>-<project-id>.cloudfunctions.net/aiGenerate"
```

### Local Debug with Firebase Emulators
If developing offline with local Firebase emulators:
```bash
firebase emulators:start
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true
```

---

## 4. Release Build Commands

### Android Release App Bundle (Google Play)
```bash
flutter build appbundle --release \
  --dart-define=AI_PROXY_URL="https://<region>-<project-id>.cloudfunctions.net/aiGenerate" \
  --dart-define=APP_CHECK_STAGE="enforce"
```

### Web Release (Firebase Hosting)
```bash
flutter build web --release \
  --dart-define=AI_PROXY_URL="https://<region>-<project-id>.cloudfunctions.net/aiGenerate" \
  --dart-define=APP_CHECK_STAGE="enforce"
```

---

## 5. Security Notice for Developers

> [!CAUTION]
> Never put hardcoded API keys or service account credentials into `.env`, Dart files, or Git commits.
> Production release builds reject direct API keys by design (`StateError` fail-closed). All AI communication must route through the authenticated Cloud Functions proxy.

