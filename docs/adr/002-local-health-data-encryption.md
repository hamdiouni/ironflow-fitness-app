# ADR-002: Local Health & Personal Data Encryption at Rest

- **Status**: Proposed (Awaiting Owner Approval before Wave 1.7)
- **Date**: 2026-11-05
- **Wave**: Wave 1.7

## 1. Problem
All 24 files opening Hive boxes (`workouts`, `nutrition`, `body_progress`, `user_profile`, `ai_chat`, `auth_session`) currently store records in plaintext on disk (`hive_encryption_uses = []`). Health and fitness records must be encrypted at rest on mobile devices.

## 2. Options Considered

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Option A: Built-in `HiveAesCipher` + `flutter_secure_storage` Key** | Generate a 256-bit random key via `Hive.generateSecureKey()` on first launch, store it in `FlutterSecureStorage` (Android Keystore / iOS Keychain), and pass `encryptionCipher: HiveAesCipher(key)` to `Hive.openBox()`. | **0 new dependencies** (`hive` and `flutter_secure_storage` are already installed); AES-256 CBC encryption built into Hive; < 3ms overhead per box open. | On Web, `flutter_secure_storage_web` uses WebCrypto + `localStorage`/`IndexedDB` wrapped keys (browser storage cannot provide hardware enclave isolation against XSS). |
| **Option B: Migrate all local storage to SQLCipher (`sqflite_sqlcipher` / `drift` + SQLCipher)** | Replace Hive entirely with encrypted SQLite. | Full relational ACID + full-database page encryption. | High migration risk across 63 Hive files; adds ~3–4 MB native binary size per ABI. |

## 3. Recommendation
- **Option A (`HiveAesCipher` with key in `FlutterSecureStorage`)** for user/health boxes (`workouts`, `nutrition`, `body_progress`, `user_profile`, `ai_chat`, `auth_session`, `sync_queue`).
- Keep non-sensitive app preferences (`theme`, `language`, `units`) unencrypted so theme/locale loads instantaneously before async keystore reads.
- Include a tested one-time migration (`HiveEncryptionMigrator`) that detects an unencrypted legacy box, reads its entries, deletes the plaintext box file, and re-writes them into the `HiveAesCipher`-encrypted box.
- **New Runtime Dependencies**: **0** (uses existing `hive: ^2.2.3` and `flutter_secure_storage` upgraded to `^11.2.0` MIT/BSD).
- **Size Impact**: **0 KB**.
- **Rollback**: Migration keeps a temporary `.bak` until verified; feature flag in `HiveManager`.
