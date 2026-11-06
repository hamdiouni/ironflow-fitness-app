# Release Engineering, Signing & Store Readiness Guide

## 1. Version Scheme (`MAJOR.MINOR.PATCH+BUILD_NUMBER`)
IronFlow uses standard Flutter semantic versioning in `pubspec.yaml`:
- **`MAJOR`**: Breaking schema/API changes or major product milestones.
- **`MINOR`**: Backward-compatible feature waves (e.g., `1.1.0` -> `1.2.0` for Body Map).
- **`PATCH`**: Bug fixes, security patches, and hotfixes.
- **`+BUILD_NUMBER`**: Strictly monotonically increasing integer (`+2`, `+3`, ...) required by Google Play (`versionCode`) and Apple App Store Connect (`CFBundleVersion`).

Override at build time in CI without hand-editing `pubspec.yaml`:
```bash
flutter build appbundle --release \
  --build-name=1.1.0 \
  --build-number=2 \
  --dart-define-from-file=config/production.json \
  --dart-define=GIT_COMMIT=$(git rev-parse HEAD) \
  --dart-define=BUILD_DATE=$(date -u +%Y-%m-%d)
```

---

## 2. Flavors (`dev`, `staging`, `production`)
Each environment has an isolated JSON configuration file in `config/`:

| Flavor | Config File | App Name | Application ID | Firebase Project | Direct AI Keys | App Check Enforce |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`dev`** | `config/dev.json` | `IronFlow Dev` | `com.progressiontracker.progression_tracker.dev` | `ironflow-dev` | Debug-only | `false` |
| **`staging`** | `config/staging.json` | `IronFlow Staging` | `com.progressiontracker.progression_tracker.staging` | `ironflow-staging` | `false` | `false` (monitor) |
| **`production`** | `config/production.json` | `IronFlow` | `com.progressiontracker.progression_tracker` | `gym-app-fe50c` | `false` | `true` |

> **Security Rule**: Never place secret API keys (`GEMINI_API_KEY`, `OPENAI_API_KEY`, `NVIDIA_API_KEY`) into `config/*.json`. Production and staging AI traffic routes exclusively through the authenticated Firebase Cloud Functions proxy (`AI_PROXY_URL`).

---

## 3. Build Stamp (`BuildStamp`)
`lib/core/config/build_stamp.dart` embeds four compile-time fields into every binary:
- `APP_VERSION` (defaults to `1.1.0+2`)
- `FLAVOR` (`dev`, `staging`, `production`)
- `GIT_COMMIT` (7-char short SHA displayed in UI, full SHA in diagnostics)
- `BUILD_DATE` (ISO-8601 UTC date)

Example output:
```text
v1.1.0+2 (production • ca4d06a • 2026-11-06)
```

---

## 4. Android Release Signing (Never Commit Keys)
1. **Generate an Upload Keystore** (outside the repository, e.g., in `~/.ironflow-keys/`):
   ```bash
   keytool -genkey -v -keystore ~/ironflow-upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```
2. **Create `android/key.properties`** (already gitignored in `.gitignore`):
   ```properties
   storePassword=<YOUR_KEYSTORE_PASSWORD>
   keyPassword=<YOUR_KEY_PASSWORD>
   keyAlias=upload
   storeFile=/absolute/path/to/ironflow-upload-keystore.jks
   ```
3. **Verify Gradle Signing Configuration**:
   - `android/app/build.gradle.kts` automatically loads `android/key.properties` when present and signs the `release` build type with the upload key.
   - Register the upload key SHA-1 and SHA-256 fingerprints in Firebase Console (`Project Settings -> Your Apps -> Android`) for Google Sign-In and Firebase App Check Play Integrity.

---

## 5. Web Deployment Checklist
1. Build release bundle with production configuration:
   ```bash
   flutter build web --release \
     --dart-define-from-file=config/production.json \
     --dart-define=GIT_COMMIT=$(git rev-parse HEAD) \
     --dart-define=BUILD_DATE=$(date -u +%Y-%m-%d)
   ```
2. Verify zero non-Firebase secret keys in `build/web/`:
   ```bash
   ! grep -RInE "nvapi-[A-Za-z0-9_-]{20,}" build/web/
   ```
3. Configure HTTP security headers on the hosting provider (`Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`).

---

## 6. Store Submission Checklists

### Google Play Store Checklist
- [ ] Upload signed `.aab` (`build/app/outputs/bundle/release/app-release.aab`) built with `config/production.json`.
- [ ] Play App Signing enabled and upload certificate SHA-256 registered in Firebase App Check (Play Integrity).
- [ ] Data Safety form matches actual collection:
  - Analytics & Crashlytics: **Optional** (off by default until opt-in via `TelemetryConsentScreen`).
  - Account & Data Deletion: **Supported in-app** (`Settings -> Privacy -> Delete Account`) and documented for web deletion requests.
  - Encryption: Data encrypted in transit (TLS) and at rest locally (`HiveAesCipher` 256-bit AES).
- [ ] Target SDK meets Google Play requirement (`flutter.targetSdkVersion`).

### Apple App Store Connect Checklist (CI / macOS Handoff)
- [ ] `ios/Runner/PrivacyInfo.xcprivacy` included in Runner bundle (`NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes` for `UserDefaults` `CA92.1` and file timestamps `C617.1`).
- [ ] `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, and `NSPhotoLibraryAddUsageDescription` present in `ios/Runner/Info.plist`.
- [ ] In-app Account Deletion (`Settings -> Privacy -> Delete Account`) verified for Guideline 5.1.1(v).
- [ ] Sign in with Apple configured where third-party social login (`GoogleSignIn`) is offered (Guideline 4.8).

