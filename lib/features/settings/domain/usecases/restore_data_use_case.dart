import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
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
    errors: errors ?? [],
  );

  factory RestoreResult.partial(Map<String, int> counts, List<String> errors) => RestoreResult(
    success: true,
    message: 'Data partially restored with some errors',
    restoredCounts: counts,
    errors: errors,
  );
}

/// Use case for restoring user data from backup files.
class RestoreDataUseCase {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;
  final AuthRepository _authRepository;
  final FirebaseStorage? _storage;

  RestoreDataUseCase(
    this._workoutRepository,
    this._nutritionRepository,
    this._bodyRepository,
    this._authRepository, [
    FirebaseStorage? storage,
  ]) : _storage = storage;

  /// Restores data from a cloud backup.
  ///
  /// [backupRecord] - The backup record to restore from
  /// [overwriteExisting] - Whether to overwrite existing data (default: false)
  ///
  /// Returns a RestoreResult with success status and details.
  Future<RestoreResult> restoreFromCloudBackup(
    BackupRecord backupRecord, {
    bool overwriteExisting = false,
  }) async {
    final storage = _storage;
    if (storage == null) {
      return RestoreResult.failure('Cloud storage is not configured for restore');
    }
    try {
      // Download backup file from cloud storage
      final directory = await getApplicationDocumentsDirectory();
      final localFile = File('${directory.path}/temp_restore_${DateTime.now().millisecondsSinceEpoch}.json');
      
      await storage.ref(backupRecord.cloudPath).writeToFile(localFile);
      
      // Restore from local file
      final result = await restoreFromLocalFile(
        localFile.path,
        overwriteExisting: overwriteExisting,
      );
      
      // Clean up temporary file
      await localFile.delete();
      
      return result;
    } catch (e) {
      return RestoreResult.failure('Failed to download backup: $e');
    }
  }

  /// Restores data from a local JSON file.
  ///
  /// [filePath] - Path to the backup JSON file
  /// [overwriteExisting] - Whether to overwrite existing data (default: false)
  ///
  /// Returns a RestoreResult with success status and details.
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
      final backupData = jsonDecode(jsonContent) as Map<String, dynamic>;

      // Validate backup format
      final validationResult = _validateBackupData(backupData);
      if (!validationResult.success) {
        return validationResult;
      }

      // Perform restore
      return await _performRestore(backupData, overwriteExisting);
    } catch (e) {
      return RestoreResult.failure('Failed to read backup file: $e');
    }
  }

  /// Restores data from a JSON string.
  ///
  /// [jsonData] - JSON string containing backup data
  /// [overwriteExisting] - Whether to overwrite existing data (default: false)
  ///
  /// Returns a RestoreResult with success status and details.
  Future<RestoreResult> restoreFromJsonString(
    String jsonData, {
    bool overwriteExisting = false,
  }) async {
    try {
      final backupData = jsonDecode(jsonData) as Map<String, dynamic>;

      // Validate backup format
      final validationResult = _validateBackupData(backupData);
      if (!validationResult.success) {
        return validationResult;
      }

      // Perform restore
      return await _performRestore(backupData, overwriteExisting);
    } catch (e) {
      return RestoreResult.failure('Failed to parse JSON data: $e');
    }
  }

  /// Validates backup data before restore.
  ///
  /// [backupData] - The parsed backup data
  ///
  /// Returns a RestoreResult indicating validation success or failure.
  RestoreResult _validateBackupData(Map<String, dynamic> backupData) {
    final errors = <String>[];

    // Check required fields
    if (!backupData.containsKey('export_info')) {
      errors.add('Missing export_info section');
    }

    if (!backupData.containsKey('workouts') && 
        !backupData.containsKey('nutrition_logs') && 
        !backupData.containsKey('body_measurements')) {
      errors.add('No data sections found in backup');
    }

    // Check export version compatibility
    final exportInfo = backupData['export_info'] as Map<String, dynamic>?;
    if (exportInfo != null) {
      final version = exportInfo['export_version'] as String?;
      if (version != null && !_isVersionCompatible(version)) {
        errors.add('Incompatible backup version: $version');
      }
    }

    if (errors.isNotEmpty) {
      return RestoreResult.failure('Backup validation failed', errors);
    }

    return RestoreResult.success({});
  }

  /// Performs the actual data restore operation.
  ///
  /// [backupData] - The validated backup data
  /// [overwriteExisting] - Whether to overwrite existing data
  ///
  /// Returns a RestoreResult with restore details.
  Future<RestoreResult> _performRestore(
    Map<String, dynamic> backupData,
    bool overwriteExisting,
  ) async {
    final restoredCounts = <String, int>{};
    final errors = <String>[];

    try {
      // Clear existing data if overwriting
      if (overwriteExisting) {
        await _clearExistingData();
      }

      // Restore user profile
      if (backupData.containsKey('user_profile') && backupData['user_profile'] != null) {
        try {
          final profileJson = backupData['user_profile'] as Map<String, dynamic>;
          final profile = UserProfile.fromJson(profileJson);
          await _authRepository.saveUserProfile(profile);
          restoredCounts['user_profile'] = 1;
        } catch (e) {
          errors.add('Failed to restore user profile: $e');
        }
      }

      // Restore workouts
      if (backupData.containsKey('workouts')) {
        try {
          final workouts = backupData['workouts'] as List<dynamic>;
          int restoredWorkouts = 0;
          
          for (final workoutData in workouts) {
            try {
              if (workoutData is! Map<String, dynamic>) {
                throw const FormatException('Workout data is not a valid JSON object');
              }
              final workout = _parseWorkout(workoutData);
              await _workoutRepository.saveWorkout(workout);
              restoredWorkouts++;
            } catch (e) {
              errors.add('Failed to restore workout: $e');
            }
          }
          
          if (restoredWorkouts > 0 || workouts.isEmpty) {
            restoredCounts['workouts'] = restoredWorkouts;
          }
        } catch (e) {
          errors.add('Failed to restore workouts section: $e');
        }
      }

      // Restore programs
      if (backupData.containsKey('programs')) {
        try {
          final programs = backupData['programs'] as List<dynamic>;
          if (programs.isNotEmpty) {
            errors.add('Program restoration is not currently supported');
          } else {
            restoredCounts['programs'] = 0;
          }
        } catch (e) {
          errors.add('Failed to restore programs section: $e');
        }
      }

      // Restore nutrition logs
      if (backupData.containsKey('nutrition_logs')) {
        try {
          final nutritionLogs = backupData['nutrition_logs'] as List<dynamic>;
          int restoredNutrition = 0;
          
          for (final dayLog in nutritionLogs) {
            try {
              if (dayLog is! Map<String, dynamic>) {
                throw const FormatException('Nutrition log is not a valid JSON object');
              }
              if (dayLog.containsKey('meals')) {
                final meals = dayLog['meals'] as List<dynamic>? ?? [];
                int mealsSaved = 0;
                for (final mealData in meals) {
                  if (mealData is Map<String, dynamic>) {
                    final meal = _parseMeal(mealData);
                    await _nutritionRepository.saveMealEntry(meal);
                    mealsSaved++;
                  }
                }
                if (mealsSaved > 0 || meals.isEmpty) {
                  restoredNutrition++;
                }
              } else if (dayLog.containsKey('macros')) {
                final meal = _parseMeal(dayLog);
                await _nutritionRepository.saveMealEntry(meal);
                restoredNutrition++;
              }
            } catch (e) {
              errors.add('Failed to restore nutrition log: $e');
            }
          }
          
          if (restoredNutrition > 0 || nutritionLogs.isEmpty) {
            restoredCounts['nutrition_logs'] = restoredNutrition;
          }
        } catch (e) {
          errors.add('Failed to restore nutrition section: $e');
        }
      }

      // Restore body measurements
      if (backupData.containsKey('body_measurements')) {
        try {
          final bodyMeasurements = backupData['body_measurements'] as List<dynamic>;
          int restoredMeasurements = 0;
          
          for (final measurementData in bodyMeasurements) {
            try {
              if (measurementData is! Map<String, dynamic>) {
                throw const FormatException('Body measurement is not a valid JSON object');
              }
              final entry = _parseBodyEntry(measurementData);
              await _bodyRepository.saveBodyEntry(entry);
              restoredMeasurements++;
            } catch (e) {
              errors.add('Failed to restore body measurement: $e');
            }
          }
          
          if (restoredMeasurements > 0 || bodyMeasurements.isEmpty) {
            restoredCounts['body_measurements'] = restoredMeasurements;
          }
        } catch (e) {
          errors.add('Failed to restore body measurements section: $e');
        }
      }

      // Return result based on errors
      if (errors.isEmpty) {
        return RestoreResult.success(restoredCounts);
      } else if (restoredCounts.values.any((count) => count > 0)) {
        return RestoreResult.partial(restoredCounts, errors);
      } else {
        return RestoreResult.failure('Restore failed', errors);
      }
    } catch (e) {
      return RestoreResult.failure('Restore operation failed: $e');
    }
  }

  Workout _parseWorkout(Map<String, dynamic> data) {
    final id = data['id'] as String;
    final date = DateTime.parse(data['date'] as String);
    final durationMinutes = (data['duration_minutes'] as num?)?.toInt() ?? 0;
    final totalVolume = (data['total_volume'] as num?)?.toDouble() ?? 0.0;
    final caloriesBurned = (data['calories_burned'] as num?)?.toDouble() ?? 0.0;

    final exercisesList = data['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesList.map((eData) {
      final eMap = eData as Map<String, dynamic>;
      final eId = eMap['id'] as String;
      final name = eMap['name'] as String;
      final typeStr = eMap['type'] as String? ?? 'strength';
      final type = ExerciseType.values.firstWhere(
        (t) => t.name.toLowerCase() == typeStr.toLowerCase(),
        orElse: () => ExerciseType.strength,
      );

      final setsList = eMap['sets'] as List<dynamic>? ?? [];
      final sets = setsList.map((sData) {
        final sMap = sData as Map<String, dynamic>;
        return SetEntry(
          id: sMap['id'] as String,
          reps: (sMap['reps'] as num).toInt(),
          weight: (sMap['weight'] as num).toDouble(),
          rpe: (sMap['rpe'] as num?)?.toInt(),
          timestamp: sMap.containsKey('timestamp')
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
    final id = data['id'] as String;
    final name = data['name'] as String;
    final timestamp = DateTime.parse(data['timestamp'] as String);

    final macrosMap = data['macros'] as Map<String, dynamic>? ?? {};
    final macros = MealMacros(
      calories: (macrosMap['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (macrosMap['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (macrosMap['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (macrosMap['fats'] as num?)?.toDouble() ?? 0.0,
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
    final id = data['id'] as String;
    final date = DateTime.parse(data['date'] as String);
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

  /// Clears all existing user data before restore.
  Future<void> _clearExistingData() async {
    try {
      final workouts = await _workoutRepository.getAllWorkouts();
      for (final w in workouts) {
        await _workoutRepository.deleteWorkout(w.id);
      }
      await _nutritionRepository.clearAllData();
      final bodyEntries = await _bodyRepository.getAllBodyEntries();
      for (final b in bodyEntries) {
        await _bodyRepository.deleteBodyEntry(b.id);
      }
    } catch (e) {
      throw Exception('Failed to clear existing data: $e');
    }
  }

  /// Checks if the backup version is compatible with current app version.
  ///
  /// [version] - The backup version string
  ///
  /// Returns true if compatible, false otherwise.
  bool _isVersionCompatible(String version) {
    final parts = version.split('.');
    if (parts.isNotEmpty) {
      final major = int.tryParse(parts[0]) ?? 0;
      return major >= 1;
    }
    return false;
  }

  /// Gets a preview of what would be restored from a backup file.
  ///
  /// [filePath] - Path to the backup file
  ///
  /// Returns a map with counts of each data type that would be restored.
  Future<Map<String, dynamic>> getRestorePreview(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonContent = await file.readAsString();
      final backupData = jsonDecode(jsonContent) as Map<String, dynamic>;

      final preview = <String, dynamic>{};

      // Export info
      if (backupData.containsKey('export_info')) {
        preview['export_info'] = backupData['export_info'];
      }

      // Statistics
      if (backupData.containsKey('statistics')) {
        preview['statistics'] = backupData['statistics'];
      }

      // Data counts
      final counts = <String, int>{};
      
      if (backupData.containsKey('workouts')) {
        counts['workouts'] = (backupData['workouts'] as List).length;
      }
      
      if (backupData.containsKey('programs')) {
        counts['programs'] = (backupData['programs'] as List).length;
      }
      
      if (backupData.containsKey('nutrition_logs')) {
        counts['nutrition_logs'] = (backupData['nutrition_logs'] as List).length;
      }
      
      if (backupData.containsKey('body_measurements')) {
        counts['body_measurements'] = (backupData['body_measurements'] as List).length;
      }

      preview['data_counts'] = counts;

      return preview;
    } catch (e) {
      throw Exception('Failed to preview backup file: $e');
    }
  }
}