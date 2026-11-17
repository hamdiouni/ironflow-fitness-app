import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/hive_json_utils.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_alias_resolver.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';

/// One-time local schema migrations for Hive data.
///
/// Schema v2 (Phase 1, DATABASE_AND_SYNC_AUDIT) added identity/link fields
/// to the stored records. All new fields are nullable in the models, so
/// pre-v2 JSON still loads — this migration goes one step further and
/// *backfills* what can be derived, so historical data becomes fully
/// linked instead of merely loadable:
///
/// - `userId` ← the currently stored auth session (single-user devices
///   make this unambiguous for local history)
/// - `updatedAt` ← the record's own date (`date` / `timestamp`)
/// - `exerciseDefinitionId` ← catalog lookup by exercise name
///
/// Historical `Workout.programId`/`programDayIndex` cannot be recovered
/// reliably and stay null; new workouts stamp them in
/// StartWorkoutUseCase.
///
/// The migration operates on the raw stored Maps (never the typed models),
/// is idempotent, writes back only records it actually changed, and never
/// throws — a failure leaves the stored schema version untouched so the
/// migration retries on the next launch. Runs once, gated by
/// `schema_version` in the `app_settings` box.
///
/// Schema v3 (Phase 2): the `sync_queue` box historically held TWO
/// incompatible schemas (`SyncAction` and the retired `SyncOperation`).
/// With the legacy engine deleted, v3 drops any entry that is not a
/// `SyncAction` (missing `dataType`/`dataId`) so the outbox has exactly
/// one schema. Legacy entries were never actionable by any live code
/// path, so dropping them loses nothing syncable.
///
/// Schema v4 (Wave 3): separates encrypted `custom_foods` out of the
/// shared `foods` catalog cache box and normalizes case/whitespace on
/// account-scoped keys (`custom_foods`, `user_profile`, `diet_plan`) using
/// [RecordOwnershipRules.storageScope].
class DataMigration {
  static const int currentSchemaVersion = 4;
  static const int currentAliasMigrationVersion = 1;
  static const String _versionKey = 'schema_version';
  static const String _aliasMigrationKey = 'exercise_alias_migration_version';

  static const String _appSettingsBox = HiveManager.appSettingsBox;
  static const String _workoutsBox = HiveManager.workoutsBox;
  static const String _mealsBox = HiveManager.mealsBox;
  static const String _bodyEntriesBox = HiveManager.bodyEntriesBox;
  static const String _activeProgramBox = HiveManager.activeProgramBox;
  static const String _syncQueueBox = HiveManager.syncQueueBox;
  static const String _foodsBox = HiveManager.foodsBox;
  static const String _userProfileBox = HiveManager.userProfileBox;
  static const String _dietPlanBox = HiveManager.dietPlanBox;

  /// Runs pending migrations. [currentUserId] is the signed-in user's id
  /// (from the stored auth session); when null, the userId backfill is
  /// skipped (rows are stamped on their next save instead) while the
  /// remaining backfills still run.
  static Future<void> runIfNeeded({String? currentUserId}) async {
    try {
      if (!Hive.isBoxOpen(_appSettingsBox)) {
        AppLogger.debug(
          '⚠️ [Migration] $_appSettingsBox not open; skipping migration',
        );
        return;
      }
      final settings = await HiveManager.ensureAppSettingsBox();
      final stored =
          int.tryParse(settings.get(_versionKey) ?? '') ?? 1;
      if (stored < currentSchemaVersion) {
        AppLogger.debug(
          '🔄 [Migration] Upgrading local schema v$stored → '
          'v$currentSchemaVersion',
        );

        if (stored < 2) {
          await _migrateWorkouts(currentUserId);
          await _migrateMeals(currentUserId);
          await _migrateBodyEntries(currentUserId);
          await _migrateActivePrograms(currentUserId);
        }
        if (stored < 3) {
          await _purgeLegacySyncQueueEntries();
        }
        if (stored < 4) {
          await _migrateV4CustomFoodsAndStorageScopes();
        }

        await settings.put(_versionKey, '$currentSchemaVersion');
        AppLogger.debug('✅ [Migration] Local schema is now '
            'v$currentSchemaVersion');
      }

      final aliasVersion =
          int.tryParse(settings.get(_aliasMigrationKey) ?? '') ?? 0;
      if (aliasVersion < currentAliasMigrationVersion) {
        await migrateCanonicalExerciseAliases();
        await settings.put(_aliasMigrationKey, '$currentAliasMigrationVersion');
      }
    } catch (e, st) {
      // Never block startup. The version stamp is only written after a
      // fully successful run, so a failed migration retries next launch.
      AppLogger.debug('❌ [Migration] Failed (will retry next launch): $e\n$st');
    }
  }

  // ---------------------------------------------------------------------------
  // Per-box migrations
  // ---------------------------------------------------------------------------

  static Future<void> _migrateWorkouts(String? userId) async {
    final box = await _ensureMapBox(_workoutsBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = deepCastMap(raw);
      var dirty = false;

      dirty |= _setIfAbsent(record, 'userId', userId);
      if (record['updatedAt'] == null && record['date'] is String) {
        record['updatedAt'] = record['date'];
        dirty = true;
      }
      final exercises = record['exercises'];
      if (exercises is List) {
        for (final exercise in exercises) {
          if (exercise is Map) {
            dirty |= _backfillDefinitionId(exercise, nameKey: 'name');
          }
        }
      }
      if (dirty) {
        await box.put(key, record);
        changed++;
      }
    }
    AppLogger.debug('📊 [Migration] workouts: $changed records backfilled');
  }

  static Future<void> _migrateMeals(String? userId) async {
    final box = await _ensureMapBox(_mealsBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = deepCastMap(raw);
      var dirty = false;

      dirty |= _setIfAbsent(record, 'userId', userId);
      if (record['updatedAt'] == null && record['timestamp'] is String) {
        record['updatedAt'] = record['timestamp'];
        dirty = true;
      }
      if (dirty) {
        await box.put(key, record);
        changed++;
      }
    }
    AppLogger.debug('📊 [Migration] meals: $changed records backfilled');
  }

  static Future<void> _migrateBodyEntries(String? userId) async {
    final box = await _ensureMapBox(_bodyEntriesBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = deepCastMap(raw);
      if (_setIfAbsent(record, 'userId', userId)) {
        await box.put(key, record);
        changed++;
      }
    }
    AppLogger.debug(
      '📊 [Migration] body_entries: $changed records backfilled',
    );
  }

  static Future<void> _migrateActivePrograms(String? userId) async {
    final box = await _ensureMapBox(_activeProgramBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = deepCastMap(raw);
      var dirty = false;

      dirty |= _setIfAbsent(record, 'userId', userId);
      final program = record['program'];
      if (program is Map) {
        dirty |= _setIfAbsent(program, 'userId', userId);
        final days = program['days'];
        if (days is List) {
          for (final day in days) {
            if (day is! Map) continue;
            final exercises = day['exercises'];
            if (exercises is List) {
              for (final exercise in exercises) {
                if (exercise is Map) {
                  dirty |= _backfillDefinitionId(
                    exercise,
                    nameKey: 'exerciseName',
                  );
                }
              }
            }
          }
        }
      }
      if (dirty) {
        await box.put(key, record);
        changed++;
      }
    }
    AppLogger.debug(
      '📊 [Migration] active_program: $changed records backfilled',
    );
  }

  /// v3: drop retired `SyncOperation` entries from the outbox box,
  /// keeping only `SyncAction`-shaped records.
  static Future<void> _purgeLegacySyncQueueEntries() async {
    final box = await _ensureMapBox(_syncQueueBox);
    if (box == null) return;
    var removed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      final isSyncAction = raw is Map &&
          raw['dataType'] != null &&
          raw['dataId'] != null &&
          raw['status'] != null;
      if (!isSyncAction) {
        await box.delete(key);
        removed++;
      }
    }
    AppLogger.debug(
      '📊 [Migration] sync_queue: removed $removed legacy entries',
    );
  }

  /// v4: move custom foods out of the unencrypted `foods` catalog cache box
  /// into dedicated encrypted `custom_foods`, and normalize storage-scope
  /// key casing across `custom_foods`, `user_profile`, and `diet_plan`.
  static Future<void> _migrateV4CustomFoodsAndStorageScopes() async {
    await _migrateCustomFoodsFromFoodsBox();
    await _normalizeCustomFoodsKeys();
    await _normalizeUserProfileKeys();
    await _normalizeDietPlanKeys();
  }

  static Future<void> _migrateCustomFoodsFromFoodsBox() async {
    final foodsBox = await _ensureDynamicBox(_foodsBox);
    if (foodsBox == null) return;

    final customKeys = foodsBox.keys.where((key) {
      final k = key.toString();
      return k == 'custom_foods' || k.startsWith('custom_foods_');
    }).toList();
    if (customKeys.isEmpty) return;

    final customFoodsBox = await HiveManager.ensureCustomFoodsBox();
    var movedKeys = 0;

    for (final legacyKey in customKeys) {
      final rawVal = foodsBox.get(legacyKey);
      if (rawVal is! List) continue;
      final legacyItems = deepCastList(rawVal);

      final kStr = legacyKey.toString();
      final String targetKey;
      if (kStr == 'custom_foods') {
        targetKey = 'custom_foods';
      } else {
        final rawUid = kStr.substring('custom_foods_'.length);
        final scoped = RecordOwnershipRules.storageScope(rawUid);
        targetKey = scoped == null ? 'custom_foods' : 'custom_foods_$scoped';
      }

      final existingRaw = customFoodsBox.get(targetKey);
      final merged = existingRaw is List
          ? deepCastList(existingRaw)
          : <dynamic>[];
      final existingIds = <String>{
        for (final item in merged)
          if (item is Map && item['id'] != null) item['id'].toString(),
      };
      for (final item in legacyItems) {
        if (item is Map && item['id'] != null) {
          final id = item['id'].toString();
          if (!existingIds.add(id)) continue;
        }
        merged.add(item);
      }

      await customFoodsBox.put(targetKey, merged);
      final persisted = customFoodsBox.get(targetKey);
      if (persisted is List && persisted.length >= legacyItems.length) {
        await foodsBox.delete(legacyKey);
        movedKeys++;
      }
    }

    AppLogger.debug(
      '📊 [Migration] custom_foods: migrated $movedKeys key(s) from foods box',
    );
  }

  static Future<void> _normalizeCustomFoodsKeys() async {
    final customFoodsBox = await _ensureDynamicBox(HiveManager.customFoodsBox);
    if (customFoodsBox == null) return;
    for (final key in customFoodsBox.keys.toList()) {
      final kStr = key.toString();
      if (!kStr.startsWith('custom_foods_')) continue;
      final rawUid = kStr.substring('custom_foods_'.length);
      final scoped = RecordOwnershipRules.storageScope(rawUid);
      if (scoped == null) continue;
      final targetKey = 'custom_foods_$scoped';
      if (targetKey == kStr) continue;

      final rawVal = customFoodsBox.get(key);
      if (rawVal is! List) continue;
      final legacyItems = deepCastList(rawVal);
      final existingRaw = customFoodsBox.get(targetKey);
      final merged = existingRaw is List
          ? deepCastList(existingRaw)
          : <dynamic>[];
      final existingIds = <String>{
        for (final item in merged)
          if (item is Map && item['id'] != null) item['id'].toString(),
      };
      for (final item in legacyItems) {
        if (item is Map && item['id'] != null) {
          if (!existingIds.add(item['id'].toString())) continue;
        }
        merged.add(item);
      }
      await customFoodsBox.put(targetKey, merged);
      if (customFoodsBox.containsKey(targetKey)) {
        await customFoodsBox.delete(key);
      }
    }
  }

  static Future<void> _normalizeUserProfileKeys() async {
    final profileBox = await _ensureDynamicBox(_userProfileBox);
    if (profileBox == null) return;
    const prefixes = ['profile_', 'onboarded_', 'draft_step_', 'draft_data_'];

    for (final key in profileBox.keys.toList()) {
      final kStr = key.toString();
      String? matchedPrefix;
      for (final prefix in prefixes) {
        if (kStr.startsWith(prefix)) {
          matchedPrefix = prefix;
          break;
        }
      }
      if (matchedPrefix == null) continue;
      final rawUid = kStr.substring(matchedPrefix.length);
      final scoped = RecordOwnershipRules.storageScope(rawUid);
      if (scoped == null) continue;
      final targetKey = '$matchedPrefix$scoped';
      if (targetKey == kStr) continue;

      if (!profileBox.containsKey(targetKey)) {
        await profileBox.put(targetKey, profileBox.get(key));
      }
      if (profileBox.containsKey(targetKey)) {
        await profileBox.delete(key);
      }
    }
  }

  static Future<void> _normalizeDietPlanKeys() async {
    final dietPlanBox = await _ensureMapBox(_dietPlanBox);
    if (dietPlanBox == null) return;
    const prefix = 'current_diet_plan_';

    for (final key in dietPlanBox.keys.toList()) {
      final kStr = key.toString();
      if (!kStr.startsWith(prefix)) continue;
      final rawUid = kStr.substring(prefix.length);
      final scoped = RecordOwnershipRules.storageScope(rawUid);
      if (scoped == null) continue;
      final targetKey = '$prefix$scoped';
      if (targetKey == kStr) continue;

      final rawVal = dietPlanBox.get(key);
      if (rawVal is Map && !dietPlanBox.containsKey(targetKey)) {
        await dietPlanBox.put(targetKey, deepCastMap(rawVal));
      }
      if (dietPlanBox.containsKey(targetKey)) {
        await dietPlanBox.delete(key);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Future<Box<Map>?> _ensureMapBox(String name) async {
    if (Hive.isBoxOpen(name) || await Hive.boxExists(name)) {
      return HiveManager.ensureOpen<Map>(name);
    }
    AppLogger.debug('⚠️ [Migration] Box "$name" does not exist; skipping');
    return null;
  }

  static Future<Box<dynamic>?> _ensureDynamicBox(String name) async {
    if (Hive.isBoxOpen(name) || await Hive.boxExists(name)) {
      return HiveManager.ensureOpen<dynamic>(name);
    }
    AppLogger.debug('⚠️ [Migration] Box "$name" does not exist; skipping');
    return null;
  }

  /// Sets [key] to [value] when the record has no value for it yet.
  /// Returns true when a change was made.
  static bool _setIfAbsent(Map record, String key, Object? value) {
    if (value == null) return false;
    if (record[key] != null) return false;
    record[key] = value;
    return true;
  }

  /// Resolves or repairs `exerciseDefinitionId` from the canonical catalog
  /// and alias map (`ExerciseAliasResolver`). Returns true when a change was made.
  static bool _backfillDefinitionId(Map exercise, {required String nameKey}) {
    final existingId = exercise['exerciseDefinitionId'] as String?;
    final name = exercise[nameKey] as String?;
    final resolvedId = ExerciseAliasResolver.resolveCanonicalId(
      storedDefinitionId: existingId,
      exerciseName: name,
      canonicalIdByName: (normName) => ExerciseCatalog.getByName(normName)?.id,
    );
    if (resolvedId == null || resolvedId == existingId) return false;
    exercise['exerciseDefinitionId'] = resolvedId;
    return true;
  }

  /// Wave 3.4 / 3.7: Idempotent migration that repairs colliding or retired
  /// `exerciseDefinitionId` links across stored `workouts` and `active_program`
  /// records (even for databases already at `schema_version == 3`).
  static Future<int> migrateCanonicalExerciseAliases() async {
    var totalUpdated = 0;

    final workoutsBox = await _ensureMapBox(_workoutsBox);
    if (workoutsBox != null) {
      for (final key in workoutsBox.keys.toList()) {
        final raw = workoutsBox.get(key);
        if (raw is! Map) continue;
        final record = deepCastMap(raw);
        var dirty = false;
        final exercises = record['exercises'];
        if (exercises is List) {
          for (final ex in exercises) {
            if (ex is Map) {
              dirty |= _backfillDefinitionId(ex, nameKey: 'name');
            }
          }
        }
        if (dirty) {
          await workoutsBox.put(key, record);
          totalUpdated++;
        }
      }
    }

    final programBox = await _ensureMapBox(_activeProgramBox);
    if (programBox != null) {
      for (final key in programBox.keys.toList()) {
        final raw = programBox.get(key);
        if (raw is! Map) continue;
        final record = deepCastMap(raw);
        var dirty = false;
        final program = record['program'];
        if (program is Map) {
          final days = program['days'];
          if (days is List) {
            for (final day in days) {
              if (day is! Map) continue;
              final exercises = day['exercises'];
              if (exercises is List) {
                for (final ex in exercises) {
                  if (ex is Map) {
                    dirty |=
                        _backfillDefinitionId(ex, nameKey: 'exerciseName');
                  }
                }
              }
            }
          }
        }
        if (dirty) {
          await programBox.put(key, record);
          totalUpdated++;
        }
      }
    }

    return totalUpdated;
  }
}
