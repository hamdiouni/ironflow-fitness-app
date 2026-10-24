# IronFlow — Deep Whole-Project Audit & 10/10 Scorecard

Date: 2026-10-24  
Branch audited: `arena/cdde9dfd-ironflow-fitness-app`  
Method: static repository audit only. No Flutter/Dart SDK was available in the
audit environment, so compilation, tests, device behaviour, store review, and
live Firebase behaviour still require local/staging verification.

## Executive verdict

IronFlow is a feature-rich, clearly positioned fitness product with a strong
offline-first foundation and a distinctive visual identity. It is **not yet
10/10 in all parts**. The current whole-project rating is **6.6/10**.

The fastest route to 10/10 is not more features. It is: prove the build,
activate and prove real auth/sync, finish per-account isolation, secure AI,
wire localization/accessibility properly, reduce maintenance hotspots, and
make documentation claims match shipped reality.

### Repository scale snapshot

| Metric | Value |
|---|---:|
| Dart files under `lib/` | 394 |
| Dart LOC under `lib/` | 91,605 |
| Test files (`*_test.dart`) | 92 |
| Test LOC | 23,403 |
| Integration test files | 3 |
| Feature areas | 14 |
| Dart files over 1,000 LOC | 17 |
| Docs files under `docs/` | 246 |
| Additional `.kiro/` docs | 68 |

## Scoring rubric

| Score | Meaning |
|---:|---|
| 10 | Production-proven, measured, secure, accessible, tested, documented, and boringly reliable |
| 8–9 | Strong beta / near production quality with small known gaps |
| 6–7 | Useful and functional, but with material reliability, UX, security, or maintainability gaps |
| 4–5 | Risky, incomplete, misleading, or not yet operational |
| 0–3 | Missing or unsafe |

## Whole-project scorecard

| Area | Current | 10/10 target state |
|---|---:|---|
| Product strategy & positioning | 8.0 | One sharp ICP, proven willingness to pay/retain, clear “never” list, measured core loop |
| Onboarding & activation | 6.8 | <2 min to first plan, resumable, localized/accessible, instrumented funnel, A/B tested |
| Workout planning & program generation | 7.6 | Evidence-based splits, stable exercise IDs, editable plans, validated progression rules |
| Active workout execution & rest timer | 7.8 | One-thumb gym logging, lock-screen-safe timer, offline crash recovery, device-proven notifications |
| Nutrition logging & diet plans | 6.8 | Barcode + fast repeat foods, trusted catalog, adaptive targets, saved plans per user |
| Body tracking, progress & analytics | 7.1 | Reliable trends, photos, strength standards, HealthKit/Health Connect, strong tests |
| AI coach & insights | 5.7 | Proxy-only AI, user-scoped context, cost caps, evals, deterministic math separated from LLM text |
| Profile & personalization | 7.9 | Account identity + latest body/workout/nutrition data, editable, source-labelled, no generated placeholders |
| Authentication & account lifecycle | 5.8 | Real Firebase default, social auth working, reauth/delete/export proven, mock only in dev |
| Data integrity & per-user isolation | 7.2 | Every user record owner-scoped locally/remotely, migrations proven, no singleton leakage |
| Sync, offline & backup/restore | 6.5 | Two-device convergence proven, conflict tests, background backup, restore drills |
| Architecture & maintainability | 6.2 | Small modules, typed errors, few `dynamic`s, no duplicate models, clear ownership boundaries |
| UI, brand & design system | 7.7 | Distinctive HUD, token-only styling, consistent components, motion/haptics with reduced-motion support |
| Accessibility, localization & responsive UX | 4.7 | WCAG-minded semantics/contrast/touch targets, all strings localized, tablet/landscape tested |
| Performance & scalability | 6.4 | Profiled startup/scroll budgets, lazy catalogs, pagination everywhere, performance regression tests |
| Security, privacy & compliance | 6.0 | Least-privilege rules, no client AI secrets, consent/analytics controls, store declarations proven |
| Testing, QA & CI | 6.1 | Green clean-checkout CI, coverage gates, goldens, integration/device tests, release candidate checklist |
| DevOps & release readiness | 5.3 | Signed Android/iOS release builds, staging/prod flavors, Firebase deploy pipeline, rollback plan |
| Documentation & truthfulness | 5.6 | One current source of truth, README claims verified, stale docs archived |
| Business, monetization & growth | 4.9 | Pricing/paywall decided, analytics funnel live, retention loops measured, support/feedback loop |
| Exercise/food content quality | 6.0 | Verified catalogs, unique media, dead-link checks, provenance/versioning for nutrition data |
| Observability & supportability | 6.7 | Crash/error dashboards, sync health metrics, user diagnostics export, alerting/runbooks |

**Weighted current overall: 6.6/10.**  
**Definition of done for “10/10 everywhere”: every row above must be proven with
runtime evidence, not just code presence.**

## What is genuinely strong

1. **Clear identity.** The “serious lifter telemetry HUD” positioning is coherent
   across `docs/ROADMAP.md`, the theme tokens, typography, and named flows
   (TODAY / TRAIN / FUEL / PROGRESS).
2. **Complete fitness loop.** Workout, nutrition, body progress, analytics,
   retention, tools, AI, sync, settings, onboarding, and profile all exist as
   real feature areas totalling ~78k LOC under `lib/features/`.
3. **Offline-first base.** Hive local storage, local drafts, cached catalogs,
   rest-timer persistence, and connectivity-aware sync triggers are appropriate
   for gym use.
4. **Recent data-link remediation is substantial.** Schema-v2 owner/link fields,
   `DataMigration`, flat Firestore layout, one sync engine/outbox, reactive Hive
   watch streams, `CompleteWorkoutUseCase`, and the recent per-user
   profile/diet scoping materially improved trust.
5. **Workout science logic improved.** `GetProgressionSuggestionUseCase` now
   avoids fabricated RPE, excludes warm-ups, and `DetectPersonalRecordUseCase`
   uses heaviest weight / reps-at-weight / capped estimated 1RM instead of raw
   volume only.
6. **Rest timer design is much better.** `RestTimerService` uses an absolute end
   timestamp, persists state, resyncs on resume, and schedules a local
   notification.
7. **Account deletion has real architecture.** `DeleteAccountUseCase`,
   `RemoteDataPurgerImpl`, `LocalDataWiper`, and the pending-wipe startup check
   show serious lifecycle thinking.
8. **CI intent is good.** `.github/workflows/ci.yml` runs code generation,
   `flutter analyze --no-fatal-infos --fatal-warnings`, tests with coverage,
   and a debug APK build.

## P0 findings — blockers to any 10/10 claim

### P0-1: Real auth and cloud sync are not the proven default

Evidence:
- `lib/features/auth/presentation/providers/auth_provider.dart` defines
  `kUseFirebaseAuth` from `USE_FIREBASE_AUTH` with `defaultValue: false`.
- The same file warns Google sign-in is still stubbed in the Firebase
  implementation; `firebase_auth_datasource.dart` has the google_sign_in 7.x
  TODO.
- `lib/features/sync/presentation/providers/sync_provider.dart` gates initial
  push with `enableInitialPush: kUseFirebaseAuth`.
- `lib/firebase_options.dart` still contains `YOUR_IOS_API_KEY`,
  `YOUR_MACOS_API_KEY`, and `YOUR_WINDOWS_API_KEY` placeholders.

Impact: the default build is a local/mock-auth product. Cloud sync, account
continuity, and cross-device claims cannot be marketed as production-proven
until staging Firebase auth/rules/indexes are deployed and two-device tests
pass.

10/10 fix:
- Create staging + production Firebase projects/flavors.
- Deploy `firestore.rules`, `firestore.indexes.json`, and `storage.rules`.
- Finish Google/Apple sign-in or remove those buttons until real.
- Define mock→Firebase UID migration or explicitly reset local data with user
  consent.
- Add two-account/two-device sync acceptance tests.

### P0-2: Active program storage is still a device singleton

Evidence:
- `HiveActiveProgramDataSource` uses one `current_active_program` key and one
  `archived_active_program` key.
- The recent profile work hides a foreign-owned active program, but another
  account can still overwrite the singleton.

Impact: profile display is honest now, but program preservation across accounts
is not 10/10.

10/10 fix:
- Scope keys as `current_active_program_<uid>` and
  `archived_active_program_<uid>`.
- Adopt the legacy singleton once only when no scoped program exists and the
  embedded owner matches/is legacy.
- Watch the scoped key and reload on auth changes.
- Add two-account storage tests like the diet-plan datasource test.

### P0-3: Clean-checkout verification is still the gate

Evidence:
- `*.g.dart` and `*.freezed.dart` are gitignored; the audited tree contains no
  generated files.
- CI correctly runs codegen before analyze/test/build, but this audit could not
  execute Flutter.

Impact: nobody can honestly rate reliability 10/10 until the current branch is
green from a clean checkout.

10/10 fix:
- Run and record: `flutter pub get`, `dart run build_runner build
  --delete-conflicting-outputs`, `flutter analyze`, `flutter test --coverage`,
  Android release build, iOS build on macOS.
- Add coverage and build artifacts to CI reporting.

### P0-4: AI can still fall back to client-side secrets

Evidence:
- `lib/core/config/app_config.dart` reads OpenAI/Gemini/NVIDIA keys from
  `--dart-define` or dotenv.
- `AIService` sends `Authorization: Bearer $_apiKey` directly to OpenAI.
- `GeminiAIService` supports `AI_PROXY_URL` with Firebase ID token, but falls
  back to `...generateContent?key=$_apiKey`.
- `AIRepositoryImpl.getContext()` still returns `''` with a TODO, despite
  broader AI context claims elsewhere.

Impact: production AI cost/security is not 10/10 while any direct-key path can
ship.

10/10 fix:
- In release builds, require proxy URL and fail closed if absent.
- Move all providers behind an authenticated backend proxy with per-user quotas,
  timeout, redaction, and cost logging.
- Keep deterministic training/nutrition math local; use AI for explanation.
- Add AI eval fixtures for unsafe or fabricated advice.

### P0-5: Localization files exist, but the app is not wired as localized

Evidence:
- ARB files exist for de/en/es/fr/ja/pt/zh with ~107 keys each.
- `AppLocalizations.of` appears once in `lib/`.
- `MainApp` builds `MaterialApp.router` without `locale`,
  `supportedLocales`, or `localizationsDelegates`.
- Bottom-nav labels and many UI strings are hardcoded English.

Impact: README multi-language claims are ahead of the runnable app.

10/10 fix:
- Wire generated delegates/locales into `MaterialApp.router`.
- Move user-visible strings to ARB by feature, starting with shell/auth/
  onboarding/workout/nutrition.
- Add locale widget tests and pseudo-localization overflow tests.

### P0-6: Release/store configuration is incomplete

Evidence:
- Android release signing search found only debug signing in
  `android/app/build.gradle.kts`; no `key.properties`/keystore wiring was found.
- iOS `Info.plist` grep found no `*UsageDescription` entries, while the app uses
  notifications and image picking; permissions copy must be verified.
- CI builds a debug APK only; no signed release, iOS, or store-upload job.

Impact: store readiness cannot be rated high until signed builds and platform
permission declarations are proven.

10/10 fix:
- Add release signing via CI secrets, iOS provisioning, privacy manifests/
  usage strings, store data-safety answers, and a release checklist.

## P1 findings — major quality gaps

### Security/privacy rules need least-privilege tightening

- Firestore `foods` and `exercises` allow any authenticated user to write.
  Catalog seeding should require an admin claim or a server-side script only.
- Storage profile images allow any authenticated user to read
  `users/{userId}/profile/{fileName}`. If avatars are public by design, document
  it; otherwise restrict to owner.
- Analytics sets user ID/properties in `AnalyticsService`; add consent/opt-out
  and verify no sensitive health details are sent as event parameters.

### Maintainability hotspots

- 17 files exceed 1,000 LOC. Largest: onboarding screen (2,420), food search
  (2,195), AI chat (1,963), nutrition screen (1,881), home screen (1,684),
  profile screen (1,330), active workout screen (1,313).
- Rough static signals: 311 `dynamic` usages, 108 `throw Exception`, 57
  `catch (_)`, 58 analyzer ignore comments, 144 `setState(` calls.
- Duplicate model concepts remain: two `UserProfile` classes and
  `FoodItem`/`FoodItemFull` split models.

10/10 direction: extract screen sections/view models, introduce typed failures
at repository boundaries, delete test-only production providers where safe, and
unify duplicate models behind migrations.

### Nutrition trust and friction

- No barcode scanner implementation was found; barcode exists in roadmap only.
- `foods_list.dart` references 204 Unsplash image URLs but only 9 unique images,
  which makes the catalog feel synthetic.
- Food conversion correctly avoids invented micros now, but unmeasured values can
  still be represented as zero in required fields; UI should display “unknown”
  rather than a false precise zero where relevant.

10/10 direction: barcode/Open Food Facts cache, catalog provenance, dedupe
media, verified portion units, adaptive TDEE from weight/intake trends.

### Accessibility/responsive debt

Rough signals: 13 `Semantics`/semantic-label hits, 6 `Tooltip`s, 2
`LayoutBuilder`s, 11 `MediaQuery` usages across a 91k-LOC UI. The dense HUD
style needs explicit contrast, touch-target, font-scaling, reduced-motion, and
screen-reader passes.

### Documentation sprawl and stale claims

There are 246 files under `docs/` plus 68 under `.kiro/`, many historical
“complete/fixed” reports. Meanwhile README still claims “production-ready”,
real-time sync, Firebase Realtime Database, GPT-4/DALL-E, 500+ exercises, and
1000+ foods without linking evidence. Documentation volume is high; canonical
accuracy is not.

10/10 direction: keep one current architecture/product source of truth, archive
historical reports, and make README claims testable.

### Product/business instrumentation is undecided

`AnalyticsService` defines many events, but the roadmap still lists
monetization as undecided and no billing/paywall code was found. A 10/10
product needs a decided business model, funnel dashboards, retention cohorts,
support feedback, and pricing experiments—or an explicit free/open-source goal.

## Area-by-area deep notes

### Product & onboarding

The 7-step onboarding is comprehensive (goal, body stats, place, frequency/
split, experience, budget, summary) and supports draft resume. That richness is
also friction. For 10/10, measure completion by step, allow “skip for now” into
a usable home state, and split the 2,420-line onboarding screen into step
widgets/controllers.

### Workout

This is the strongest product pillar: deterministic splits, exercise-definition
IDs, RPE/RIR input, PR logic, `CompleteWorkoutUseCase`, reactive history, and a
timestamp-based rest timer. Remaining gaps are device proof (background timer,
notifications, exact-alarm permissions), giant screen files, and per-user
active-program storage.

### Nutrition

Nutrition has targets, saved plans, meal swaps, custom foods, history, and a
large catalog. It will not feel 10/10 until logging is faster (barcode/recent/
favourites), catalog provenance is obvious, and targets adapt from real intake
and body-weight trend instead of mostly static formulas.

### Body/progress/analytics

Body entries now stream reactively and feed profile/latest weight. Analytics
includes strength progression and estimated 1RM. Test coverage is thin for body
(1 test file) relative to importance. HealthKit/Health Connect and richer
strength standards are the obvious next level after reliability.

### AI

AI is broad but should be narrowed. The winning pattern is: deterministic
engines compute progression/targets/deficiencies; AI explains, summarizes, and
converses. Proxy-only release mode, context minimization, and evals are
required before AI can be trusted as a headline feature.

### Auth/data/sync

The architecture after the database/sync remediation is coherent: Hive local
source of truth, one outbox/sync engine, flat Firestore collections, tombstones,
LWW, cursors, rules, and indexes. The missing part is operational proof under
real Firebase auth and the last singleton/identity migrations.

### UI/design/accessibility

The design system has tokens, typography, components, haptics, animations, and
a memorable identity. But ~797 `TextStyle(` constructions and 52 hardcoded
`Color(0x...)` hits in features suggest token discipline is incomplete. Add
golden tests for key screens in light/dark, large-text, and small-width modes.

### Performance

Local-first Hive and stream providers help. Risks are startup work (Firebase,
Crashlytics/Analytics, Hive boxes, pending wipe, migration, notifications,
state restore, Global AI init), large Dart-embedded catalogs, chart/list
rendering, and no recorded performance budgets. Add DevTools traces for cold
start, home scroll, food search, active workout set logging, and history with
1k workouts/10k sets.

### Testing/CI/release

The unit/widget base is meaningful, but coverage is uneven: workout 27 test
files and AI 18, while sync has 1, body 1, notifications 1, profile 2. There are
no golden tests. CI should add coverage gates, Firebase emulator/rules tests,
integration tests on an emulator/device, signed release builds, and dependency/
secret scanning.

## Roadmap to make every part 10/10

### Phase A — Production truth (P0)

1. Make clean-checkout CI green and record results.
2. Deploy staging Firebase; enable real auth; finish or remove social auth.
3. Scope active-program storage per user; prove account switching.
4. Proxy-only AI in release; remove direct-key production paths.
5. Wire localization delegates and correct README claims.
6. Add Android/iOS release signing and store permission declarations.

Exit criteria: signed staging build, two-account/two-device sync test, account
delete/export/restore drill, no client AI secrets, localized shell.

### Phase B — Core-loop excellence (P1)

1. Split the seven largest screens; introduce view-model/state files per screen.
2. Barcode + recent/favourite food fast paths; catalog QA/provenance.
3. Unify `UserProfile` and food models behind migrations.
4. Accessibility pass: semantics, contrast, 48dp targets, font scaling,
   reduced motion, landscape/tablet checks.
5. Performance budgets and traces; lazy-load catalogs; golden tests.

Exit criteria: workout set log <3 seconds median in usability test, food log
fast path <10 seconds, no >1,000-line presentation files except generated/data
catalogs, goldens for primary tabs.

### Phase C — Scale, retention, business (P2)

1. Health Connect/Apple Health read/write with explicit consent.
2. Adaptive TDEE/target recalibration from intake + weight trend.
3. Decide free vs freemium; implement billing only after sync/AI costs are
   controlled.
4. Beta cohort dashboards: activation, D1/D7/D30 retention, workout completion,
   nutrition adherence, sync failure rate, AI cost/user.
5. Support/runbooks: diagnostics export, sync health screen, crash triage.

Exit criteria: measurable retention, predictable unit economics, documented
support operations, and store-ready compliance evidence.

## First 10 implementation tickets

1. Run local Flutter verification and fix all analyze/test failures.
2. Add staging Firebase flavor + deploy rules/indexes; enable `USE_FIREBASE_AUTH`
   only there first.
3. Implement per-user active-program Hive keys + migration + tests.
4. Finish Google sign-in for google_sign_in 7.x or hide social buttons.
5. Add release-mode guard: AI direct API keys forbidden; proxy required.
6. Wire `AppLocalizations` delegates/locales into `MaterialApp.router`.
7. Restrict Firestore catalog writes to admin/service accounts; review storage
   profile-image read rule.
8. Add Android release signing and iOS usage-description/privacy review.
9. Correct README production/sync/AI/catalog claims and archive stale docs.
10. Add golden tests for Today/Train/Fuel/Progress/Profile in dark/light and
    large-text modes.

## Phase A implementation log — tranche 1 (2026-10-24)

Implemented in the working tree after the audit:

- **Per-user active-program storage (P0-2):** `HiveActiveProgramDataSource`
  now scopes current/archived programs by resolved owner
  (`current_active_program_<uid>`, `archived_active_program_<uid>`), adopts a
  legacy singleton once only when no scoped key exists and the stored model is
  legacy/unowned or owned by the requester, and watches the scoped key. The
  repository, stream provider, and `SyncService` program initial-push/pull now
  pass the auth/sync user id. Added
  `hive_active_program_datasource_test.dart` for account isolation, scoped
  archive/restore, and one-time legacy adoption.
- **Localization wiring (P0-5, first step):** `MainApp` now passes the saved
  `languageProvider` locale plus `AppLocalizations.supportedLocales` and
  `AppLocalizations.localizationsDelegates` to `MaterialApp.router`. Added a
  localization wiring test. Full UI string extraction remains Phase B.
- **AI direct-key fail-closed policy (P0-4):** `AppConfig` returns direct
  OpenAI/Gemini/NVIDIA keys only in debug builds (and only when
  `ALLOW_DIRECT_AI_KEYS` is not disabled). `GeminiAIService` and the direct
  OpenAI `AIService` reject direct keys with `DIRECT_API_KEY_DISABLED` when
  policy is off; profile/release must use `AI_PROXY_URL`. Added disabled-policy
  tests for both services.
- **Firebase Google sign-in code path:** `FirebaseAuthDataSourceImpl` now uses
  Firebase popup auth on web and the pinned `google_sign_in` 6.x credential
  flow on mobile instead of throwing “temporarily disabled”. Platform OAuth
  configuration and real-device proof are still required before enabling.
- **Rules tightening:** shared `foods`/`exercises` Firestore writes now require
  an `admin: true` custom claim; profile-image Storage reads are owner-only.
- **Release config:** Android release builds use `android/key.properties` when
  present (with `key.properties.example`); debug signing remains only as a
  clearly-commented local fallback. iOS display name is now IronFlow and the
  photo-library purpose string was added for progress photos.
- **README truthfulness:** removed the unsupported production-ready,
  real-time/RTDB sync, 500+/1000+ catalog, GPT-4/DALL-E, and blanket
  multi-language claims and replaced them with the current gated/local-first
  state.

Still not done in this tranche: local Flutter SDK verification; staging
Firebase project/flavors and rule/index deployment; mock→Firebase UID data
migration/default flip; signed store builds and device proof; full string
localization/accessibility pass; golden tests; stale-doc archival. Ratings do
not move to 10/10 until those are proven.

## Phase A implementation log — tranche 2 (2026-10-24)

Implemented in the working tree after tranche 1:

- **No exact-alarm special access:** workout/meal/rest notifications now use
  `AndroidScheduleMode.inexactAllowWhileIdle`; the reminder notifier no
  longer requests exact-alarm access, and `SCHEDULE_EXACT_ALARM` /
  `USE_EXACT_ALARM` were removed from the Android manifest. The persisted
  absolute rest-timer end remains the source of truth, so an inexact
  notification does not corrupt timer state.
- **Firebase options fail fast:** fake iOS/macOS/Windows `YOUR_*` options were
  removed. Web/Android keep their real generated values; unconfigured
  platforms now throw an `UnsupportedError` telling the developer to run
  `flutterfire configure` instead of initializing Firebase with dummy IDs.
- **Telemetry opt-outs are honored:** the Privacy screen previously saved
  Analytics/Crashlytics booleans that startup ignored. New
  `TelemetryPreferences` applies stored opt-outs immediately after Firebase
  initialization and whenever the Privacy settings save; debug builds never
  collect. Added unit tests for defaults, stored opt-outs, setters, and the
  pure debug/preference policy.
- **iOS localization bundle metadata:** `CFBundleLocalizations` now declares
  en/es/fr/de/pt/ja/zh, matching the app's generated Flutter localizations.
- **Consent-safe legacy OpenAI context:** `AIRepositoryImpl` no longer claims
  automatic access to user data and no longer carries a context TODO. It
  accepts an optional caller-supplied context builder; without one,
  `getContext()` returns empty and the system prompt forbids inventing
  user-specific facts. The default provider does not inject
  `BuildAIContextUseCase`, so no personal context is gathered implicitly.
- **Hardened CI definition:** CI now runs on master, `arena/**`, pull
  requests, and manual dispatch; uploads coverage; compiles an Android
  release APK (using repository signing secrets when present, local
  debug-signing fallback otherwise); and includes a macOS no-codesign iOS
  debug compile job. Jobs have read-only permissions, concurrency, and
  timeouts. This is a stronger gate definition, not yet a green run.
- **Operator runbook:** `docs/deployment/PHASE_A_STAGING_RUNBOOK.md` now
  sequences the remaining non-code gates: local Flutter verification,
  staging Firebase/FlutterFire, Auth providers, rules/index deployment,
  admin catalog seeding, AI proxy, Android/iOS signing, explicit
  mock→Firebase migration decision, two-account/two-device sync, lifecycle
  checks, social sign-in, notifications/photos, and rollback.

Still not done after tranche 2: any local/CI Flutter run; Firebase project
creation/rule deployment; OAuth fingerprints/client IDs; signing material;
mock→Firebase UID migration or auth-default flip; device proof; full string
localization/accessibility/golden-test pass. The next rating movement depends
on executing the runbook, not on more static structure.

## Final rating

IronFlow at audit time: **6.6/10 overall** — a powerful, ambitious beta with
strong bones.  
After Phase A tranche 1 (static checks only): **~6.9/10**, mainly from closing
active-program leakage, localization wiring, AI key fail-closed policy, rules,
and release-config gaps.  
After Phase A tranche 2 (static checks only): **~7.0/10**, mainly from
honoring telemetry opt-outs, removing exact-alarm special access, failing fast
on fake Firebase platform options, safer legacy AI context, and a harder CI /
staging-runbook definition.  
IronFlow after the rest of Phase A is deployed/proven: **~8/10** — credible
production candidate.  
IronFlow after Phases B–C with measured beta evidence: **10/10 is achievable**.
