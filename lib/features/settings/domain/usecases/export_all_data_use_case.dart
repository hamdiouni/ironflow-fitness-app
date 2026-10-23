import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/data/models/body_entry_model.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_workouts_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_nutrition_use_case.dart';

/// Use case for exporting all user data to a comprehensive backup file.
class ExportAllDataUseCase {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;
  final AuthRepository _authRepository;
  final ExportWorkoutsUseCase _exportWorkoutsUseCase;
  final ExportNutritionUseCase _exportNutritionUseCase;

  ExportAllDataUseCase(
    this._workoutRepository,
    this._nutritionRepository,
    this._bodyRepository,
    this._authRepository,
    this._exportWorkoutsUseCase,
    this._exportNutritionUseCase,
  );

  /// Exports all user data to a comprehensive JSON file.
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportToJSON() async {
    final allData = await _gatherAllData();
    final jsonContent = const JsonEncoder.withIndent('  ').convert(allData);
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${directory.path}/ironflow_complete_backup_$timestamp.json');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Exports all user data to a ZIP archive containing multiple formats.
  ///
  /// Returns the file path of the exported ZIP file.
  Future<String> exportToZIP() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final zipPath = '${directory.path}/ironflow_backup_$timestamp.zip';
    
    // Create temporary directory for individual export files
    final tempDir = await Directory('${directory.path}/temp_export_$timestamp').create();
    
    try {
      // Export individual components
      await _exportWorkoutsToTemp(tempDir.path);
      await _exportNutritionToTemp(tempDir.path);
      await _exportBodyDataToTemp(tempDir.path);
      await _exportUserProfileToTemp(tempDir.path);
      await _exportCompleteDataToTemp(tempDir.path);
      
      // Create ZIP archive
      final archive = Archive();
      await _addDirectoryToArchive(archive, tempDir, '');
      
      // Write ZIP file
      final zipData = ZipEncoder().encode(archive);
      if (zipData != null) {
        final zipFile = File(zipPath);
        await zipFile.writeAsBytes(zipData);
      }
      
      return zipPath;
    } finally {
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  /// Exports data within a specific date range.
  ///
  /// [startDate] - Start date for export
  /// [endDate] - End date for export
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportDateRangeToJSON(DateTime startDate, DateTime endDate) async {
    final dateRangeData = await _gatherDateRangeData(startDate, endDate);
    final jsonContent = const JsonEncoder.withIndent('  ').convert(dateRangeData);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'ironflow_export_${_formatDateForFilename(startDate)}_to_${_formatDateForFilename(endDate)}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Gets export statistics without actually exporting.
  ///
  /// Returns a map with counts of each data type.
  Future<Map<String, int>> getExportStatistics() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(
      DateTime(2000),
      DateTime.now().add(const Duration(days: 1)),
    );
    final bodyMeasurements = await _bodyRepository.getAllBodyEntries();
    
    return {
      'workouts': workouts.length,
      'nutrition_days': nutritionLogs.length,
      'body_measurements': bodyMeasurements.length,
      'programs': 0,
      'total_meals': nutritionLogs.fold<int>(0, (sum, log) => sum + log.meals.length),
    };
  }

  Future<Map<String, dynamic>> _gatherAllData() async {
    final userProfile = await _authRepository.getCurrentUser();
    final workouts = await _workoutRepository.getAllWorkouts();
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(
      DateTime(2000),
      DateTime.now().add(const Duration(days: 1)),
    );
    final bodyMeasurements = await _bodyRepository.getAllBodyEntries();
    
    return {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '2.0',
        'app_version': '1.0.0',
        'export_type': 'complete_backup',
      },
      'user_profile': userProfile?.toJson(),
      'statistics': {
        'total_workouts': workouts.length,
        'total_nutrition_days': nutritionLogs.length,
        'total_body_measurements': bodyMeasurements.length,
        'total_programs': 0,
        'date_range': {
          'first_workout': workouts.isNotEmpty 
              ? workouts.map((w) => w.date).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
              : null,
          'last_workout': workouts.isNotEmpty
              ? workouts.map((w) => w.date).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
              : null,
        },
      },
      'workouts': workouts.map((w) => _workoutToMap(w)).toList(),
      'programs': [],
      'nutrition_logs': nutritionLogs.map((n) => _nutritionToMap(n)).toList(),
      'body_measurements': bodyMeasurements.map((b) => _bodyEntryToMap(b)).toList(),
    };
  }

  Future<Map<String, dynamic>> _gatherDateRangeData(DateTime startDate, DateTime endDate) async {
    final userProfile = await _authRepository.getCurrentUser();
    final workouts = await _workoutRepository.getWorkoutsByDateRange(startDate, endDate);
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(startDate, endDate);
    final bodyMeasurements = await _bodyRepository.getBodyEntriesByDateRange(startDate, endDate);
    
    return {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '2.0',
        'app_version': '1.0.0',
        'export_type': 'date_range',
        'date_range': {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      },
      'user_profile': userProfile?.toJson(),
      'statistics': {
        'total_workouts': workouts.length,
        'total_nutrition_days': nutritionLogs.length,
        'total_body_measurements': bodyMeasurements.length,
      },
      'workouts': workouts.map((w) => _workoutToMap(w)).toList(),
      'nutrition_logs': nutritionLogs.map((n) => _nutritionToMap(n)).toList(),
      'body_measurements': bodyMeasurements.map((b) => _bodyEntryToMap(b)).toList(),
    };
  }

  // Phase 3 (F-13): records serialize through the real data-layer
  // models — the hand-written snake_case dialect (duration_minutes,
  // total_volume, …) silently dropped every schema-v2 link field
  // (userId, programId, exerciseDefinitionId, suggested reps/sets…)
  // and drifted from the parsers. Restore reads this shape via
  // *Model.fromJson, with the legacy dialect kept as a fallback for
  // pre-2.0 backups.
  Map<String, dynamic> _workoutToMap(Workout w) =>
      WorkoutModel.fromEntity(w).toJson();

  Map<String, dynamic> _nutritionToMap(DailyNutritionSummary n) => {
    'date': n.date.toIso8601String(),
    'total_calories': n.totalCalories,
    'total_protein': n.totalProtein,
    'total_carbs': n.totalCarbs,
    'total_fats': n.totalFats,
    'total_fiber': n.totalFiber,
    'total_sugar': n.totalSugar,
    'total_sodium': n.totalSodium,
    'total_potassium': n.totalPotassium,
    // Meal records are canonical MealModel JSON (Phase 3, F-13) — the
    // old hand map kept only macros, dropping micros/vitamins/minerals
    // and the foodItemId link on every backup.
    'meals': n.meals.map((m) => MealModel.fromEntity(m).toJson()).toList(),
  };

  Map<String, dynamic> _bodyEntryToMap(BodyEntry b) =>
      BodyEntryModel.fromEntity(b).toJson();

  Future<void> _exportWorkoutsToTemp(String tempPath) async {
    final csvPath = await _exportWorkoutsUseCase.exportToCSV();
    final jsonPath = await _exportWorkoutsUseCase.exportToJSON();
    
    await File(csvPath).copy('$tempPath/workouts.csv');
    await File(jsonPath).copy('$tempPath/workouts.json');
    
    await File(csvPath).delete();
    await File(jsonPath).delete();
  }

  Future<void> _exportNutritionToTemp(String tempPath) async {
    final csvPath = await _exportNutritionUseCase.exportToCSV();
    final jsonPath = await _exportNutritionUseCase.exportToJSON();
    final summaryPath = await _exportNutritionUseCase.exportSummaryToCSV();
    final trendsPath = await _exportNutritionUseCase.exportMacroTrendsToCSV();
    
    // Copy files to temp directory
    await File(csvPath).copy('$tempPath/nutrition.csv');
    await File(jsonPath).copy('$tempPath/nutrition.json');
    await File(summaryPath).copy('$tempPath/nutrition_summary.csv');
    await File(trendsPath).copy('$tempPath/macro_trends.csv');
    
    // Clean up original files
    await File(csvPath).delete();
    await File(jsonPath).delete();
    await File(summaryPath).delete();
    await File(trendsPath).delete();
  }

  Future<void> _exportBodyDataToTemp(String tempPath) async {
    final bodyMeasurements = await _bodyRepository.getAllBodyEntries();
    final csvContent = _generateBodyCSV(bodyMeasurements);
    final jsonContent = _generateBodyJSON(bodyMeasurements);
    
    await File('$tempPath/body_measurements.csv').writeAsString(csvContent);
    await File('$tempPath/body_measurements.json').writeAsString(jsonContent);
  }

  Future<void> _exportUserProfileToTemp(String tempPath) async {
    final userProfile = await _authRepository.getCurrentUser();
    if (userProfile != null) {
      final jsonContent = const JsonEncoder.withIndent('  ').convert(userProfile.toJson());
      await File('$tempPath/user_profile.json').writeAsString(jsonContent);
    }
  }

  Future<void> _exportCompleteDataToTemp(String tempPath) async {
    final allData = await _gatherAllData();
    final jsonContent = const JsonEncoder.withIndent('  ').convert(allData);
    await File('$tempPath/complete_backup.json').writeAsString(jsonContent);
  }

  Future<void> _addDirectoryToArchive(Archive archive, Directory dir, String prefix) async {
    await for (final entity in dir.list()) {
      if (entity is File) {
        final bytes = await entity.readAsBytes();
        final relativePath = prefix.isEmpty 
            ? entity.path.split('/').last 
            : '$prefix/${entity.path.split('/').last}';
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      } else if (entity is Directory) {
        final relativePath = prefix.isEmpty 
            ? entity.path.split('/').last 
            : '$prefix/${entity.path.split('/').last}';
        await _addDirectoryToArchive(archive, entity, relativePath);
      }
    }
  }

  String _generateBodyCSV(List<BodyEntry> measurements) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Weight,PhotoPath');
    
    for (final measurement in measurements) {
      final date = measurement.date.toIso8601String().split('T')[0];
      final weight = measurement.weight.toStringAsFixed(2);
      final photo = measurement.photoPath ?? '';
      
      buffer.writeln('$date,$weight,$photo');
    }
    
    return buffer.toString();
  }

  String _generateBodyJSON(List<BodyEntry> measurements) {
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'export_version': '2.0',
      'total_measurements': measurements.length,
      'body_measurements': measurements.map((m) => _bodyEntryToMap(m)).toList(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}