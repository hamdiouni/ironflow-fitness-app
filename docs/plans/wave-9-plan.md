# Wave 9 — Legal, Docs, Client Pack, Acceptance (Plan & Step 0)

Branch: `feat/prod-v2-wave-9` (branched from `master` at `36f4011`, backed up by tag `backup/pre-prod-v2-wave-9`).

## Step 0 — What Exists Today & Scope

| Component | What exists today (file evidence) | Required Wave 9 Action |
| :--- | :--- | :--- |
| **9.1 License report & In-app attribution** | `docs/CLIENT_PACK/DEPENDENCY_LICENSES.csv` (227 packages, 100% permissive). `showLicensePage` in `privacy_settings_screen.dart:512`. Fonts registered in `main.dart:52` (OFL Inter & Space Grotesk). | Verify all dependencies; update `SettingsAboutSection` and `PrivacySettingsScreen` with version stamp (`2.0.0+9`), application title ("IronFlow"), and an in-app Data Attributions & Open Database notice (ODbL Open Food Facts, USDA, OFL fonts). |
| **9.2 Policies & Store Answers** | `docs/legal/PRIVACY_POLICY.md`, `TERMS_OF_SERVICE.md`, `FITNESS_AND_MEDICAL_DISCLAIMER.md`, `docs/STORE_DATA_DISCLOSURE.md`. | Review and update for Release 2.0.0 (Waves 1-8 additions: AI proxy with responsible safety `BLOCK_MEDIUM_AND_ABOVE`, ephemeral meal photo estimates under ADR-003, lock-screen chronometer countdown under ADR-004 without exact alarm permissions). |
| **9.3 Client Pack & Runbooks** | `docs/CLIENT_PACK/` contains `README.md`, `ARCHITECTURE_OVERVIEW.md`, `DEPLOYMENT_RUNBOOK.md`, `KEY_ROTATION_AND_CREDENTIALS.md`, `STORE_RELEASE_CHECKLIST.md`. | Update for Release 2.0.0+9 with full architecture summary, deployment runbooks, zero-trust secrets guide, and release checklist. |
| **9.4 File Ledger Normalization** | `docs/audit/FILE_LEDGER.csv` has 791 rows; 19 rows have mismatched column count. | Normalize schema so 100% of files have valid `verdict=KEEP` or documented reasons with 9 columns. |
| **9.5 Final Acceptance Gates** | Analyzer, unit tests, coverage gate, gitleaks, Cloud Functions tests, release build. | Run all verification gates end-to-end; ensure 0 errors/warnings, 0 test failures, 0 skipped, coverage ratchet passed, 0 leaks, release build succeeds. |

## Claims Checked

| Claim | Result |
| :--- | :--- |
| "All pub dependencies have permissive licenses" | **TRUE** — 227 dependencies audited in `docs/CLIENT_PACK/DEPENDENCY_LICENSES.csv`; 100% MIT, BSD, Apache 2.0, or ISC. Zero GPL contamination. |
| "App Check and AI Proxy prevent secret leaks" | **TRUE** — Verified in Cloud Functions tests and zero API keys in client code. |
| "Lock screen countdown requires exact alarm permission" | **FALSE** — ADR-004 proved native system chronometer (`usesChronometer: true`, `chronometerCountDown: true`) runs completely on-device without high-risk `SCHEDULE_EXACT_ALARM`. |
