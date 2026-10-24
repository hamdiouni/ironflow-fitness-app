# IronFlow Phase A — Staging & Release Runbook

This runbook covers the operational work that cannot be completed by code
alone: Firebase project setup, OAuth platform configuration, rules/index
deployment, AI proxy configuration, signing, and acceptance proof.

Do **not** change the default value of `USE_FIREBASE_AUTH` until every item in
sections 1–5 passes on staging and the mock→Firebase local-data decision in
section 6 is explicitly approved.

## 0. Local verification gate

Run from a clean checkout:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
flutter build apk --debug
flutter build apk --release
```

On macOS, after iOS FlutterFire configuration exists:

```bash
flutter build ios --debug --no-codesign
```

Record the Flutter/Dart versions and attach CI links to the release notes.

## 1. Firebase projects and FlutterFire

1. Create separate Firebase projects (recommended):
   - `ironflow-staging`
   - `ironflow-prod` (or keep the existing production project only after audit)
2. Register Android, Web, and iOS apps with the real bundle/application IDs.
3. Regenerate platform config from the repo root, for example:

```bash
dart pub global activate flutterfire_cli
flutterfire configure \
  --project=<staging-project-id> \
  --ios-bundle-id=<ios.bundle.id> \
  --macos-bundle-id=<macos.bundle.id> \
  --android-package-name=com.progressiontracker.progression_tracker
```

4. Confirm `lib/firebase_options.dart` contains no `YOUR_*` placeholders for
   every platform you intend to ship.
5. Add Android debug and release SHA-1/SHA-256 fingerprints to Firebase for
   Google sign-in.
6. Configure iOS Google URL schemes/client IDs and Apple Sign-In capability if
   those buttons remain visible.

> Current repository state: Web/Android Firebase options are real;
> iOS/macOS/Windows intentionally throw `UnsupportedError` until FlutterFire
> is regenerated for them.

## 2. Auth providers

In Firebase Console → Authentication → Sign-in method, enable only providers
that are fully configured and tested:

- Email/Password
- Google (after SHA/OAuth/iOS setup)
- Apple (after Apple Developer + Firebase Apple provider setup)

If a provider is not ready for a release, hide its button for that release.

## 3. Firestore/Storage rules and indexes

Deploy from the repo root after selecting the staging project:

```bash
firebase use <staging-project-id>
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Important rule notes:

- Shared `foods` and `exercises` writes require a Firebase Auth custom claim:

```json
{ "admin": true }
```

Grant that claim only to operator accounts using the Firebase Admin SDK or a
trusted backend script. Normal users can read catalogs; user custom foods stay
local and do not write to the shared catalog.

- Seed catalogs with an admin-claimed operator account or Admin SDK/service
  account (Admin SDK bypasses rules). Do not loosen client write rules for
  seeding.
- Profile/progress/workout Storage objects are owner-only.

## 4. AI proxy

Production AI must not use client-bundled provider keys.

Minimum proxy contract used by the current Gemini client:

- Base URL supplied as `AI_PROXY_URL`
- Client posts to `<AI_PROXY_URL>/generate`
- Client sends `Authorization: Bearer <Firebase ID token>` when signed in
- Proxy verifies the Firebase ID token server-side
- Proxy owns Gemini credentials, per-user quotas, timeouts, request-size limits,
  logging/redaction, and provider error mapping

Build staging with, for example:

```bash
flutter run \
  --dart-define=USE_FIREBASE_AUTH=true \
  --dart-define=AI_PROXY_URL=https://<staging-ai-proxy>
```

Direct `OPENAI_API_KEY` / `GEMINI_API_KEY` / `NVIDIA_API_KEY` values are debug
-only and are ignored/fail closed in profile/release builds.

## 5. Signing and CI secrets

### Android

For local signed builds, copy `android/key.properties.example` to
`android/key.properties` and fill it with the upload keystore values. Never
commit `android/key.properties` or keystores.

For GitHub Actions store signing, configure:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Without all four, CI still compile-proves release using the debug-signing
fallback; that artifact is not Play-uploadable.

### iOS

Still required outside this repo:

- Apple Developer team/provisioning profiles/certificates
- App Store Connect app record
- Sign in with Apple capability if enabled
- Privacy manifest/data-use answers review
- A signed archive/TestFlight pipeline

## 6. Mock→Firebase UID decision (required before default flip)

Mock auth derives stable IDs such as `user_<hash>`; Firebase uses real UIDs.
Choose one explicitly:

1. **Fresh-account cutover:** communicate that enabling Firebase starts a new
   cloud account; keep local legacy data only under the existing guarded
   adoption rules.
2. **Guided migration:** capture the previous mock/session UID before the
   first Firebase sign-in, show user consent, then re-stamp/move owned local
   records and scoped keys to the Firebase UID with a one-time marker and
   rollback snapshot.

Do not silently bulk-stamp another account's records. Test the selected path
with pre-upgrade fixtures before changing the default.

## 7. Staging acceptance checklist

### Two accounts, one device

- [ ] Sign up Alice; complete onboarding; create active program/diet plan.
- [ ] Log workout, body weight, and meals; confirm Profile shows those values.
- [ ] Sign out; sign up Bob on the same device.
- [ ] Confirm Bob does not see Alice profile, active/archived program, diet
      plan, workouts, body entries, meals, or targets.
- [ ] Sign back in as Alice; confirm Alice program/diet/history are intact.

### Two devices

- [ ] Sign in as Alice on devices A and B.
- [ ] Create/update/delete workout, meal, body entry, targets, and program on A.
- [ ] Confirm convergence on B, including tombstone deletes.
- [ ] Go offline on B, log data, reconnect, and confirm outbox flush.
- [ ] Edit the same program on both devices and verify documented LWW behavior.

### Account lifecycle

- [ ] Export data; restore into a clean install; compare counts.
- [ ] Delete local data; confirm account can sign in again cleanly.
- [ ] Delete account; confirm Firebase Auth user, Firestore docs, Storage
      objects, and local Hive/session data are gone.
- [ ] Interrupt deletion mid-flow; relaunch and confirm pending wipe completes.

### Notifications/photos

- [ ] Deny and later grant Android notification permission.
- [ ] Verify workout/meal/streak reminders use inexact scheduling acceptably.
- [ ] Start a rest timer, lock/background/kill the app, and verify resume sync.
- [ ] Pick a progress photo on iOS and Android; verify purpose copy/permissions.

### AI

- [ ] Release build without `AI_PROXY_URL` shows AI unavailable/fails closed.
- [ ] Release build with proxy + signed-in user succeeds.
- [ ] Signed-out/expired-token request returns a controlled auth error.
- [ ] With AI personalization consent off, no personal context is sent.
- [ ] Verify per-user quota/rate-limit behavior at the proxy.

## 8. Rollback

- Keep the previous signed build and Firebase rules/index export.
- If staging auth/sync misbehaves, ship/keep `USE_FIREBASE_AUTH=false` builds;
  do not hot-fix by loosening Firestore/Storage rules.
- If a rules deploy is bad, redeploy the previous known-good
  `firestore.rules`/`storage.rules` from git and capture the failing request in
  Firebase rules monitoring before retrying.
