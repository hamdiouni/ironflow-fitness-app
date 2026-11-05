# AI Proxy (`functions/`) & Firebase App Check Deployment Runbook (Wave 1)

> **Important**: Per project rules, nothing is deployed automatically by the assistant. Execute the steps below when ready to provision the staging/production environment.

---

## 1. Prerequisites
- Install the Firebase CLI if not already installed:
  ```powershell
  npm install -g firebase-tools
  firebase login
  ```
- Select your Firebase project:
  ```powershell
  firebase use ironflow-fitness-app
  ```

---

## 2. Configure the Server-Side Gemini API Key in Secret Manager
Never place a production Gemini key in `.env` or `--dart-define` for release/web builds. Store it in Google Cloud Secret Manager:
```powershell
firebase functions:secrets:set GEMINI_API_KEY
```
When prompted, paste the restricted server-side Gemini API key.

---

## 3. Install Dependencies, Test, and Deploy the Cloud Function Proxy
```powershell
cd functions
npm install
npm test
npm run build
cd ..
firebase deploy --only functions:aiGenerate,firestore:rules,firestore:indexes,storage
```

Once deployed, Firebase CLI prints the HTTPS URL for `aiGenerate` (for example `https://aigenerate-<hash>-uc.a.run.app`). Pass that URL at build time via:
```powershell
flutter build apk --release --dart-define=FLAVOR=prod --dart-define=AI_PROXY_URL=https://aigenerate-<hash>-uc.a.run.app
flutter build web --release --dart-define=FLAVOR=prod --dart-define=AI_PROXY_URL=https://aigenerate-<hash>-uc.a.run.app
```

---

## 4. Staged Firebase App Check Rollout (Monitor -> Enforce)

### Stage A — Monitor Mode (Default in Wave 1)
1. In **Firebase Console -> App Check -> Apps**:
   - **Android**: Register Play Integrity with your release signing key SHA-256 fingerprint.
   - **iOS**: Register App Attest + DeviceCheck with your Apple Team ID.
   - **Web**: Register reCAPTCHA Enterprise (pass the site key via `--dart-define=RECAPTCHA_SITE_KEY=<site_key>`).
2. Keep `ENFORCE_APP_CHECK=false` (the default) on `aiGenerate` and in Firestore/Storage while verifying in Firebase Console that 99%+ of legitimate client requests carry valid tokens.

### Stage B — Enforcement Mode
Once attestation metrics are green across Android and Web:
1. Enable App Check enforcement on `aiGenerate` by setting `ENFORCE_APP_CHECK=true` in `functions/.env` and redeploying `functions:aiGenerate`.
2. In **Firebase Console -> App Check -> APIs**, click **Enforce** for **Cloud Firestore** and **Cloud Storage**.

