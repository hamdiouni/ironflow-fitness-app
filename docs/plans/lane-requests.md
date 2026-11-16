# Cross-Lane Requests

This document tracks files owned by other lanes that are needed by a specific lane during Wave 1 implementation.

## Guidelines
- **Lane A (Cloud)** owns: `functions/**`, `firebase.json`, `firestore.rules`, `storage.rules`, `test/rules/**`, `.firebaserc`.
- **Lane B (App)** owns: app domain/data/presentation files for backup, sync, telemetry, local data wiper, food repo, auth signup.
- **Integrator** owns: `pubspec.*`, `lib/main.dart`, `lib/core/router/app_router.dart`, `config/*.json`, `.github/workflows/ci.yml`, `l10n`, generated files.

If a lane needs a change in a file owned by another lane or Integrator, log the request below.

---

## Logged Requests

### Request LR-01: MainScaffold Telemetry Consent Auto-Prompt
- **Requester:** Lane B (App)
- **Target File:** `lib/main.dart`
- **Owner:** Integrator
- **Description:** Invoke `TelemetryConsentScreen.showIfNeeded(context)` once after user is authenticated on app startup in `MainScaffold`.
- **Status:** COMPLETED (`0bf5171`)

### Request LR-02: Router Support for Edit Mode Onboarding
- **Requester:** Lane B (App)
- **Target File:** `lib/core/router/app_router.dart`
- **Owner:** Integrator
- **Description:** Update redirect logic to allow `/onboarding?mode=edit` for already-onboarded users without redirecting to `/home`.
- **Status:** COMPLETED (`0bf5171`)

### Request LR-03: Production Config Firebase Project ID
- **Requester:** Lane A / Lane B
- **Target File:** `config/production.json`
- **Owner:** Integrator
- **Description:** Update `FIREBASE_PROJECT_ID` to canonical `ironflow-5b79d`.
- **Status:** COMPLETED (`0bf5171`)

### Request LR-04: Firestore Rules Owner Delete for AI Usage Subcollection
- **Requester:** Lane B (App)
- **Target File:** `firestore.rules`
- **Owner:** Lane A (Cloud)
- **Description:** Update `match /users/{userId}/ai_usage/{dateId}` from `allow write: if false;` to allow owner delete: `allow read, delete: if isOwner(userId); allow create, update: if false;`. This enables `RemoteDataPurgerImpl` to delete `ai_usage` records during account deletion without encountering `permission-denied`.
- **Status:** COMPLETED (`f465a59`)

### Request LR-05: Settings Screen & Onboarding UI Edit Mode Navigation
- **Requester:** Lane B (App)
- **Target Files:** `lib/features/settings/presentation/screens/settings_screen.dart`, `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- **Owner:** Integrator
- **Description:** 
  1. In `settings_screen.dart:125`: Update "Edit Body Stats & Goals" tile from `context.go(AppRoutes.onboarding)` to `context.push('${AppRoutes.onboarding}?mode=edit')` so users route with edit intent.
  2. In `onboarding_screen.dart`: When `mode == 'edit'`, initialize steps with existing `userProfileProvider` data and allow updating without resetting user onboarding state.
- **Status:** COMPLETED (`0bf5171` + Wave 1 completion edit)
