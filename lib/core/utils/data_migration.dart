import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/features/workout/data/exercise_database.dart';

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
class DataMigration {
  static const int currentSchemaVersion = 2;
  static const String _versionKey = 'schema_version';

  static const String _appSettingsBox = 'app_settings';
  static const String _workoutsBox = 'workouts';
  static const String _mealsBox = 'meals';
  static const String _bodyEntriesBox = 'body_entries';
  static const String _activeProgramBox = 'active_program';

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
      final settings = Hive.box<String>(_appSettingsBox);
      final stored =
          int.tryParse(settings.get(_versionKey) ?? '') ?? 1;
      if (stored >= currentSchemaVersion) return;

      AppLogger.debug(
        '🔄 [Migration] Upgrading local schema v$stored → '
        'v$currentSchemaVersion',
      );

      await _migrateWorkouts(currentUserId);
      await _migrateMeals(currentUserId);
      await _migrateBodyEntries(currentUserId);
      await _migrateActivePrograms(currentUserId);

      await settings.put(_versionKey, '$currentSchemaVersion');
      AppLogger.debug('✅ [Migration] Local schema is now '
          'v$currentSchemaVersion');
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
    final box = _openMapBox(_workoutsBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = _deepCopy(raw);
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
    final box = _openMapBox(_mealsBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = _deepCopy(raw);
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
    final box = _openMapBox(_bodyEntriesBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = _deepCopy(raw);
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
    final box = _openMapBox(_activeProgramBox);
    if (box == null) return;
    var changed = 0;
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = _deepCopy(raw);
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Box<Map>? _openMapBox(String name) {
    if (!Hive.isBoxOpen(name)) {
      AppLogger.debug('⚠️ [Migration] Box "$name" not open; skipping');
      return null;
    }
    return Hive.box<Map>(name);
  }

  /// Sets [key] to [value] when the record has no value for it yet.
  /// Returns true when a change was made.
  static bool _setIfAbsent(Map record, String key, Object? value) {
    if (value == null) return false;
    if (record[key] != null) return false;
    record[key] = value;
    return true;
  }

  /// Resolves `exerciseDefinitionId` from the catalog by exercise name.
  /// Returns true when a change was made.
  static bool _backfillDefinitionId(Map exercise, {required String nameKey}) {
    if (exercise['exerciseDefinitionId'] != null) return false;
    final name = exercise[nameKey];
    if (name is! String) return false;
    final definition = ExerciseDatabase.getByName(name);
    if (definition == null) return false;
    exercise['exerciseDefinitionId'] = definition.id;
    return true;
  }

  /// Deep-copies a raw Hive map into mutable, string-keyed structures, so
  /// edits never touch Hive's in-memory objects before `put`, and written
  /// values match the `Map<String, dynamic>` shape the data sources use.
  static Map<String, dynamic> _deepCopy(Map source) {
    return source.map(
      (key, value) => MapEntry(key.toString(), _copyValue(value)),
    );
  }

  static dynamic _copyValue(dynamic value) {
    if (value is Map) return _deepCopy(value);
    if (value is List) return value.map(_copyValue).toList();
    return value;
  }
}
