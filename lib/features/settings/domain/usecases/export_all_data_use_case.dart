import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
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
    final tempDir = Directory('${directory.path}/temp_export_$timestamp');
    
    try {
      // Create temporary directory
      await tempDir.create(recursive: true);
      
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
      final zipFile = File('${directory.path}/ironflow_complete_backup_$timestamp.zip');
      await zipFile.writeAsBytes(ZipEncoder().encode(archive)!);
      
      // Clean up temporary directory
      await tempDir.delete(recursive: true);
      
      return zipFile.path;
    } catch (e) {
      // Clean up on error
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  /// Exports user data for a specific date range.
  ///
  /// [startDate] - Start date for export range
  /// [endDate] - End date for export range
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportDateRange(DateTime startDate, DateTime endDate) async {
    final rangeData = await _gatherDateRangeData(startDate, endDate);
    final jsonContent = const JsonEncoder.withIndent('  ').convert(rangeData);
    
    final directory = await getApplicationDocumentsDirectory();
    final startStr = _formatDateForFilename(startDate);
    final endStr = _formatDateForFilename(endDate);
    final file = File('${directory.path}/ironflow_backup_${startStr}_to_$endStr.json');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Gets export statistics without actually exporting.
  ///
  /// Returns a map with counts of each data type.
  Future<Map<String, int>> getExportStatistics() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    final nutritionLogs = await _nutritionRepository.getAllNutritionLogs();
    final bodyMeasurements = await _bodyRepository.getAllMeasurements();
    final programs = await _workoutRepository.getAllPrograms();
    
    return {
      'workouts': workouts.length,
      'nutrition_days': nutritionLogs.length,
      'body_measurements': bodyMeasurements.length,
      'programs': programs.length,
      'total_meals': nutritionLogs.fold<int>(0, (sum, log) => sum + log.meals.length),
    };
  }

  Future<Map<String, dynamic>> _gatherAllData() async {
    final userProfile = await _authRepository.getCurrentUser();
    final workouts = await _workoutRepository.getAllWorkouts();
    final programs = await _workoutRepository.getAllPrograms();
    final nutritionLogs = await _nutritionRepository.getAllNutritionLogs();
    final bodyMeasurements = await _bodyRepository.getAllMeasurements();
    
    return {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '1.0',
        'app_version': '1.0.0', // TODO: Get from package info
        'export_type': 'complete_backup',
      },
      'user_profile': userProfile?.toJson(),
      'statistics': {
        'total_workouts': workouts.length,
        'total_nutrition_days': nutritionLogs.length,
        'total_body_measurements': bodyMeasurements.length,
        'total_programs': programs.length,
        'date_range': {
          'first_workout': workouts.isNotEmpty 
              ? workouts.map((w) => w.date).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
              : null,
          'last_workout': workouts.isNotEmpty
              ? workouts.map((w) => w.date).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
              : null,
        },
      },
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'programs': programs.map((p) => p.toJson()).toList(),
      'nutrition_logs': nutritionLogs.map((n) => n.toJson()).toList(),
      'body_measurements': bodyMeasurements.map((b) => b.toJson()).toList(),
    };
  }

  Future<Map<String, dynamic>> _gatherDateRangeData(DateTime startDate, DateTime endDate) async {
    final userProfile = await _authRepository.getCurrentUser();
    final workouts = await _workoutRepository.getWorkoutsByDateRange(startDate, endDate);
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(
      startDate: startDate,
      endDate: endDate,
    );
    final bodyMeasurements = await _bodyRepository.getMeasurementsByDateRange(startDate, endDate);
    
    return {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '1.0',
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
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'nutrition_logs': nutritionLogs.map((n) => n.toJson()).toList(),
      'body_measurements': bodyMeasurements.map((b) => b.toJson()).toList(),
    };
  }

  Future<void> _exportWorkoutsToTemp(String tempPath) async {
    final csvPath = await _exportWorkoutsUseCase.exportToCSV();
    final jsonPath = await _exportWorkoutsUseCase.exportToJSON();
    final summaryPath = await _exportWorkoutsUseCase.exportSummaryToCSV();
    
    // Copy files to temp directory
    await File(csvPath).copy('$tempPath/workouts.csv');
    await File(jsonPath).copy('$tempPath/workouts.json');
    await File(summaryPath).copy('$tempPath/workout_summary.csv');
    
    // Clean up original files
    await File(csvPath).delete();
    await File(jsonPath).delete();
    await File(summaryPath).delete();
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
    final bodyMeasurements = await _bodyRepository.getAllMeasurements();
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

  String _generateBodyCSV(List<dynamic> measurements) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Weight,Body Fat,Muscle Mass,Chest,Waist,Hips,Arms,Legs,Notes');
    
    for (final measurement in measurements) {
      final date = measurement.date?.toIso8601String().split('T')[0] ?? '';
      final weight = measurement.weight?.toStringAsFixed(2) ?? '';
      final bodyFat = measurement.bodyFat?.toStringAsFixed(2) ?? '';
      final muscleMass = measurement.muscleMass?.toStringAsFixed(2) ?? '';
      final chest = measurement.chest?.toStringAsFixed(2) ?? '';
      final waist = measurement.waist?.toStringAsFixed(2) ?? '';
      final hips = measurement.hips?.toStringAsFixed(2) ?? '';
      final arms = measurement.arms?.toStringAsFixed(2) ?? '';
      final legs = measurement.legs?.toStringAsFixed(2) ?? '';
      final notes = (measurement.notes ?? '').replaceAll(',', ';').replaceAll('\n', ' ');
      
      buffer.writeln('$date,$weight,$bodyFat,$muscleMass,$chest,$waist,$hips,$arms,$legs,$notes');
    }
    
    return buffer.toString();
  }

  String _generateBodyJSON(List<dynamic> measurements) {
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'export_version': '1.0',
      'total_measurements': measurements.length,
      'body_measurements': measurements.map((m) => m.toJson()).toList(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}