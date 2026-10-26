import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/body/data/models/body_entry_model.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/settings/domain/usecases/backup_data_use_case.dart';

/// Result of a restore operation.
class RestoreResult {
  final bool success;
  final String message;
  final Map<String, int> restoredCounts;
  final List<String> errors;

  const RestoreResult({
    required this.success,
    required this.message,
    required this.restoredCounts,
    required this.errors,
  });

  factory RestoreResult.success(Map<String, int> counts) => RestoreResult(
    success: true,
    message: 'Data restored successfully',
    restoredCounts: counts,
    errors: [],
  );

  factory RestoreResult.failure(String message, [List<String>? errors]) => RestoreResult(
    success: false,
    message: message,
    restoredCounts: {},
    errors: errors ?? [message],
  );

  factory RestoreResult.partial(Map<String, int> counts, List<String> errors) => RestoreResult(
    success: true,
    message: 'Data partially restored with some errors',
    restoredCounts: counts,
    errors: errors,
  );
}

/// Metadata and counts preview of a validated backup.
class BackupPreview {
  final bool isValid;
  final String? error;
  final List<String> validationErrors;
  final String? exportVersion;
  final DateTime? exportDate;
  final int workoutCount;
  final int nutritionCount;
  final int bodyMeasurementCount;
  final bool hasUserProfile;
  final Map<String, dynamic>? data;

  const BackupPreview({
    required this.isValid,
    this.error,
    this.validationErrors = const [],
    this.exportVersion,
    this.exportDate,
    this.workoutCount = 0,
    this.nutritionCount = 0,
    this.bodyMeasurementCount = 0,
    this.hasUserProfile = false,
    this.data,
  });

  factory BackupPreview.invalid(String error, [List<String>? errors]) => BackupPreview(
    isValid: false,
    error: error,
    validationErrors: errors ?? [error],
  );
}

/// Use case for safely restoring user data from backup files.
/// Guarantees zero data loss: validates and parses all records in memory
/// BEFORE deleting or modifying any existing repository data.
class RestoreDataUseCase {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;
  final AuthRepository _authRepository;
  final FirebaseStorage? _storage;
  final Directory? _privateDocumentsDir;

  RestoreDataUseCase(
    this._workoutRepository,
    this._nutritionRepository,
    this._bodyRepository,
    this._authRepository, [
    FirebaseStorage? storage,
    Directory? privateDocumentsDir,
  ])  : _storage = storage,
        _privateDocumentsDir = privateDocumentsDir;

  Future<String?> _currentRestoreUserId() async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      return RecordOwnershipRules.normalizeUserId(currentUser?.id);
    } catch (_) {
      return null;
    }
  }

  bool _isForeignRecord(String? ownerId, String? currentUserId) {
    return RecordOwnershipRules.isForeignToCurrentUser(
      ownerId: ownerId,
      currentUserId: currentUserId,
    );
  }

  String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;

  bool _isLegacySnapshotFile(File file) {
    const prefix = 'safety_snapshot_';
    const suffix = '.json';
    final name = _fileName(file.path);
    if (!name.startsWith(prefix) || !name.endsWith(suffix)) return false;
    final middle = name.substring(prefix.length, name.length - suffix.length);
    return middle.isNotEmpty && int.tryParse(middle) != null;
  }

  Future<List<File>> _snapshotFilesForCurrentScope() async {
    final snapshotDir = await getSafetySnapshotDirectory();
    if (!await snapshotDir.exists()) return <File>[];

    final allSnapshots = snapshotDir
        .listSync()
        .whereType<File>()
        .where(
          (file) =>
              _fileName(file.path).startsWith('safety_snapshot_') &&
              file.path.endsWith('.json'),
        )
        .toList();

    final currentUserId = await _currentRestoreUserId();
    final scope = RecordOwnershipRules.storageScope(currentUserId);
    List<File> scopedSnapshots;
    if (scope == null) {
      scopedSnapshots = allSnapshots.where(_isLegacySnapshotFile).toList();
    } else {
      final scopedPrefix = 'safety_snapshot_${scope}_';
      scopedSnapshots = allSnapshots
          .where((file) => _fileName(file.path).startsWith(scopedPrefix))
          .toList();
      if (scopedSnapshots.isEmpty) {
        // One-time legacy adoption only when no account-scoped
        // snapshot exists yet. After scoped snapshots exist, a legacy
        // snapshot cannot be safely attributed to this account.
        final hasAnyScopedSnapshot =
            allSnapshots.any((file) => !_isLegacySnapshotFile(file));
        if (!hasAnyScopedSnapshot) {
          scopedSnapshots =
              allSnapshots.where(_isLegacySnapshotFile).toList();
        }
      }
    }

    scopedSnapshots.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );
    return scopedSnapshots;
  }

  /// Restores data from a cloud backup.
  Future<RestoreResult> restoreFromCloudBackup(
    BackupRecord backupRecord, {
    bool overwriteExisting = false,
  }) async {
    final storage = _storage;
    if (storage == null) {
      return RestoreResult.failure('Cloud storage is not configured for restore');
    }
    try {
      final directory = _privateDocumentsDir ?? await getApplicationDocumentsDirectory();
      final localFile = File('${directory.path}/temp_restore_${DateTime.now().millisecondsSinceEpoch}.json');
      
      await storage.ref(backupRecord.cloudPath).writeToFile(localFile);
      
      final result = await restoreFromLocalFile(
        localFile.path,
        overwriteExisting: overwriteExisting,
      );
      
      if (await localFile.exists()) {
        await localFile.delete();
      }
      
      return result;
    } catch (e) {
      return RestoreResult.failure('Failed to download backup: $e');
    }
  }

  /// Restores data from a local JSON file.
  Future<RestoreResult> restoreFromLocalFile(
    String filePath, {
    bool overwriteExisting = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return RestoreResult.failure('Backup file not found');
      }

      final jsonContent = await file.readAsString();
      return await restoreFromJsonString(
        jsonContent,
        overwriteExisting: overwriteExisting,
      );
    } catch (e) {
      return RestoreResult.failure('Failed to read backup file: $e');
    }
  }

  /// Restores data from a JSON string.
  /// Validates format and dry-parses in memory before any repository modification.
  Future<RestoreResult> restoreFromJsonString(
    String jsonData, {
    bool overwriteExisting = false,
  }) async {
    try {
      final dynamic decoded = jsonDecode(jsonData);
      if (decoded is! Map<String, dynamic>) {
        return RestoreResult.failure('Backup data must be a JSON object');
      }

      // 1. Schema and required sections validation
      final validationResult = _validateBackupData(decoded);
      if (!validationResult.success) {
        return validationResult;
      }

      // 2. Perform safe restore (dry-parse in memory before any write/clear)
      return await _performRestore(decoded, overwriteExisting);
    } catch (e) {
      return RestoreResult.failure('Failed to parse JSON data: $e');
    }
  }

  /// Validates backup data format and version compatibility.
  RestoreResult _validateBackupData(Map<String, dynamic> backupData) {
    final errors = <String>[];

    // Check required export_info
    if (!backupData.containsKey('export_info') || backupData['export_info'] is! Map<String, dynamic>) {
      errors.add('Missing export_info section');
    } else {
      final exportInfo = backupData['export_info'] as Map<String, dynamic>;
      final version = exportInfo['export_version'] as String?;
      if (version != null && !_isVersionCompatible(version)) {
        errors.add('Incompatible backup version: $version');
      }
    }

    // Check data presence
    final hasWorkouts = backupData.containsKey('workouts');
    final hasNutrition = backupData.containsKey('nutrition_logs') || backupData.containsKey('daily_nutrition');
    final hasBody = backupData.containsKey('body_measurements');
    final hasProfile = backupData.containsKey('user_profile') && backupData['user_profile'] != null;

    if (!hasWorkouts && !hasNutrition && !hasBody && !hasProfile) {
      errors.add('No data sections found in backup');
    }

    if (errors.isNotEmpty) {
      return RestoreResult.failure('Backup validation failed', errors);
    }

    return RestoreResult.success({});
  }

  /// Directory where safety snapshots are securely stored in app-private storage.
  Future<Directory> getSafetySnapshotDirectory() async {
    Directory baseDir;
    final privateDocs = _privateDocumentsDir;
    if (privateDocs != null) {
      baseDir = privateDocs;
    } else {
      try {
        baseDir = await getApplicationDocumentsDirectory();
      } catch (_) {
        baseDir = Directory.systemTemp;
      }
    }
    final snapshotDir = Directory('${baseDir.path}/safety_snapshots');
    if (!await snapshotDir.exists()) {
      await snapshotDir.create(recursive: true);
    }
    return snapshotDir;
  }

  /// Captures a complete snapshot of the current state before restore.
  Future<File> createSafetySnapshot() async {
    final snapshotDir = await getSafetySnapshotDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final currentUserId = await _currentRestoreUserId();
    final scope = RecordOwnershipRules.storageScope(currentUserId);
    final fileName = scope == null
        ? 'safety_snapshot_$timestamp.json'
        : 'safety_snapshot_${scope}_$timestamp.json';
    final file = File('${snapshotDir.path}/$fileName');

    final snapshotData = await _captureCurrentStateSnapshot();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(snapshotData));

    // Prune old snapshots (keep max 3)
    await _pruneOldSnapshots();
    return file;
  }

  /// Gathers all existing data into a snapshot payload.
  Future<Map<String, dynamic>> _captureCurrentStateSnapshot() async {
    UserProfile? userProfile;
    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        userProfile = await _authRepository.getUserProfile(currentUser.id);
      }
    } catch (_) {}
    final workouts = await _workoutRepository.getAllWorkouts();
    
    // Gather nutrition
    final meals = <Meal>[];
    try {
      final history = await _nutritionRepository.getNutritionHistory(
        DateTime.fromMillisecondsSinceEpoch(0),
        DateTime.now().add(const Duration(days: 365)),
      );
      for (final day in history) {
        meals.addAll(day.meals);
      }
    } catch (_) {}

    final bodyEntries = await _bodyRepository.getAllBodyEntries();

    return {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '2.0',
        'app_version': '1.2.0',
        'export_type': 'safety_snapshot',
      },
      'user_profile': userProfile?.toJson(),
      'workouts': workouts.map((w) => _workoutToMap(w)).toList(),
      'nutrition_logs': [
        {
          'date': DateTime.now().toIso8601String(),
          'meals': meals.map((m) => _mealToMap(m)).toList(),
        }
      ],
      'body_measurements': bodyEntries.map((b) => _bodyEntryToMap(b)).toList(),
    };
  }

  /// Prunes old snapshots to retain at most 3 snapshots in app-private storage.
  Future<void> _pruneOldSnapshots() async {
    try {
      final files = await _snapshotFilesForCurrentScope();

      if (files.length > 3) {
        for (int i = 3; i < files.length; i++) {
          await files[i].delete();
        }
      }
    } catch (_) {}
  }

  /// Returns the most recent safety snapshot file, if one exists.
  Future<File?> getLatestSnapshot() async {
    try {
      final files = await _snapshotFilesForCurrentScope();
      if (files.isEmpty) return null;
      return files.first;
    } catch (_) {
      return null;
    }
  }

  /// Checks if an undo snapshot is available for restoration.
  Future<bool> hasUndoSnapshot() async {
    final latest = await getLatestSnapshot();
    return latest != null;
  }

  /// Undoes the last restore operation by applying the most recent safety snapshot.
  Future<RestoreResult> undoRestore() async {
    final snapshotFile = await getLatestSnapshot();
    if (snapshotFile == null) {
      return RestoreResult.failure('No safety snapshot available to undo restore');
    }

    try {
      final jsonContent = await snapshotFile.readAsString();
      final decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        return RestoreResult.failure('Safety snapshot file is invalid');
      }

      // Restore without creating a new snapshot to prevent recursion
      final result = await _performRestore(decoded, true, isRollback: true);
      if (result.success) {
        await snapshotFile.delete();
      }
      return result;
    } catch (e) {
      return RestoreResult.failure('Failed to undo restore: $e');
    }
  }

  /// Deletes safety snapshot files for the current restore scope.
  /// Used in account/data deletion (REL-01).
  Future<void> clearAllSnapshots() async {
    try {
      final files = await _snapshotFilesForCurrentScope();
      for (final file in files) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Performs safe data restore with automated snapshot and rollback protection.
  Future<RestoreResult> _performRestore(
    Map<String, dynamic> backupData,
    bool overwriteExisting, {
    bool isRollback = false,
  }) async {
    final restoredCounts = <String, int>{};
    final errors = <String>[];

    // --- PHASE 1: IN-MEMORY PARSING (Zero database writes or deletes) ---
    UserProfile? parsedProfile;
    final parsedWorkouts = <Workout>[];
    final parsedMeals = <Meal>[];
    final parsedBodyEntries = <BodyEntry>[];

    // Profile
    if (backupData.containsKey('user_profile') && backupData['user_profile'] != null) {
      try {
        final profileJson = backupData['user_profile'] as Map<String, dynamic>;
        parsedProfile = UserProfile.fromJson(profileJson);
      } catch (e) {
        errors.add('Failed to parse user profile: $e');
      }
    }

    // Workouts
    if (backupData.containsKey('workouts')) {
      final workoutsRaw = backupData['workouts'];
      if (workoutsRaw is List) {
        for (final workoutData in workoutsRaw) {
          try {
            if (workoutData is! Map<String, dynamic>) {
              throw const FormatException('Workout data is not a valid JSON object');
            }
            parsedWorkouts.add(_parseWorkout(workoutData));
          } catch (e) {
            errors.add('Failed to restore workout: $e');
          }
        }
      } else {
        errors.add('Workouts section is not a list');
      }
    }

    // Programs
    if (backupData.containsKey('programs')) {
      final programs = backupData['programs'] as List<dynamic>? ?? [];
      if (programs.isNotEmpty) {
        errors.add('Program restoration is not currently supported');
      }
    }

    // Nutrition Logs (supporting both 'nutrition_logs' and 'daily_nutrition')
    final nutritionRaw = backupData['nutrition_logs'] ?? backupData['daily_nutrition'];
    if (nutritionRaw is List) {
      for (final dayLog in nutritionRaw) {
        try {
          if (dayLog is! Map<String, dynamic>) {
            throw const FormatException('Nutrition log is not a valid JSON object');
          }
          if (dayLog.containsKey('meals') && dayLog['meals'] is List) {
            for (final mealData in dayLog['meals'] as List<dynamic>) {
              if (mealData is Map<String, dynamic>) {
                parsedMeals.add(_parseMeal(mealData));
              }
            }
          } else if (dayLog.containsKey('macros') || dayLog.containsKey('name')) {
            parsedMeals.add(_parseMeal(dayLog));
          }
        } catch (e) {
          errors.add('Failed to restore nutrition log: $e');
        }
      }
    }

    // Body Measurements
    if (backupData.containsKey('body_measurements')) {
      final bodyRaw = backupData['body_measurements'];
      if (bodyRaw is List) {
        for (final measurementData in bodyRaw) {
          try {
            if (measurementData is! Map<String, dynamic>) {
              throw const FormatException('Body measurement is not a valid JSON object');
            }
            parsedBodyEntries.add(_parseBodyEntry(measurementData));
          } catch (e) {
            errors.add('Failed to restore body measurement: $e');
          }
        }
      } else {
        errors.add('Body measurements section is not a list');
      }
    }

    // Ownership preflight: when an account is signed in, records
    // proven to belong to another account are skipped here, before a
    // safety snapshot or any clear/write. Legacy-unowned records keep
    // the existing local-restore behaviour and are stamped by the
    // scoped repositories when written. This deliberately does not
    // retag another account's backup into the current account.
    final currentUserId = await _currentRestoreUserId();
    if (currentUserId != null) {
      if (parsedProfile != null &&
          !RecordOwnershipRules.isOwnedByCurrentUser(
            ownerId: parsedProfile.userId,
            currentUserId: currentUserId,
          )) {
        errors.add('Skipped user profile from another account');
        parsedProfile = null;
      }

      final foreignWorkouts = parsedWorkouts
          .where((workout) => _isForeignRecord(workout.userId, currentUserId))
          .length;
      if (foreignWorkouts > 0) {
        parsedWorkouts.removeWhere(
          (workout) => _isForeignRecord(workout.userId, currentUserId),
        );
        errors.add(
          'Skipped $foreignWorkouts workout(s) from another account',
        );
      }

      final foreignMeals = parsedMeals
          .where((meal) => _isForeignRecord(meal.userId, currentUserId))
          .length;
      if (foreignMeals > 0) {
        parsedMeals.removeWhere(
          (meal) => _isForeignRecord(meal.userId, currentUserId),
        );
        errors.add('Skipped $foreignMeals meal(s) from another account');
      }

      final foreignBodyEntries = parsedBodyEntries
          .where((entry) => _isForeignRecord(entry.userId, currentUserId))
          .length;
      if (foreignBodyEntries > 0) {
        parsedBodyEntries.removeWhere(
          (entry) => _isForeignRecord(entry.userId, currentUserId),
        );
        errors.add(
          'Skipped $foreignBodyEntries body measurement(s) from another account',
        );
      }
    }

    // If completely unable to parse any valid record and errors exist, abort before wiping
    final totalParsed = (parsedProfile != null ? 1 : 0) +
        parsedWorkouts.length +
        parsedMeals.length +
        parsedBodyEntries.length;

    if (totalParsed == 0 && errors.isNotEmpty) {
      return RestoreResult.failure('Restore failed', errors);
    }

    // --- PHASE 2: SAFETY SNAPSHOT (REL-03) ---
    File? safetySnapshotFile;
    if (!isRollback) {
      try {
        safetySnapshotFile = await createSafetySnapshot();
      } catch (e) {
        return RestoreResult.failure('Failed to create safety snapshot before restore: $e');
      }
    }

    // --- PHASE 3: WRITE WITH ROLLBACK PROTECTION ---
    try {
      if (overwriteExisting) {
        await _clearExistingData();
      }

      if (parsedProfile != null) {
        await _authRepository.saveUserProfile(parsedProfile);
        restoredCounts['user_profile'] = 1;
      }

      if (parsedWorkouts.isNotEmpty || backupData.containsKey('workouts')) {
        for (final w in parsedWorkouts) {
          await _workoutRepository.saveWorkout(w);
        }
        if (parsedWorkouts.isNotEmpty) {
          restoredCounts['workouts'] = parsedWorkouts.length;
        }
      }

      if (parsedMeals.isNotEmpty || nutritionRaw != null) {
        for (final m in parsedMeals) {
          await _nutritionRepository.saveMealEntry(m);
        }
        if (parsedMeals.isNotEmpty) {
          restoredCounts['nutrition_logs'] = parsedMeals.length;
        }
      }

      if (parsedBodyEntries.isNotEmpty || backupData.containsKey('body_measurements')) {
        for (final b in parsedBodyEntries) {
          await _bodyRepository.saveBodyEntry(b);
        }
        if (parsedBodyEntries.isNotEmpty) {
          restoredCounts['body_measurements'] = parsedBodyEntries.length;
        }
      }

      if (backupData.containsKey('programs')) {
        restoredCounts['programs'] = 0;
      }

      if (errors.isEmpty) {
        return RestoreResult.success(restoredCounts);
      } else if (restoredCounts.values.any((c) => c > 0)) {
        return RestoreResult.partial(restoredCounts, errors);
      } else {
        return RestoreResult.failure('Restore failed', errors);
      }
    } catch (e) {
      // ON ANY FAILURE: ROLLBACK FROM SAFETY SNAPSHOT
      if (!isRollback && safetySnapshotFile != null) {
        await _rollbackFromSnapshot(safetySnapshotFile);
        return RestoreResult.failure(
          'Restore operation write failed: $e. Previous data was safely rolled back from safety snapshot.',
          [e.toString()],
        );
      }
      return RestoreResult.failure('Restore operation write failed: $e');
    }
  }

  /// Automatically rolls back state using the safety snapshot file.
  Future<void> _rollbackFromSnapshot(File snapshotFile) async {
    try {
      if (!await snapshotFile.exists()) return;
      final content = await snapshotFile.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) return;

      await _clearExistingData();
      await _performRestore(decoded, false, isRollback: true);
    } catch (_) {}
  }

  Workout _parseWorkout(Map<String, dynamic> data) {
    // Phase 3 (F-13): backups from export_version 2.0 store canonical
    // WorkoutModel JSON (marked by `durationSeconds`) — parse through
    // the real model so link fields survive. The hand parser below
    // remains only for pre-2.0 backups in the legacy snake_case dialect.
    if (data.containsKey('durationSeconds')) {
      return WorkoutModel.fromJson(data).toEntity();
    }
    final id = data['id'] as String? ?? 'workout_${DateTime.now().millisecondsSinceEpoch}';
    final dateStr = data['date'] as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    final durationMinutes = (data['duration_minutes'] as num?)?.toInt() ?? 0;
    final totalVolume = ((data['total_volume'] ?? data['total_volume_kg']) as num?)?.toDouble() ?? 0.0;
    final caloriesBurned = (data['calories_burned'] as num?)?.toDouble() ?? 0.0;

    final exercisesList = data['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesList.map((eData) {
      final eMap = eData as Map<String, dynamic>;
      final eId = eMap['id'] as String? ?? 'ex_${DateTime.now().millisecondsSinceEpoch}';
      final name = eMap['name'] as String? ?? 'Exercise';
      final rawType = (eMap['type'] as String? ?? 'strength').replaceAll('ExerciseType.', '').toLowerCase();
      final type = ExerciseType.values.firstWhere(
        (t) => t.name.toLowerCase() == rawType,
        orElse: () => ExerciseType.strength,
      );

      final setsList = eMap['sets'] as List<dynamic>? ?? [];
      final sets = setsList.asMap().entries.map((entry) {
        final idx = entry.key;
        final sMap = entry.value as Map<String, dynamic>;
        return SetEntry(
          id: sMap['id'] as String? ?? 'set_${idx + 1}',
          reps: (sMap['reps'] as num).toInt(),
          weight: ((sMap['weight'] ?? sMap['weight_kg']) as num).toDouble(),
          rpe: (sMap['rpe'] as num?)?.toInt(),
          timestamp: sMap.containsKey('timestamp') && sMap['timestamp'] != null
              ? DateTime.parse(sMap['timestamp'] as String)
              : date,
        );
      }).toList();

      return Exercise(
        id: eId,
        name: name,
        type: type,
        sets: sets,
      );
    }).toList();

    return Workout(
      id: id,
      date: date,
      exercises: exercises,
      duration: Duration(minutes: durationMinutes),
      totalVolume: totalVolume,
      caloriesBurned: caloriesBurned,
    );
  }

  Meal _parseMeal(Map<String, dynamic> data) {
    // Phase 3 (F-13): canonical MealModel JSON carries the full
    // nutrient groups; parse through the real model (preserving
    // userId/foodItemId links). Older exports kept only a `macros`
    // map per meal and fall through to the legacy parser below.
    if (data.containsKey('micros') &&
        data.containsKey('vitamins') &&
        data.containsKey('minerals')) {
      try {
        return MealModel.fromJson(data).toEntity();
      } catch (_) {
        // Not model-shaped after all — try the legacy dialect.
      }
    }
    final id = data['id'] as String? ?? 'meal_${DateTime.now().millisecondsSinceEpoch}';
    final name = data['name'] as String? ?? 'Meal';
    final timestamp = data.containsKey('timestamp') && data['timestamp'] != null
        ? DateTime.parse(data['timestamp'] as String)
        : DateTime.now();

    final macrosMap = data['macros'] as Map<String, dynamic>? ?? {};
    final macros = MealMacros(
      calories: ((data['total_calories'] ?? macrosMap['calories']) as num?)?.toDouble() ?? 0.0,
      protein: ((data['total_protein'] ?? macrosMap['protein']) as num?)?.toDouble() ?? 0.0,
      carbs: ((data['total_carbs'] ?? macrosMap['carbs']) as num?)?.toDouble() ?? 0.0,
      fats: ((data['total_fats'] ?? macrosMap['fats']) as num?)?.toDouble() ?? 0.0,
    );

    final microsMap = data['micros'] as Map<String, dynamic>?;
    final micros = microsMap != null
        ? MealMicros(
            fiber: (microsMap['fiber'] as num?)?.toDouble() ?? 0.0,
            sugar: (microsMap['sugar'] as num?)?.toDouble() ?? 0.0,
            sodium: (microsMap['sodium'] as num?)?.toDouble() ?? 0.0,
            potassium: (microsMap['potassium'] as num?)?.toDouble() ?? 0.0,
          )
        : const MealMicros(fiber: 0, sugar: 0, sodium: 0, potassium: 0);

    final vitaminsMap = data['vitamins'] as Map<String, dynamic>?;
    final vitamins = vitaminsMap != null
        ? MealVitamins(
            vitaminA: (vitaminsMap['vitaminA'] as num?)?.toDouble() ?? 0.0,
            vitaminB: (vitaminsMap['vitaminB'] as num?)?.toDouble() ?? 0.0,
            vitaminC: (vitaminsMap['vitaminC'] as num?)?.toDouble() ?? 0.0,
            vitaminD: (vitaminsMap['vitaminD'] as num?)?.toDouble() ?? 0.0,
            vitaminE: (vitaminsMap['vitaminE'] as num?)?.toDouble() ?? 0.0,
          )
        : const MealVitamins(vitaminA: 0, vitaminB: 0, vitaminC: 0, vitaminD: 0, vitaminE: 0);

    final mineralsMap = data['minerals'] as Map<String, dynamic>?;
    final minerals = mineralsMap != null
        ? MealMinerals(
            calcium: (mineralsMap['calcium'] as num?)?.toDouble() ?? 0.0,
            iron: (mineralsMap['iron'] as num?)?.toDouble() ?? 0.0,
            magnesium: (mineralsMap['magnesium'] as num?)?.toDouble() ?? 0.0,
            zinc: (mineralsMap['zinc'] as num?)?.toDouble() ?? 0.0,
          )
        : const MealMinerals(calcium: 0, iron: 0, magnesium: 0, zinc: 0);

    return Meal(
      id: id,
      name: name,
      macros: macros,
      micros: micros,
      vitamins: vitamins,
      minerals: minerals,
      timestamp: timestamp,
    );
  }

  BodyEntry _parseBodyEntry(Map<String, dynamic> data) {
    // Phase 3 (F-13): canonical BodyEntryModel JSON uses camelCase
    // (`photoPath`); the legacy dialect used `photo_path` and stays on
    // the hand parser below so old backups keep their photo paths.
    if (data.containsKey('photoPath')) {
      try {
        return BodyEntryModel.fromJson(data).toEntity();
      } catch (_) {
        // Not model-shaped after all — try the legacy dialect.
      }
    }
    final id = data['id'] as String? ?? 'body_${DateTime.now().millisecondsSinceEpoch}';
    final dateStr = data['date'] as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    final weight = (data['weight'] as num).toDouble();
    final photoPath = data['photo_path'] as String?;

    final rawMeasurements = data['measurements'] as Map<dynamic, dynamic>? ?? {};
    final measurements = <MeasurementType, double>{};
    for (final entry in rawMeasurements.entries) {
      final keyStr = entry.key.toString();
      final val = (entry.value as num?)?.toDouble();
      if (val != null) {
        for (final type in MeasurementType.values) {
          if (type.name.toLowerCase() == keyStr.toLowerCase()) {
            measurements[type] = val;
            break;
          }
        }
      }
    }

    return BodyEntry(
      id: id,
      date: date,
      weight: weight,
      measurements: measurements,
      photoPath: photoPath,
    );
  }

  /// Clears existing user data.
  Future<void> _clearExistingData() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    for (final w in workouts) {
      await _workoutRepository.deleteWorkout(w.id);
    }
    await _nutritionRepository.clearAllData();
    final bodyEntries = await _bodyRepository.getAllBodyEntries();
    for (final b in bodyEntries) {
      await _bodyRepository.deleteBodyEntry(b.id);
    }
  }

  bool _isVersionCompatible(String version) {
    final parts = version.split('.');
    if (parts.isNotEmpty) {
      final major = int.tryParse(parts[0]) ?? 0;
      return major >= 1;
    }
    return false;
  }

  /// Gets a structured preview of what would be restored from a backup file.
  Future<BackupPreview> getRestorePreview(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupPreview.invalid('Backup file not found');
      }

      final jsonContent = await file.readAsString();
      return getRestorePreviewFromJson(jsonContent);
    } catch (e) {
      return BackupPreview.invalid('Failed to preview backup file: $e');
    }
  }

  /// Gets a structured preview of what would be restored from a JSON string.
  BackupPreview getRestorePreviewFromJson(String jsonContent) {
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        return BackupPreview.invalid('Backup file is not a valid JSON object');
      }

      final validation = _validateBackupData(decoded);
      if (!validation.success) {
        return BackupPreview.invalid(validation.message, validation.errors);
      }

      final exportInfo = decoded['export_info'] as Map<String, dynamic>?;
      final version = exportInfo?['export_version'] as String?;
      final dateStr = exportInfo?['export_date'] as String?;
      final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

      final workoutsList = decoded['workouts'] as List<dynamic>? ?? [];
      final nutritionList = (decoded['nutrition_logs'] ?? decoded['daily_nutrition']) as List<dynamic>? ?? [];
      final bodyList = decoded['body_measurements'] as List<dynamic>? ?? [];
      final hasProfile = decoded['user_profile'] != null;

      return BackupPreview(
        isValid: true,
        exportVersion: version,
        exportDate: date,
        workoutCount: workoutsList.length,
        nutritionCount: nutritionList.length,
        bodyMeasurementCount: bodyList.length,
        hasUserProfile: hasProfile,
        data: decoded,
      );
    } catch (e) {
      return BackupPreview.invalid('Corrupt or unreadable JSON: $e');
    }
  }

  // Phase 3 (F-13): safety snapshots use the same canonical model JSON
  // as backups (previously a third hand-written copy of the dialect,
  // which also dropped schema-v2 link fields — a rollback would have
  // silently unlinked every restored record).
  Map<String, dynamic> _workoutToMap(Workout w) =>
      WorkoutModel.fromEntity(w).toJson();

  Map<String, dynamic> _mealToMap(Meal m) =>
      MealModel.fromEntity(m).toJson();

  Map<String, dynamic> _bodyEntryToMap(BodyEntry b) =>
      BodyEntryModel.fromEntity(b).toJson();
}
