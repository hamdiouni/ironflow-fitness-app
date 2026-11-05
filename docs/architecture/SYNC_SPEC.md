# IronFlow Multi-Device Cloud Sync Specification (`SYNC_SPEC.md`)

## 1. Architecture Overview
IronFlow uses an **offline-first, single-outbox** synchronization architecture implemented in [`SyncService`](../../lib/features/sync/domain/services/sync_service.dart) and [`HiveSyncQueueDataSource`](../../lib/features/sync/data/datasources/hive_sync_queue_datasource.dart).

- **Local Source of Truth**: Encrypted Hive boxes (`HiveAesCipher` via `HiveEncryptionService`) hold all domain records (`workouts`, `active_program`, `nutrition_meals`, `nutrition_targets`, `body_entries`) and the persistent sync outbox (`sync_queue`).
- **Cloud Transport**: Cloud Firestore (`FirestoreSyncDataSource`) stores per-user documents in top-level collections (`/workouts/{id}`, `/programs/{id}`, `/nutrition/{id}`, `/body_progress/{id}`) and `/users/{uid}/settings/nutrition_targets`.
- **Feature Flag**: Cloud sync can be gated at compile time via `--dart-define=ENABLE_CLOUD_SYNC=false` (`SyncService.kDefaultCloudSyncEnabled`) or toggled at runtime via `SyncService.setSyncEnabled(bool)`. When disabled, local writes and outbox queueing continue normally without network calls.

---

## 2. Outbox Queueing, Ordering, & Coalescing
1. **FIFO Outbox**: Every local repository write (`create`, `update`, `delete`) appends a `SyncAction` to the `sync_queue` box with `timestamp = DateTime.now()` and `status = SyncStatus.pending`.
2. **Idempotent Coalescing on Push**:
   - Each `create`/`update` `SyncAction` stores the full serialized model JSON snapshot (`toJson()`), and each `delete` stores `{id, userId}`.
   - During `_pushLocalChanges(userId)`, pending/failed actions owned by `userId` with `retryCount < 3` are scanned in FIFO order (`timestamp ASC`) and coalesced by `(dataType, dataId)`.
   - Superseded intermediate actions for the same `(dataType, dataId)` are marked `SyncStatus.completed` prior to network execution, so only the final effective state (latest `update` or final `delete` tombstone) is transmitted to Firestore.
3. **Multi-Account Isolation on Shared Devices**:
   - `_pushLocalChanges(userId)` inspects `action.data['userId']` and skips actions belonging to any other `userId`, leaving them queued until their owner signs in.

---

## 3. Retry Policy & Partial Failure Isolation
1. **Per-Action Retry Cap (`retryCount < 3`)**:
   - If a Firestore write fails during `_pushLocalChanges`, the action is marked `SyncStatus.failed` and its `retryCount` is incremented by `1`.
   - Failed actions are automatically retried on subsequent `syncAll()` runs until `retryCount >= 3`, at which point they are skipped until explicit user/system invocation of `retryFailedActions(userId)`.
2. **Collection Leg Isolation (`_guardLeg`)**:
   - During `_pullCloudChanges(userId)`, each collection (`workouts`, `program`, `meals`, `nutrition targets`, `body entries`) is pulled inside an isolated `_guardLeg` block.
   - If pulling one collection fails, other collections still pull and advance their cursors normally, and the failing collection's cursor is **not** advanced so its changes will be fetched on the next sync.

---

## 4. Conflict Resolution & Multi-Device Convergence Rules
IronFlow resolves concurrent edits across devices using **Protected Deterministic Last-Write-Wins (LWW)**:

| Scenario | Rule | Outcome |
|---|---|---|
| **Cloud strictly newer** (`cloudClock > effectiveLocalClock`) | Cloud record wins | Local Hive record is overwritten with `cloud` |
| **Local strictly newer** (`cloudClock < effectiveLocalClock`) | Local record wins | Cloud snapshot is ignored; local state is preserved |
| **Unpushed local edit exists** (`unpushedClock != null` and `cloudClock <= effectiveLocalClock`) | Unpushed local edit protected | A pending or failed local edit in `sync_queue` is never clobbered by a stale or equal-timestamp pull |
| **Equal timestamp tie** (`cloudClock == effectiveLocalClock`, no unpushed edit) | Canonical JSON tie-breaker | Keys of both records' JSON maps are sorted lexicographically and compared (`canonicalCloud.compareTo(canonicalLocal) > 0`), guaranteeing that two devices with millisecond-identical timestamps converge to the exact same payload |
| **Tombstone deletion** (`cloud.deletedAt != null`) | Tombstone LWW | `tombstoneClock = deletedAt ?? updatedAt`. If `effectiveLocalClock == null` or `effectiveLocalClock <= tombstoneClock`, the local record is deleted; if local was updated strictly after `tombstoneClock`, the local edit is preserved |

### Clock Extraction Hierarchy
- **Workouts**: `updatedAt ?? date ?? epoch`
- **Active Program**: `updatedAt ?? epoch`
- **Meals**: `updatedAt ?? timestamp ?? epoch`
- **Body Progress**: `updatedAt ?? date ?? epoch`
- **Nutrition Targets**: `updatedAt ?? epoch`

---

## 5. Incremental Pull Cursors & Clock-Skew Safety Margin
- Each collection maintains a per-user, per-device cursor in `app_settings` (`sync_cursor_<userId>_<collection>`).
- Queries filter on `syncedAt > cursor` (backed by composite indexes `(userId ASC, syncedAt ASC)` in `firestore.indexes.json`).
- After a successful collection pull, the cursor is set to `DateTime.now().subtract(Duration(minutes: 5))` (`_cursorSafetyMargin`). The 5-minute overlap ensures minor client/server clock skew never skips a document, while LWW idempotency makes re-pulling documents within the 5-minute window a no-op.

