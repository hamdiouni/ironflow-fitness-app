# Wave 1 Plan — Security & Cloud (P0)

> **Mode:** `PLAN_ONLY: yes` — only `docs/plans/wave-1-plan.md` created; zero source/config/git mutations executed.  
> **Base Commit Verified:** `master` @ `834c51faa4fc31bdb87a1846059f30ccb3dc69da` (clean tree before this file).  
> **Proposed Execution Branch / Backup Tag:** `feat/prod-v2-wave-1` / `backup/pre-prod-v2-wave-1` (see Question #1).  
> **Execution Mode:** `LANES: single` (sequential order in Section 4; parallel `A / B / Integrator` reference in Section 5).

---

## 1. Step 0 — Repository Verification

### 1A. What Exists Today

| Item | Exists? | Evidence |
| :--- | :--- | :--- |
| Clean git repo, remote & V1 history | Yes | `master` @ `834c51f`, `origin` -> `https://github.com/hamdiouni/ironflow-fitness-app.git`. V1 branches `feat/prod-wave-0`..`feat/prod-wave-6` & tags `backup/pre-prod-wave-0` (`36bec3a`), `backup/pre-prod-wave-1` (`612045f`)..`backup/pre-prod-wave-6` already exist. |
| Secret scanner setup & local untracked env files | Partial | `.gitleaks.toml` and `scripts/pre-commit-secrets-check.sh` exist; `.github/workflows/ci.yml:14-26` runs `gitleaks/gitleaks-action@v2`. `.env` & `env.json` exist locally and are untracked (`git ls-files` shows only `.env.example` & `env.example.json`). Legacy `scripts/remove_secrets.sh`, `SECURITY_FIX_GUIDE.md`, `SECURITY_FIX_SUMMARY.md` already removed. **Local `gitleaks` CLI is NOT installed** (`Get-Command gitleaks` empty). |
| Firestore & Storage rules + emulator tests | Partial | `firestore.rules:44-66,102-105,120-142` enforces `readsOwnDoc() && isValidSyncPayload()` on `update`, `isBoundedDoc()`, and `ai_usage` `allow write: if false`. `storage.rules:18-52` has `allow read, delete: if isOwner(userId);` (safe on delete) and `profile`/`workouts`/`progress` rules, **but lacks `users/{userId}/backups/{fileName}` write rules.** `test/rules/firebase_rules.emulator.spec.mjs` exists (130 lines), **but `@firebase/rules-unit-testing` is not installed** (`node_modules` & `functions/node_modules` both `False`), CI does not run rules tests, and `backups/` Storage cases are absent. |
| `BackupDataUseCase` upload metadata & local isolation | Partial | `lib/features/settings/domain/usecases/backup_data_use_case.dart:213-234` uploads JSON to `users/${user.id}/backups/$fileName` via `.putFile(file)` **without `SettableMetadata(contentType: 'application/json')`** and **without rejecting `isLocalOnlyUserId`**. |
| Firebase Functions AI proxy (`functions/`) | Partial | `functions/src/index.ts`, `functions/src/proxy_core.mjs`, and `functions/test/ai_proxy.test.mjs` exist. Bug: `proxy_core.mjs:299-362` increments `users/{uid}/ai_usage` quota **before** checking `geminiApiKey` and **never refunds quota** on upstream `429`, `502`, `503`, or timeout (`504`). |
| Legacy Cloudflare AI proxy (`backend/ai_proxy/`) | Yes (Unretired) | `backend/ai_proxy/worker.js:99-120` decodes Firebase JWT payload with `atob` **without RS256 signature verification**, calls `gemini-1.5-flash`, and sits beside `backend/ai_proxy/wrangler.toml` & `backend/ai_proxy/README.md`. |
| App Check wiring (`ENFORCE_APP_CHECK` vs `APP_CHECK_ENFORCE`) | Partial | `lib/core/services/app_check_service.dart:24-29,61-69` skips Web `activate` when `RECAPTCHA_SITE_KEY` is empty and reads `ENFORCE_APP_CHECK`; `FlavorConfig` (`flavor_config.dart:135,188,228`) reads `APP_CHECK_ENFORCE`; `functions/src/index.ts:39` reads `ENFORCE_APP_CHECK ?? 'false'`. |
| Project ID & config alignment | Broken / Split | `.firebaserc` does not exist. `lib/firebase_options.dart:54,64` & `android/app/google-services.json:4` use **`ironflow-5b79d`**, while `config/production.json:7-8` & `FlavorConfig.production` (`flavor_config.dart:220,225`) use **`gym-app-fe50c`** (`staging.json` -> `ironflow-staging`, `dev.json` -> `ironflow-dev`). |
| Firebase Hosting (`firebase.json`) | Broken / Incomplete | `firebase.json:16-31` has only `Cross-Origin-Resource-Policy: cross-origin` (COOP & COEP were both removed in `f0548c2`); **missing `Cross-Origin-Opener-Policy: same-origin-allow-popups`** and **missing `/generate` -> `aiGenerate` rewrite**. |
| Release auth, debug routes, telemetry & notifications | Partial | `auth_provider.dart:45-80` forces `FirebaseAuthDataSourceImpl` when `kReleaseMode` or `prod`/`staging`. `app_router.dart:414` + `lib/dev/dev_routes.dart:9-27` gate out `/design-preview`, `/design-gallery`, `/ai-test` in `kReleaseMode`. `NotificationService` defers permissions (`notification_permission_timing_test.dart`). `TelemetryPreferences` defaults OFF (`main.dart:84`), **but** `TelemetryConsentScreen` (`telemetry_consent_dialog.dart`) only opens manually from `PrivacySettingsScreen:357` and `AnalyticsService` (`analytics_service.dart`) lacks a pre-send `isAnalyticsEnabled()` guard. |
| Offline Guest & Demo Mode isolation | Partial | `local_sample_data_seeder.dart:18-24` (`local_guest_athlete`, `local_demo_showcase`) & `sync_provider.dart:45,61,93,105` scope sync providers to `null` for local-only IDs; explicit tests proving `SyncService` / `BackupDataUseCase` ignore/reject local-only users are missing. |
| Account deletion (`RemoteDataPurgerImpl` + `LocalDataWiper`) | Partial | `remote_data_purger_impl.dart:9-160` aggregates errors via `RemotePurgeException` and recurses Storage, **but `L107` only deletes `['backups', 'nutrition', 'consent']`, missing `'ai_usage'`.** `LocalDataWiper` (`local_data_wiper.dart:32-58,182`) skips `'foods'` box so `custom_foods_<userId>` keys persist. |
| Critical Sync fixes (`1.7`) | Broken | 1) `sync_service.dart:787-797` + `hive_sync_queue_datasource.dart:93-97`: `retryFailedActions` preserves `retryCount >= 3` (`L359` skips forever). 2) `synced_workout_repository.dart:80-88,158-166`: duplicate `syncAll` after `queueAction` (`sync_service.dart:146`). 3) `sync_service.dart:747-753`: `_advanceCursor` uses client `DateTime.now()`, and `firestore_sync_datasource.dart:294-310` `_pullQuery` has no `.limit(...)`. 4) `active_program_repository_impl.dart:113-116` & `active_program_providers.dart:45-54`: `clearActiveProgram` has no remote delete hook. |
| Critical Food, Router & Signup fixes (`1.7`) | Broken | 1) `food_repository_impl.dart:68` calls `cacheFoods([model])`, overwriting `'foods_cache'` (`hive_food_datasource.dart:83-87`). 2) `app_router.dart:169-177` Case 3 blocks `/onboarding?mode=edit` for onboarded users + `settings_screen.dart:125` navigates without `?mode=edit`. 3) `signup_screen.dart:24,67-70`, `auth_notifier.dart:114-132`, `sign_up_use_case.dart`, `auth_repository_impl.dart`, `firebase_auth_datasource.dart` ignore `_nameController` display name. |

### 1B. Claims Checked (Reports / ADRs / Prompt Hypotheses vs Repo Reality)

| Claim | Verified? | Evidence |
| :--- | :--- | :--- |
| *"Repo may be newer than Wave 0 reports (AI proxy, encrypted storage, flavors exist)."* | **True (Verified)** | V1 Waves 1–6 (`ca4d06a`..`834c51f`) landed `functions/` proxy, `FlavorConfig` + `config/*.json`, `TelemetryPreferences`, `RemoteDataPurgerImpl`, `HiveEncryptionService`, and flat sync tombstone rules, while specific Wave 1 gaps remain. |
| *"Firestore `update` checks ownership & Storage `delete` crashes on `request.resource`; add emulator tests."* | **Rules Fixed / Backups & Deps Missing** | `firestore.rules:123-141` already checks `readsOwnDoc() && isValidSyncPayload()` on `update`; `storage.rules:18-20` separates `read, delete`. `test/rules/firebase_rules.emulator.spec.mjs` exists, **but** lacks `users/{uid}/backups/{file}` rules/tests and `@firebase/rules-unit-testing` is missing from `node_modules` / `functions/package.json` / CI. |
| *"`backend/ai_proxy/worker.js` decodes JWT without RS256 verification and should be retired."* | **True (Verified)** | `backend/ai_proxy/worker.js:99-120` decodes JWT with `atob` only (unverified signature) and sits alongside `backend/ai_proxy/wrangler.toml` & `README.md`. Must retire `[ASK]`. |
| *"Cloud Function proxy checks key before quota & refunds on 429/502/503/timeouts."* | **False (Bug Present)** | `functions/src/proxy_core.mjs:299-362` runs `checkAndIncrementDailyQuota` before `geminiApiKey` validation and never refunds on transient upstream failures or aborts. |
| *"`firebase.json` has `Cross-Origin-Opener-Policy: same-origin-allow-popups` and `/generate` rewrite."* | **False (Missing)** | Commit `f0548c2` removed COOP alongside COEP from `firebase.json`, leaving only `Cross-Origin-Resource-Policy: cross-origin`, and `rewrites` has no `/generate` route. |
| *"One Firebase project ID across `config/*.json`, `.firebaserc`, and `firebase_options.dart`."* | **False (Contradictory)** | `firebase_options.dart` & `google-services.json` specify `ironflow-5b79d`; `config/production.json` specifies `gym-app-fe50c`; `.firebaserc` is missing. |
| *"Baseline checks (`flutter pub get / analyze / test / build web / build apk --debug`) status"* | **Not Run in `PLAN_ONLY`** | Not executed during planning; scheduled as the mandatory pre-edit Baseline Gate before any code changes begin. |

---

## 2. Questions for Owner (Required Before Executing Wave 1)

1. **Branch & Backup Tag Naming Collision:** Prompt asks for `feat/prod-wave-1` and `backup/pre-prod-wave-1`, which **already exist** from V1 (`backup/pre-prod-wave-1` -> `612045f`, while `master` is `834c51f`). Rules forbid rewriting history or forcing tags. Approve **`feat/prod-v2-wave-1`** and **`backup/pre-prod-v2-wave-1`** pointing to `834c51f`?
2. **Unfilled Owner Setting Placeholders:**
   - `keys revoked = [yes, I confirm]`: Confirm all exposed provider keys prior to `backup/pre-prod-wave-0` have been revoked and rotated.
   - `cloud budget cap = [my number]`: Supply the USD monthly/daily budget cap so `functions/` quota (`AI_DAILY_LIMIT`) and budget alerts match it.
3. **File Deletion & Dependency Additions (`[ASK]`):**
   - Approve deleting legacy Cloudflare files: `backend/ai_proxy/worker.js`, `backend/ai_proxy/wrangler.toml`, and `backend/ai_proxy/README.md`?
   - Approve adding `@firebase/rules-unit-testing` (and `firebase` client SDK if needed for emulator execution) to `functions/package.json` `devDependencies` (verifying exact version, license, and last npm release date before install)?
4. **Canonical Production Firebase Project ID (`1.3`):** Confirm whether **`ironflow-5b79d`** (in `lib/firebase_options.dart`, `android/app/google-services.json`, `auth_notifier.dart`, `firebase_auth_datasource.dart`) or **`gym-app-fe50c`** (in `config/production.json`, `FlavorConfig.production`) is the live production Firebase project, and confirm aliases for `.firebaserc` (`default`, `production`, `staging`, `dev`).
5. **Local `gitleaks` Install (`1.0`):** `gitleaks` is absent on this machine (`Get-Command gitleaks` empty). Can you install it first (e.g., `winget install Gitleaks.Gitleaks` or `scoop install gitleaks` / `choco install gitleaks`), or should local secret scan be marked **`PARTIAL`** while CI `gitleaks-action@v2` stays blocking? (Also confirm `.env` and `env.json` locally contain no leaked secrets or hold rotated dev values only.)
6. **App Check Web `RECAPTCHA_SITE_KEY` (`1.2`):** Do you have the Web reCAPTCHA v3 / Enterprise **site key** for `--dart-define=RECAPTCHA_SITE_KEY=...`? Also confirm unifying flag naming (`ENFORCE_APP_CHECK` vs `APP_CHECK_ENFORCE`) and starting Functions in monitor mode (`ENFORCE_APP_CHECK=false`) until web & Android tokens are verified.
7. **Consent Auto-Prompt, Production Offline/Demo UI & `custom_foods` Wipe (`1.5`–`1.6`):**
   - Should `TelemetryConsentScreen.showIfNeeded` trigger once automatically on `MainScaffold` first mount (`lib/main.dart`) in addition to `PrivacySettingsScreen`?
   - Should `OfflineAccessSection` (`Continue Offline` / `Explore Live Demo`) remain enabled in production flavor with strict `isLocalOnlyUserId` sync/backup guards?
   - Approve targeted deletion of `custom_foods_<userId>` keys inside `'foods'` box in `LocalDataWiper` during Wave 1 (leaving full `custom_foods` box split/encryption in Wave 3.2)?

---

## 3. Tests Written First (Characterization & Emulator Gate — Red -> Green)

Every behavioral change follows **write failing test -> fix -> verify green**:

| Area | Target Test File (`[NEW]` or Existing) | Failing Cases Written Before Production Edit |
| :--- | :--- | :--- |
| **1.1** Storage Backup Rules & Metadata | `test/rules/firebase_rules.emulator.spec.mjs` | Owner `create/read/delete` on `users/{uid}/backups/b1.json` (`application/json`, `<= 10 MB`) succeeds; cross-user, anonymous, oversize (`> 10 MB`), and non-JSON (`text/plain`) writes fail. |
| **1.1** Backup Upload Metadata & Offline Block | `test/features/settings/backup_restore_characterization_test.dart` | `BackupDataUseCase.createManualBackup()` passes `SettableMetadata(contentType: 'application/json')` to `putFile`; local-only `isLocalOnlyUserId` throws before touching Storage/Firestore. |
| **1.2** Functions Proxy Quota & Auth | `functions/test/ai_proxy.test.mjs` | Missing `geminiApiKey` returns `503` without incrementing `ai_usage`; upstream `429`/`502`/`503`/timeout abort refunds transactional quota (`>= 0`); forged/expired token returns `401`; `ENFORCE_APP_CHECK=true` rejects missing/invalid `X-Firebase-AppCheck` while `false` allows monitor mode. |
| **1.2 / 1.4** Client App Check & Hosting Rewrite URL | `test/features/ai/ai_proxy_transport_and_app_check_test.dart` | App Check web key + unified enforcement flag behavior; `GeminiAiService` handles `/generate` Hosting rewrite alongside `/aiGenerate`. |
| **1.3** Single-Source Flavor Config | `test/core/config/flavor_config_test.dart` | `config/production.json` matches `.firebaserc` & `firebase_options.dart` project ID; `config/dev.json` contains zero production project IDs or production proxy URLs. |
| **1.5** Telemetry Opt-In Guard & Consent Flow | `test/core/services/telemetry_preferences_test.dart` & `test/features/auth/release_safety_characterization_test.dart` | `AnalyticsService` skips logging when `TelemetryPreferences.isAnalyticsEnabled()` is `false`; `TelemetryConsentScreen.showIfNeeded` fires once when unconsented; debug routes (`/design-preview`, `/design-gallery`, `/ai-test`) & `MockAuthDataSourceImpl` blocked in release mode; `SyncService` no-ops for `isLocalOnlyUserId`. |
| **1.6** Account Deletion E2E | `test/features/settings/remote_data_purger_test.dart` & `test/features/settings/account_and_data_deletion_test.dart` | `RemoteDataPurgerImpl` deletes `users/{uid}/ai_usage` + nested subcollections + Storage recursively and throws `RemotePurgeException` before local wipe/auth delete on partial error; `LocalDataWiper` clears `custom_foods_<userId>` while preserving shared `foods_cache`. |
| **1.7a–d** Sync Correctness (Retry, Dupes, Cursor/Limit, Program Delete) | `test/features/sync/sync_correctness_wave1_test.dart` & `test/features/workout/data/repositories/synced_workout_repository_test.dart` | `retryFailedActions()` resets `retryCount` to `0` so previously failed actions push; saving/deleting one workout triggers one push cycle (no duplicate `syncAll`); pull cursor advances to max server `syncedAt` (not client clock) with `.limit(...)` query cap; `clearActiveProgram()` enqueues remote `deleteProgram`. |
| **1.7e** `getFoodById` Cache Upsert | `test/features/nutrition/data/datasources/hive_food_datasource_test.dart` (or `food_repository_cache_test.dart` `[NEW]`) | Calling `getFoodById('f2')` when `foods_cache` holds `[f1]` leaves `[f1, f2]` in cache instead of overwriting with `[f2]`. |
| **1.7f** Onboarding Edit Mode Route | `test/core/router/app_router_test.dart` & `test/features/settings/settings_screen_characterization_test.dart` | Signed-in onboarded user navigating to `/onboarding?mode=edit` is NOT redirected back to `/home`; Settings "Edit Body Stats & Goals" routes to `/onboarding?mode=edit`. |
| **1.7g** Signup Display Name | `test/features/auth/auth_and_onboarding_gate_characterization_test.dart` | Email signup passes non-empty `_nameController` text through `SignUpUseCase` -> `AuthRepositoryImpl` -> `FirebaseAuthDataSourceImpl` (`updateDisplayName` + Firestore profile `name`) & `MockAuthDataSourceImpl`. |

---

## 4. Files to Change (Ordered Execution Sequence)

### Execution Order (`LANES: single`)
1. **Pre-Edit Safety & Baseline (`Step 0 Gate`):**
   - Create `backup/pre-prod-v2-wave-1` tag at `834c51f`, checkout `feat/prod-v2-wave-1`.
   - Run baseline gate: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web`, `flutter build apk --debug`, `cd functions && npm ci && npm test`.
2. **Order 1 — `1.0` Secret Scan & Git Verification:**
   - Run `gitleaks detect` across tree, history (`--log-opts="--all"`), and `build/` + `bash scripts/pre-commit-secrets-check.sh --ci-verify` (logs stored outside repo; deleted after confirmation). *(Mark `PARTIAL` if `gitleaks` missing locally.)*
3. **Order 2 — `1.1` Rules + Emulator Tests:**
   - `[MODIFY]` `functions/package.json`, `functions/package-lock.json` (`@firebase/rules-unit-testing` `[ASK]`)
   - `[MODIFY]` `test/rules/firebase_rules.emulator.spec.mjs` (write Storage backup tests first -> run emulator -> fail)
   - `[MODIFY]` `storage.rules` (add `users/{userId}/backups/{fileName}` rule with size + `application/json` content-type bounds)
   - `[MODIFY]` `firebase.json` (ensure emulator ports for `firestore`, `storage`, `auth`, `functions`)
   - `[MODIFY]` `test/features/settings/backup_restore_characterization_test.dart` -> `[MODIFY]` `lib/features/settings/domain/usecases/backup_data_use_case.dart` (`SettableMetadata(contentType: 'application/json')` + reject `isLocalOnlyUserId`)
4. **Order 3 — `1.2` Single AI Proxy + App Check + Worker Retirement:**
   - `[MODIFY]` `functions/test/ai_proxy.test.mjs` (write failing tests first)
   - `[MODIFY]` `functions/src/proxy_core.mjs`, `functions/src/index.ts` (check `geminiApiKey` before quota, atomic quota refund on 429/502/503/504/abort, strict `verifyIdToken`, App Check monitor mode default)
   - `[MODIFY]` `test/features/ai/ai_proxy_transport_and_app_check_test.dart` -> `[MODIFY]` `lib/core/services/app_check_service.dart`, `lib/core/config/flavor_config.dart` (wire Web `RECAPTCHA_SITE_KEY` + aligned App Check flag naming)
   - `[DELETE [ASK]]` `backend/ai_proxy/worker.js`, `backend/ai_proxy/wrangler.toml`, `backend/ai_proxy/README.md`
5. **Order 4 — `1.3` & `1.4` Config Alignment & Firebase Hosting:**
   - `[MODIFY]` `test/core/config/flavor_config_test.dart`
   - `[NEW]` `.firebaserc`
   - `[MODIFY]` `config/dev.json`, `config/staging.json`, `config/production.json`, `lib/core/config/flavor_config.dart`, `lib/firebase_options.dart` (only if canonical project != `ironflow-5b79d`), `lib/features/auth/data/datasources/firebase_auth_datasource.dart`, `lib/features/auth/presentation/providers/auth_notifier.dart`
   - `[MODIFY]` `firebase.json` (`Cross-Origin-Opener-Policy: same-origin-allow-popups`, `/generate` -> `aiGenerate` rewrite; no `COEP: require-corp`)
   - `[MODIFY]` `lib/features/ai/data/datasources/gemini_ai_service.dart` (verify `/generate` & `/aiGenerate` path handling)
6. **Order 5 — `1.5` Release Safety & Telemetry Consent Wiring:**
   - `[MODIFY]` `test/core/services/telemetry_preferences_test.dart`, `test/features/auth/release_safety_characterization_test.dart`, `test/features/auth/local_offline_and_demo_mode_test.dart`
   - `[MODIFY]` `lib/core/services/analytics_service.dart` (guard methods with `TelemetryPreferences.isAnalyticsEnabled()`)
   - `[MODIFY]` `lib/main.dart` (`MainScaffold`: post-frame `TelemetryConsentScreen.showIfNeeded(context)` if approved)
   - `[MODIFY]` `lib/features/sync/data/services/sync_service.dart` (defense-in-depth `isLocalOnlyUserId` early return inside `queueAction` / `syncAll`)
7. **Order 6 — `1.6` Account Deletion End-to-End:**
   - `[MODIFY]` `test/features/settings/remote_data_purger_test.dart`, `test/features/settings/account_and_data_deletion_test.dart`
   - `[MODIFY]` `lib/features/settings/data/repositories/remote_data_purger_impl.dart` (add `'ai_usage'` subcollection deletion)
   - `[MODIFY]` `lib/features/settings/domain/services/local_data_wiper.dart` (targeted deletion of `custom_foods_<userId>` inside `'foods'` box)
8. **Order 7 — `1.7` Critical App Bug Fixes (each Red -> Green in sequence):**
   - **7a Sync retry reset:** `test/features/sync/sync_correctness_wave1_test.dart` -> `lib/features/sync/data/datasources/hive_sync_queue_datasource.dart`, `lib/features/sync/data/services/sync_service.dart`
   - **7b Remove duplicate `syncAll`:** `test/features/workout/data/repositories/synced_workout_repository_test.dart` -> `lib/features/workout/data/repositories/synced_workout_repository.dart`
   - **7c Server `syncedAt` cursor & query `.limit(...)`:** `test/features/sync/sync_correctness_wave1_test.dart` -> `lib/features/sync/data/datasources/firestore_sync_datasource.dart`, `lib/features/sync/data/services/sync_service.dart`
   - **7d `clearActiveProgram` remote delete:** `test/features/sync/sync_correctness_wave1_test.dart` -> `lib/features/workout/data/repositories/active_program_repository_impl.dart`, `lib/features/workout/presentation/providers/active_program_providers.dart`
   - **7e `getFoodById` upsert cache:** `test/features/nutrition/data/datasources/hive_food_datasource_test.dart` (or `food_repository_cache_test.dart` `[NEW]`) -> `lib/features/nutrition/data/datasources/hive_food_datasource.dart`, `lib/features/nutrition/data/repositories/food_repository_impl.dart`
   - **7f Router `/onboarding?mode=edit`:** `test/core/router/app_router_test.dart`, `test/features/settings/settings_screen_characterization_test.dart` -> `lib/core/router/app_router.dart`, `lib/features/settings/presentation/screens/settings_screen.dart`, `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
   - **7g Signup display name:** `test/features/auth/auth_and_onboarding_gate_characterization_test.dart` -> `lib/features/auth/presentation/screens/signup_screen.dart`, `lib/features/auth/presentation/providers/auth_notifier.dart`, `lib/features/auth/domain/usecases/sign_up_use_case.dart`, `lib/features/auth/domain/repositories/auth_repository.dart`, `lib/features/auth/data/repositories/auth_repository_impl.dart`, `lib/features/auth/data/datasources/auth_datasource.dart`, `lib/features/auth/data/datasources/firebase_auth_datasource.dart`, `lib/features/auth/data/datasources/mock_auth_datasource.dart`
9. **Order 8 — Final Gate & Checkpoints (No Push / No Deploy):**
   - Re-run full Baseline Gate (`flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web`, `flutter build apk --debug`, `cd functions && npm ci && npm test`), Firebase Emulator rules suite (`firebase emulators:exec --only firestore,storage "node --test test/rules/firebase_rules.emulator.spec.mjs"`), and local Hosting emulator browser test verifying Google Sign-In popup (COOP `same-origin-allow-popups`) + YouTube embed loading.

---

## 5. Parallel Lane Reference (If `LANES` Is Switched to `parallel`)

| Lane | Disjoint Files Owned | Wave 1 Scope |
| :--- | :--- | :--- |
| **Lane A — Cloud** | `functions/**`, `firestore.rules`, `storage.rules`, `test/rules/**`, `backend/ai_proxy/**` | `1.1` rules & emulator tests, `1.2` proxy quota/App Check/forged-token tests, retire `backend/ai_proxy/` (`[ASK]`) |
| **Lane B — App** | `lib/features/**`, `lib/core/services/**`, `test/**` (except `test/core/config/**`, `test/core/router/**`, `test/rules/**`) | `1.1` backup metadata, `1.2` client App Check/proxy service, `1.5` analytics/sync guard, `1.6` purge/wipe, `1.7a–e,g` |
| **Integrator** | `firebase.json`, `.firebaserc`, `config/*.json`, `android/app/google-services.json`, `lib/firebase_options.dart`, `lib/core/config/flavor_config.dart`, `lib/core/router/app_router.dart`, `lib/main.dart`, `lib/features/settings/presentation/screens/settings_screen.dart`, `lib/features/onboarding/presentation/screens/onboarding_screen.dart`, `test/core/config/**`, `test/core/router/**`, `pubspec.*`, `.github/workflows/ci.yml` | Baseline, `1.0` secret scan, `1.3` config alignment, `1.4` Hosting headers/rewrite, `1.5` `MainScaffold` consent wiring, `1.7f` `/onboarding?mode=edit` route & settings navigation, lane merges & full verification gates |
