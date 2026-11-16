# AI Proxy & Firebase App Check Deployment Runbook

This runbook documents deploying and rolling out the IronFlow authenticated AI proxy (`aiGenerate` in `functions/src/index.ts`, ADR-001) and Firebase App Check.

> **Important**: Never run deployment commands (`firebase deploy`) from automated CI or unapproved scripts without owner sign-off. Run manual production deployments interactively with the owner.

## 1. Architecture Overview

- **Single Canonical Proxy**: Firebase Cloud Functions 2nd Gen (`functions/src/index.ts` -> `aiGenerate`, region `us-central1`).
- **Hosting Rewrite (`firebase.json`)**: `/generate` rewrites to `aiGenerate`; production URL is `https://us-central1-ironflow-5b79d.cloudfunctions.net/aiGenerate`.
- **Authentication & Abuse Controls (`functions/src/proxy_core.mjs`)**:
  - Verifies Firebase Auth ID token (`Authorization: Bearer <idToken>`) using `getAuth().verifyIdToken(...)`.
  - Checks `GEMINI_API_KEY` availability before incrementing quota.
  - Enforces atomic per-user daily quota in Firestore (`users/{uid}/ai_usage/{yyyy-mm-dd}`, configurable via `AI_DAILY_QUOTA`), refunding quota on `429`, `502`, `503`, or upstream timeouts.
  - Validates model allow-list and bounded message payload sizes; never logs prompts or personal health records.

## 2. Secrets & Firebase Project Setup

Select target alias in `.firebaserc` (`production` -> `ironflow-5b79d`, `staging` -> `ironflow-staging`, `dev` -> `ironflow-dev`):

```powershell
firebase use production
firebase functions:secrets:set GEMINI_API_KEY
```

Never commit `GEMINI_API_KEY` or store it inside `config/*.json` or `assets/`.

## 3. Staged App Check Rollout

1. **Stage 1 — Monitor First (Default in `config/production.json` and `functions/src/index.ts`)**:
   - `ENFORCE_APP_CHECK=false` lets clients attach valid App Check tokens when available (Play Integrity on Android, DeviceCheck/App Attest on iOS, reCAPTCHA v3 on Web via `--dart-define=RECAPTCHA_V3_SITE_KEY=<site-key>`) without hard-blocking legacy or Web sessions during rollout.
   - Verify token health in Firebase Console -> App Check metrics.
2. **Stage 2 — Strict Enforcement**:
   - Once Web `RECAPTCHA_V3_SITE_KEY` and mobile attestations show >= 99% verified traffic, update `ENFORCE_APP_CHECK=true` on Cloud Functions environment configuration and `config/production.json`.

## 4. Local Emulator & Pre-Deploy Verification

```powershell
cd functions
npm ci
npm run build
npm test
cd ..
firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"
```

## 5. Manual Production Deployment Steps (Owner Executed)

```powershell
# 1. Deploy Firestore & Storage rules first
firebase deploy --only firestore:rules,storage

# 2. Deploy Cloud Functions proxy (aiGenerate)
firebase deploy --only functions:aiGenerate

# 3. Build Web release & deploy Hosting (uses COOP: same-origin-allow-popups)
flutter build web --release --dart-define-from-file=config/production.json --dart-define=RECAPTCHA_V3_SITE_KEY=<site-key>
firebase deploy --only hosting
```
