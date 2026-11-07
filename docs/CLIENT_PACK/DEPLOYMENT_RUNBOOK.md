# IronFlow — Production Deployment Runbook

**Target Audience:** DevOps Engineers, Cloud Administrators, Technical Project Leads  
**Version:** 2.0.0  
**Estimated Deployment Time:** ~45–60 minutes

---

## 1. Prerequisites & Toolchain Requirements

Ensure the following tools are installed and authenticated on your deployment machine:
- **Flutter SDK**: `3.24.0` or higher (`flutter doctor` must report zero errors)
- **Node.js**: `18.x` or `20.x LTS`
- **Firebase CLI**: `13.x` or higher (`npm install -g firebase-tools`)
- **Java Development Kit (JDK)**: `17` or `21` (required for Android Gradle builds)
- **Google Cloud SDK / gcloud CLI**: Optional, for Cloud Run management

Log in to the client Firebase account:
```bash
firebase login
```

---

## 2. Firebase Cloud Project Provisioning

1. **Create Firebase Project**:
   - Create or select the production project in the [Firebase Console](https://console.firebase.google.com) (e.g. `ironflow-production`).
   - Upgrade the project to the **Blaze (Pay as you go)** plan. *(Required for Firebase Cloud Functions 2nd Gen and external Gemini API egress; Google provides generous monthly free tiers).*
2. **Enable Required Services**:
   - **Authentication**: Enable `Email/Password` and `Google Sign-In`.
   - **Cloud Firestore**: Create database in `Production mode` selecting your preferred region (e.g., `us-central1` or `europe-west1`).
   - **Cloud Storage**: Create bucket in `Production mode`.
   - **Firebase Hosting**: Enable Hosting.
   - **Firebase App Check**: Enable App Check (Play Integrity for Android, reCAPTCHA Enterprise for Web).
3. **Link Local Project**:
   ```bash
   firebase use --add ironflow-production
   ```

---

## 3. Deploying Firebase Cloud Functions AI Proxy (`SEC-01`, `ADR-001`)

The AI proxy (`functions/aiGenerate`) routes user queries securely to the Gemini API, enforcing authentication, App Check tokens, and durable Firestore quotas.

1. **Set Environment Secrets**:
   Provide the production Gemini API key via Firebase Secret Manager:
   ```bash
   firebase functions:secrets:set GEMINI_API_KEY
   # Enter the production Gemini API key securely when prompted
   ```
2. **Install Dependencies & Deploy**:
   ```bash
   cd functions
   npm install
   cd ..
   firebase deploy --only functions:aiGenerate
   ```
3. **Capture Proxy URL**:
   After deployment, note the public HTTPS trigger URL output by the CLI:
   `https://<region>-<project-id>.cloudfunctions.net/aiGenerate`

---

## 4. Deploying Security Rules & Composite Indexes

Deploy the audited Firestore security rules, composite indexes, and Cloud Storage security rules:

```bash
# 1. Deploy Firestore Security Rules & Indexes
firebase deploy --only firestore:rules,firestore:indexes

# 2. Deploy Cloud Storage Security Rules
firebase deploy --only storage:rules
```

### Verification Checks:
- Verify in Firebase Console that `firestore.rules` restricts `users/{uid}` updates so that `request.auth.uid == userId` and protected fields cannot be tampered with.
- Verify in Firebase Console that `storage.rules` allows recursive deletions for account purges while disallowing unauthorized reads.

---

## 5. Firebase App Check Configuration (`SEC-01`, `W1.4`)

App Check prevents unauthorized apps, scraping bots, and modified APKs from calling your backend.

1. **Android (Play Integrity)**:
   - In Firebase Console > App Check > Apps > Android:
   - Add your Google Play Store SHA-256 app signing certificate fingerprint.
2. **Web (reCAPTCHA Enterprise)**:
   - In Google Cloud Console > Security > reCAPTCHA Enterprise:
   - Create a website key for your production domain (e.g., `ironflow.web.app`).
   - Register the site key in Firebase Console App Check settings.
3. **Enforcement Rollout**:
   - Begin with App Check in **Monitor Mode** for 48 hours to confirm zero legitimate traffic rejection.
   - Once verified, toggle Firestore, Storage, and Cloud Functions to **Enforce**.

---

## 6. Building & Deploying the Web Application

1. **Prepare Release Build**:
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release --dart-define=AI_PROXY_URL="https://<region>-<project-id>.cloudfunctions.net/aiGenerate"
   ```
2. **Deploy to Firebase Hosting**:
   The `firebase.json` file is pre-configured with strict security headers (COOP, COEP, CORP, and 1-year immutable caching for static assets):
   ```bash
   firebase deploy --only hosting
   ```
3. **Verify Deployment**:
   Open the hosting URL (e.g., `https://ironflow-production.web.app`) in Chrome and verify:
   - PWA loads smoothly.
   - Zero console errors or missing font assets.
   - Security headers present in DevTools Network tab.

---

## 7. Building Android Release Artifacts (AAB / APK)

1. **Generate or Import Release Signing Keystore**:
   Follow [`KEY_ROTATION_AND_CREDENTIALS.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/CLIENT_PACK/KEY_ROTATION_AND_CREDENTIALS.md) to place `key.properties` and your keystore in `android/`.
2. **Build Android App Bundle for Google Play**:
   ```bash
   flutter build appbundle --release --dart-define=AI_PROXY_URL="https://<region>-<project-id>.cloudfunctions.net/aiGenerate"
   ```
   Artifact output: `build/app/outputs/bundle/release/app-release.aab`
3. **Build Universal Release APK (for Direct Sideloading / Testing)**:
   ```bash
   flutter build apk --release --dart-define=AI_PROXY_URL="https://<region>-<project-id>.cloudfunctions.net/aiGenerate"
   ```
   Artifact output: `build/app/outputs/flutter-apk/app-release.apk`
   *(R8 shrinking and resource optimization automatically reduce APK size to ~25–30 MB).*

---

## 8. Post-Deployment Verification & Smoke Test Checklist

Execute these 5 verification tests on the deployed production instance:
- [ ] **Auth Flow**: Register a new user with email/password. Verify UID document created in Firestore under `users/{uid}`.
- [ ] **Offline Workout Logging**: Turn on Airplane mode. Log a workout session. Verify data persists and Body Map updates instantly. Reconnect network; verify outbox commits to Firestore without data loss.
- [ ] **AI Coach Proxy**: Send a coaching query ("What is progressive overload?"). Verify instantaneous response from question cache. Send a novel query; verify serverless proxy dispatches and streams answer without revealing backend keys.
- [ ] **Medical Guardrail**: Send "I have severe sharp chest pain". Verify AI immediately displays non-medical disclaimer and directs user to clinical help.
- [ ] **Account Purge**: In `Settings > Account`, tap "Delete Account". Confirm deletion. Verify in Firebase Console that the Auth user, all Firestore subcollections, and all Storage media prefixes are permanently deleted.

