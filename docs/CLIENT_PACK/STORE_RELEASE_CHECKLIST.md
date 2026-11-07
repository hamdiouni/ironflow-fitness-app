# IronFlow — App Store & Play Store Release Checklist

**Version:** 2.0.0  
**Target Stores:** Google Play Store (Android), Web PWA (Firebase Hosting), Apple App Store (iOS compile-ready)

---

## 1. Google Play Store Release Checklist (Android)

### A. Technical & Build Requirements
- [x] **Target SDK 34 (Android 14)**: Set in `android/app/build.gradle.kts`.
- [x] **Predictive Back Gestures**: Enabled with `android:enableOnBackInvokedCallback="true"` in `AndroidManifest.xml`.
- [x] **R8 Code Minification & Resource Shrinking**: Enabled in `android/app/build.gradle.kts` with audited `android/app/proguard-rules.pro`.
- [x] **Edge-to-Edge System Bars**: Configured in `lib/main.dart` with transparent system bars.
- [x] **Clean Permissions**: Only `INTERNET`, `ACCESS_NETWORK_STATE`, and optional `POST_NOTIFICATIONS` requested. Zero dangerous SMS, Contacts, or background location permissions.
- [x] **Release Build**: Built with `flutter build appbundle --release`.

### B. Google Play Console Data Safety Form
Refer to [`docs/platform/STORE_DATA_SAFETY_MAPPING.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/platform/STORE_DATA_SAFETY_MAPPING.md) for exact questionnaire answers:
- [x] **Data Collection**: Disclose Fitness Data (Workouts, Body measurements), Account Info (Email, User ID), and Optional Analytics/Crash logs.
- [x] **Encryption**: Declare all user data is encrypted in transit (TLS 1.3) and encrypted at rest (AES-256).
- [x] **Deletion Mechanism**: Declare that users can request account and data deletion directly within the app (`Settings > Delete Account`).
- [x] **Children Policy**: Declare app is not targeted at children under 13.

### C. Store Listing Graphics & Copy
- [ ] **App Icon**: `512x512` 32-bit PNG with alpha channel (`assets/icons/icon_512.png`).
- [ ] **Feature Graphic**: `1024x500` PNG/JPEG.
- [ ] **Screenshots**: Minimum 4 high-resolution screenshots (`390x844` or `1080x2400`) showcasing:
  1. Home Today View & Readiness Banner
  2. 2D Vector Body Map & Muscle Recovery Diagnostics
  3. Active Workout Tracker with Plate Calculator & Rest Timer
  4. AI Coaching Chat & Macro Analytics
- [ ] **Privacy Policy URL**: Hosted link to `docs/legal/PRIVACY_POLICY.md` on your production domain.

---

## 2. Apple App Store Release Checklist (iOS)

*(Note: iOS builds compile cleanly in CI with `--no-codesign` per Owner target specifications).*

### A. Privacy Manifest & Info.plist
- [x] **Apple Privacy Manifest (`PrivacyInfo.xcprivacy`)**: Configured with User Defaults reason `CA92.1` and zero tracking domains (`NSPrivacyTracking = false`).
- [x] **Usage Descriptions**: Configured in `ios/Runner/Info.plist`:
  - `NSCameraUsageDescription`: "IronFlow uses your camera to capture workout progress photos."
  - `NSPhotoLibraryUsageDescription`: "IronFlow accesses your photo library to import profile and progress pictures."

### B. App Store Review Guidelines
- [x] **Medical Disclaimer**: Displayed in AI Coach and Body Map views per Guideline 1.4.1 (Medical Apps).
- [x] **Account Deletion**: Guideline 5.1.1(v) satisfied with one-tap recursive account deletion in Settings.
- [x] **Zero Third-Party Advertising**: No ad SDKs or tracking frameworks embedded.

---

## 3. Web PWA Release Checklist

- [x] **PWA Manifest (`web/manifest.json`)**: Configured with `name: "IronFlow"`, `display: "standalone"`, `theme_color: "#0B0F19"`.
- [x] **Security Headers (`firebase.json`)**:
  - `Cross-Origin-Opener-Policy: same-origin-allow-popups`
  - `Cross-Origin-Embedder-Policy: require-corp`
  - `Cross-Origin-Resource-Policy: cross-origin`
- [x] **Static Asset Caching**: 1-year immutable caching for static font and data assets; `no-cache` for `index.html`.
- [x] **Bundle Budget**: `main.dart.js` gzipped size verified at **1.60 MB** ($\le 2.5$ MB budget).

---

## 4. Release Commands Quick Reference

```bash
# 1. Clean build directory
flutter clean
flutter pub get

# 2. Run static analysis & test suite
flutter analyze lib/
flutter test --no-pub

# 3. Verify size budgets
python scripts/check_perf_budgets.py

# 4. Build Android App Bundle (AAB)
flutter build appbundle --release --dart-define=AI_PROXY_URL="https://<YOUR_FUNCTIONS_URL>/aiGenerate"

# 5. Build Web Application
flutter build web --release --dart-define=AI_PROXY_URL="https://<YOUR_FUNCTIONS_URL>/aiGenerate"
```

