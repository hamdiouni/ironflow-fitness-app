# ADR-009: Firebase Security Rules Unit Testing Stack

- **Status**: Accepted (Wave 1.1)
- **Date**: 2026-11-16
- **Wave**: Wave 1.1

## 1. Problem
`firestore.rules` and `storage.rules` enforce per-owner isolation, bounded document sizes, tombstones, non-writable client `users/{uid}/ai_usage`, and JSON backup upload limits (`<= 10 MB`, `contentType == 'application/json'`). Relying solely on static regex tests in Dart cannot evaluate live Firestore/Storage CEL expressions or `request.resource` semantics (such as `delete` having `request.resource == null`).

## 2. Options Considered

| Option | Description | Pros | Cons / Cost |
| :--- | :--- | :--- | :--- |
| **Option A: `@firebase/rules-unit-testing` + `firebase` JS SDK (`devDependencies` in `functions/`)** | Run Node `node:test` specs (`test/rules/firebase_rules.emulator.spec.mjs`) against the local Firebase Firestore & Storage Emulators (`assertSucceeds` / `assertFails`). | Evaluates exact production CEL rules locally & in CI; zero client bundle impact (`devDependencies` only); matches official Firebase rules testing tooling. | Requires Java JRE & Firebase Emulator Suite (`firebase-tools`) to execute tests live. |
| **Option B: Live staging Firebase project integration tests** | Run Dart/Node tests against a hosted dev/staging Firebase project. | Exercises real managed backend. | Requires network & credentials in CI; slower, non-atomic cleanup; cannot test offline in sandboxed dev. |

## 3. Recommendation
Adopt **Option A**: declare `@firebase/rules-unit-testing` (`^4.0.0`, resolved `4.0.1`) and `firebase` (`^11.0.0`, resolved `11.10.0`) as `devDependencies` in `functions/package.json`.

- **Verified npm Registry Metadata**:
  - `@firebase/rules-unit-testing@4.0.1`: License `Apache-2.0`, released `2024-11-14T15:17:25.002Z`, unpacked size `184,487` bytes (~184 KB; aligns with `peerDependencies: { firebase: "^11.0.0" }`, whereas `@firebase/rules-unit-testing@6.0.0` released `2026-11-11` requires `firebase: "^13.0.0"`).
  - `firebase@11.10.0`: License `Apache-2.0`, released `2025-06-30T16:49:30.491Z`.
- **App Binary Impact**: **0 KB** (Node `devDependencies` inside `functions/` only; never bundled into Android/Web/iOS builds).
- **Monetary Cost**: **\$0** (local and GitHub Actions emulator execution is free).
- **Risks**: Emulator execution requires `firebase-tools` and Java 17+ (`java.exe`). Without an emulator daemon running, emulator rules specs remain `NOT VERIFIED` locally while still tracked in source control for CI/local emulator runs.
- **Rollback**: Remove `@firebase/rules-unit-testing` and `firebase` from `functions/package.json` `devDependencies` and regenerate `functions/package-lock.json` via `npm install`.
