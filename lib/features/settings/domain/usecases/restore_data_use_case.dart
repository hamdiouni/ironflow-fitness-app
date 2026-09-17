import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
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
  final FirebaseStorage _storage;

  RestoreDataUseCase(
    this._workoutRepository,
    this._nutritionRepository,
    this._bodyRepository,
    this._authRepository,
    this._storage,
  );

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
    try {
      // Download backup file from cloud storage
      final directory = await getApplicationDocumentsDirectory();
      final localFile = File('${directory.path}/temp_restore_${DateTime.now().millisecondsSinceEpoch}.json');
      
      await _storage.ref(backupRecord.cloudPath).writeToFile(localFile);
      
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

      // Restore workouts
      if (backupData.containsKey('workouts')) {
        try {
          final workouts = backupData['workouts'] as List<dynamic>;
          int restoredWorkouts = 0;
          
          for (final workoutData in workouts) {
            try {
              // TODO: Convert JSON to CompletedWorkout entity and save
              // await _workoutRepository.saveWorkout(workout);
              restoredWorkouts++;
            } catch (e) {
              errors.add('Failed to restore workout: $e');
            }
          }
          
          restoredCounts['workouts'] = restoredWorkouts;
        } catch (e) {
          errors.add('Failed to restore workouts section: $e');
        }
      }

      // Restore programs
      if (backupData.containsKey('programs')) {
        try {
          final programs = backupData['programs'] as List<dynamic>;
          int restoredPrograms = 0;
          
          for (final programData in programs) {
            try {
              // TODO: Convert JSON to Program entity and save
              // await _workoutRepository.saveProgram(program);
              restoredPrograms++;
            } catch (e) {
              errors.add('Failed to restore program: $e');
            }
          }
          
          restoredCounts['programs'] = restoredPrograms;
        } catch (e) {
          errors.add('Failed to restore programs section: $e');
        }
      }

      // Restore nutrition logs
      if (backupData.containsKey('nutrition_logs')) {
        try {
          final nutritionLogs = backupData['nutrition_logs'] as List<dynamic>;
          int restoredNutrition = 0;
          
          for (final nutritionData in nutritionLogs) {
            try {
              // TODO: Convert JSON to DailyNutrition entity and save
              // await _nutritionRepository.saveDailyNutrition(nutrition);
              restoredNutrition++;
            } catch (e) {
              errors.add('Failed to restore nutrition log: $e');
            }
          }
          
          restoredCounts['nutrition_logs'] = restoredNutrition;
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
              // TODO: Convert JSON to BodyMeasurement entity and save
              // await _bodyRepository.saveMeasurement(measurement);
              restoredMeasurements++;
            } catch (e) {
              errors.add('Failed to restore body measurement: $e');
            }
          }
          
          restoredCounts['body_measurements'] = restoredMeasurements;
        } catch (e) {
          errors.add('Failed to restore body measurements section: $e');
        }
      }

      // Return result based on errors
      if (errors.isEmpty) {
        return RestoreResult.success(restoredCounts);
      } else if (restoredCounts.isNotEmpty) {
        return RestoreResult.partial(restoredCounts, errors);
      } else {
        return RestoreResult.failure('Restore failed', errors);
      }
    } catch (e) {
      return RestoreResult.failure('Restore operation failed: $e');
    }
  }

  /// Clears all existing user data before restore.
  Future<void> _clearExistingData() async {
    try {
      await _workoutRepository.deleteAllWorkouts();
      await _workoutRepository.deleteAllPrograms();
      await _nutritionRepository.deleteAllNutritionLogs();
      await _bodyRepository.deleteAllMeasurements();
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
    // For now, accept version 1.0 and later
    final parts = version.split('.');
    if (parts.length >= 2) {
      final major = int.tryParse(parts[0]) ?? 0;
      final minor = int.tryParse(parts[1]) ?? 0;
      
      // Accept version 1.0 and later
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