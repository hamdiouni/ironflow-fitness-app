# Wave 0.7 — Prioritized Production Readiness Proposal & Release Plan

## 1. Work Item Ranking (P0 / P1 / P2)

### P0 — Blocks Selling (Security, Data Integrity, Legal & Broken Rules — Waves 1, 2, 7)
1. **W1.1 Secrets & History Hygiene**: Confirm cloud key revocation; add `gitleaks` in CI + pre-commit hook; verify 0 keys in release APK and web output; delete obsolete `scripts/remove_secrets.sh` and `SECURITY_FIX_*.md` (ASK). *(Effort: 2h | Risk: Low)*
2. **W1.2 Authenticated AI Proxy & `AiTransport`**: Deploy server-side AI proxy (`functions/` or Cloud Run per ADR-001) with Firebase Auth JWT + App Check verification, durable Firestore per-user daily quotas, input size caps, model allow-list, and `AiTransport` client abstraction. *(Effort: 10h | Risk: Medium)*
3. **W1.3 Fix `firestore.rules` & `storage.rules` P0 Bugs**:
   - Fix cross-user `update` vulnerability in `firestore.rules` (`allow update: if readsOwnDoc() && writesOwnDoc() && isValidPayload()`).
   - Fix broken `delete` in `storage.rules` (`request.resource == null` on delete).
   - Add Firebase Emulator rules test suite. *(Effort: 6h | Risk: Low)*
4. **W1.4 Firebase App Check**: Add `firebase_app_check` (Play Integrity, DeviceCheck/App Attest, reCAPTCHA Enterprise) in monitor mode first, then enforce. *(Effort: 4h | Risk: Medium)*
5. **W1.5 Auth & Account Deletion Hardening**:
   - Flip `kUseFirebaseAuth` default so release/staging builds never use `MockAuthDataSourceImpl`.
   - Fix `RemoteDataPurgerImpl` so it recurses into `listAll().prefixes` (`profile/`, `workouts/`, `progress/`) and fails closed instead of swallowing exceptions. *(Effort: 6h | Risk: Medium)*
6. **W1.7 Local Health Data Encryption at Rest**: Encrypt sensitive Hive boxes (`workouts`, `nutrition`, `body_progress`, `user_profile`, `ai_chat`, `auth_session`, `sync_queue`) using `HiveAesCipher` with key in `FlutterSecureStorage` + one-time plaintext-to-encrypted migration (ADR-002). *(Effort: 8h | Risk: Medium)*
7. **W1.8 Privacy Plumbing & Opt-In Consent**: Flip `TelemetryPreferences` (`analytics_enabled`, `crash_reporting_enabled`) default from `true` (opt-out) to `false` (explicit opt-in consent); enforce AI personalization consent guard. *(Effort: 4h | Risk: Low)*
8. **W7.1–W7.2 Legal & Attribution Pack**: Bundle `OFL.txt` font licenses, wire in-app Open-Source & Asset Attribution page, add Medical & Fitness Disclaimer, and replace/attribute external catalog media URLs. *(Effort: 8h | Risk: Low)*

### P1 — Quality, CI, Architecture, Performance & Platforms (Waves 2, 3, 5)
1. **W2.1 Characterization Tests & Coverage Gates**: Raise real `lcov.info` line coverage from **53.15%** to `>= 65%` overall (`domain >= 80%`, `data >= 70%`), targeting `sync` (currently 31.5%), `settings` (36.8%), `auth` (38.8%), and `analytics` (43.3%). *(Effort: 16h | Risk: Low)*
2. **W2.2–W2.3 E2E Integration Journeys & Component Goldens**: 7 `integration_test` journeys + light/dark component goldens with bundled fonts. *(Effort: 12h | Risk: Low)*
3. **W2.4–W2.7 CI, Flavors & Observability**: Fix the 5 analyzer warnings breaking CI; add `gitleaks`, coverage drop gate, and `flutter build web` to `.github/workflows/ci.yml`; configure `dev`/`staging`/`prod` flavors; add remote feature flags & kill switch (ADR-005). *(Effort: 14h | Risk: Medium)*
4. **W3.1–W3.2 Toolchain Upgrades & Riverpod `Notifier` Migration**: Staged package upgrades (`flutter_secure_storage 11.x`, patch/minor updates) + migrate all 30 legacy `StateNotifier`s to plain `Notifier`/`AsyncNotifier` (ADR-003). *(Effort: 18h | Risk: Medium)*
5. **W3.3–W3.7 Giant File Decomposition, Catalog Indexing & Hygiene**:
   - Split all 20 non-generated files > 800 LOC into thin orchestrators and modular widgets.
   - Deduplicate `ExerciseDatabase` (fixing the 27 duplicate IDs and 20 duplicate names) and move static food/exercise catalogs to lazy indexed JSON assets (ADR-004).
   - Remove `/design-preview` and `/design-gallery` from production builds; replace all 50 `.withOpacity()` calls and 79 raw hex colors. *(Effort: 32h | Risk: Medium)*
6. **W5.1–W5.6 Performance, Platforms, Accessibility & i18n**: Enable Android R8 shrinking + ABI splits (cutting 72–97 MB APK to ~22–28 MB per ABI); remove cold-start notification permission prompt from `main.dart`; add `ios/Runner/PrivacyInfo.xcprivacy` and `NSCameraUsageDescription`; complete semantics, 2.0x text scaling, and l10n/RTL extraction. *(Effort: 24h | Risk: Medium)*

### P2 — Differentiators: Body Map, Gym-First Experience & Approved Add-ons (Waves 4, 6)
1. **W4.1–W4.2 Reference Teardown & Gym-First Design Lab Previews (STOP for approval)**: Public-info teardown + 2–3 gym-first directions vs Direction 4 baseline in isolated Design Lab. *(Effort: 12h | Risk: Low)*
2. **W4.3–W4.5 Canonical 18-Region Muscle Model, Incremental Summaries & Recovery Engine**: Approved exercise-to-muscle weights config, per-user rebuildable muscle summaries updated on workout save/edit/delete, and documented recovery estimator (`Fresh`, `Recovering`, `Needs rest` + "Mark sore"). *(Effort: 16h | Risk: Medium)*
3. **W4.6–W4.9 Interactive 2D Body Map UI, Integration & Proof**: Pre-parsed vector `CustomPainter` with path hit-testing (ADR-006), accessible list alternative, muscle detail bottom sheet, Today/Summary/Plan integration, and `TimelineSummary` performance verification. *(Effort: 20h | Risk: Medium)*
4. **W6 Approved Technology Additions**: Normalized AI question cache + 25-prompt evaluation rubric + cost tracking, plus any Owner-approved Wave 6 candidates. *(Effort: 8–20h | Risk: Low)*

---

## 2. Staged Release Plan

| Release | Waves Included | Target Outcome | Estimated Effort | Overall Risk |
| :--- | :--- | :--- | :---: | :---: |
| **v1.4 — Secure, Compliant & CI-Gated** | **Wave 1 + Wave 2** | Zero secrets in repo/history/builds; fixed Firestore & Storage rules; real Firebase Auth in release; encrypted Hive health boxes; opt-in telemetry; authenticated AI proxy; 65%+ coverage gate & green CI with flavors. | ~66 hours | Medium |
| **v1.5 — Fast, Clean & Multi-Platform** | **Wave 3 + Wave 5** | 30 `StateNotifier`s migrated to `Notifier`; 20 giant files decomposed; deduplicated & indexed food/exercise catalogs; 0 analyzer warnings/infos; R8-shrunk Android builds (< 28 MB per ABI); iOS `PrivacyInfo.xcprivacy`; full a11y & i18n. | ~74 hours | Medium |
| **v2.0 — Sellable Platform + Body Map** | **Wave 4 + Wave 6 + Wave 7** | Interactive 18-region Body Map with recovery estimates & muscle history; gym-first UX polish; AI evaluation & caching; complete legal/attribution pack, runbooks, and `docs/CLIENT_PACK/`. | ~68 hours | Low–Medium |

---

## 3. Owner Questions & Approvals Needed Before Wave 1

Please reply with your choices on the following so we can lock in Wave 1:

1. **Owner Business & Platform Settings**:
   - **How you will sell**: (a) One client takes the code, (b) White-label for many clients, or (c) Hosted service (SaaS) for many users?
   - **Target platforms**: Android + Web only, or Android + iOS + Web?
   - **Backend choice for AI Proxy (ADR-001)**: (a) Firebase Cloud Functions 2nd Gen / Cloud Run (requires Firebase Blaze pay-as-you-go plan; free tier covers initial usage, ~$0.01–$0.05 per 100 AI chats), (b) Your own custom API server, or (c) Keep AI offline-heuristic-only in release until a client funds the cloud project?
   - **Languages & RTL needed**: Keep the current 7 languages (`en`, `de`, `es`, `fr`, `ja`, `pt`, `zh`), or add Arabic (`ar`) / Hebrew (`he`) RTL?
   - **Money model & monthly cloud budget**: Free / Paid / Subscription / Client pays? Monthly cloud budget cap ($0 / $10 / $50)?
2. **Confirm Key Revocation**:
   - Please confirm that the historical keys scrubbed in Wave 0.1 (`GOOGLE_KEY_1` and `NVIDIA_KEY_2`) and the previously shared Gemini key have been revoked in Google Cloud Console and NVIDIA NGC.
3. **Approve Wave 1 Decision Records & ASK Items**:
   - **ADR-001 (AI Proxy)**, **ADR-002 (`HiveAesCipher` encryption at rest)**, and adding **`firebase_app_check`** (1 new runtime package in Wave 1.4).
   - **ASK — Delete obsolete security incident files in Wave 1.1**: May we delete `scripts/remove_secrets.sh`, `SECURITY_FIX_GUIDE.md`, and `SECURITY_FIX_SUMMARY.md` once CI secret scanning is wired?
