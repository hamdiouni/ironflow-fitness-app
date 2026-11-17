import 'package:progression_tracker/core/platform/platform_file_ops.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:convert';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

/// Use case for exporting workout data to various formats.
class ExportWorkoutsUseCase {
  final WorkoutRepository _workoutRepository;

  ExportWorkoutsUseCase(this._workoutRepository);

  /// Exports all workouts to CSV format.
  ///
  /// Returns the file path of the exported CSV file.
  Future<String> exportToCSV() async {
    try {
      AppLogger.debug('📊 [Export] Starting CSV export...');
      final workouts = await _workoutRepository.getAllWorkouts();
      AppLogger.debug('🔍 [Export] Found ${workouts.length} workouts to export');
      final csvContent = _generateCSV(workouts);
      final filePath = await PlatformFileOps.writeExportUtf8File(
        'workouts_export.csv',
        csvContent,
      );
      AppLogger.debug('✅ [Export] CSV export completed: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Export] CSV export failed: $e');
      AppLogger.debug('🔍 [Export] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Exports all workouts to JSON format.
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportToJSON() async {
    try {
      AppLogger.debug('📊 [Export] Starting JSON export...');
      final workouts = await _workoutRepository.getAllWorkouts();
      AppLogger.debug('🔍 [Export] Found ${workouts.length} workouts to export');
      final jsonContent = _generateJSON(workouts);
      final filePath = await PlatformFileOps.writeExportUtf8File(
        'workouts_export.json',
        jsonContent,
      );
      AppLogger.debug('✅ [Export] JSON export completed: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Export] JSON export failed: $e');
      AppLogger.debug('🔍 [Export] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Exports workouts within a date range to CSV.
  ///
  /// [startDate] - Start date for export range
  /// [endDate] - End date for export range
  ///
  /// Returns the file path of the exported CSV file.
  Future<String> exportDateRangeToCSV(DateTime startDate, DateTime endDate) async {
    try {
      AppLogger.debug('📊 [Export] Starting date range CSV export...');
      final workouts = await _workoutRepository.getWorkoutsByDateRange(startDate, endDate);
      final fileName =
          'workouts_${_formatDateForFilename(startDate)}_to_${_formatDateForFilename(endDate)}.csv';
      final filePath = await PlatformFileOps.writeExportUtf8File(
        fileName,
        _generateCSV(workouts),
      );
      AppLogger.debug('✅ [Export] Date range CSV export completed: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Export] Date range CSV export failed: $e');
      AppLogger.debug('🔍 [Export] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Exports workouts within a date range to JSON.
  ///
  /// [startDate] - Start date for export range
  /// [endDate] - End date for export range
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportDateRangeToJSON(DateTime startDate, DateTime endDate) async {
    try {
      AppLogger.debug('📊 [Export] Starting date range JSON export...');
      final workouts = await _workoutRepository.getWorkoutsByDateRange(startDate, endDate);
      final fileName =
          'workouts_${_formatDateForFilename(startDate)}_to_${_formatDateForFilename(endDate)}.json';
      final filePath = await PlatformFileOps.writeExportUtf8File(
        fileName,
        _generateJSON(workouts),
      );
      AppLogger.debug('✅ [Export] Date range JSON export completed: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Export] Date range JSON export failed: $e');
      AppLogger.debug('🔍 [Export] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Exports workout summary statistics to CSV.
  ///
  /// Returns the file path of the exported summary CSV file.
  Future<String> exportSummaryToCSV() async {
    try {
      AppLogger.debug('📊 [Export] Starting summary CSV export...');
      final workouts = await _workoutRepository.getAllWorkouts();
      final filePath = await PlatformFileOps.writeExportUtf8File(
        'workout_summary.csv',
        _generateSummaryCSV(workouts),
      );
      AppLogger.debug('✅ [Export] Summary CSV export completed: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Export] Summary CSV export failed: $e');
      AppLogger.debug('🔍 [Export] Stack trace: $stackTrace');
      rethrow;
    }
  }

  String _generateCSV(List<Workout> workouts) {
    AppLogger.debug('📊 [Export] Generating CSV data...');
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Date,Program,Day,Exercise,Set,Reps,Weight,RPE,Rest,Notes,Duration,Total Volume');
    
    // CSV Data
    int totalRows = 0;
    for (final workout in workouts) {
      final date = workout.date.toIso8601String().split('T')[0];
      const program = 'Default';
      const day = '';
      final duration = '${workout.duration.inMinutes} min';
      final totalVolume = workout.totalVolume.toStringAsFixed(2);
      
      for (final exercise in workout.exercises) {
        final exerciseName = exercise.name;
        
        for (int i = 0; i < exercise.sets.length; i++) {
          final set = exercise.sets[i];
          final setNumber = (i + 1).toString();
          final reps = set.reps.toString();
          final weight = set.weight.toStringAsFixed(2);
          final rpe = set.rpe?.toString() ?? '';
          const rest = '';
          const notes = '';
          
          buffer.writeln('$date,$program,$day,$exerciseName,$setNumber,$reps,$weight,$rpe,$rest,$notes,$duration,$totalVolume');
          totalRows++;
        }
      }
    }
    
    AppLogger.debug('🔍 [Export] Generated $totalRows CSV rows');
    return buffer.toString();
  }

  String _generateJSON(List<Workout> workouts) {
    AppLogger.debug('📊 [Export] Generating JSON data...');
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'export_version': '1.0',
      'total_workouts': workouts.length,
      'workouts': workouts.map((workout) => {
        'id': workout.id,
        'date': workout.date.toIso8601String(),
        'duration_minutes': workout.duration.inMinutes,
        'total_volume': workout.totalVolume,
        'calories_burned': workout.caloriesBurned,
        'exercises': workout.exercises.map((exercise) => {
          'id': exercise.id,
          'name': exercise.name,
          'type': exercise.type.name,
          'sets': exercise.sets.map((set) => {
            'id': set.id,
            'reps': set.reps,
            'weight': set.weight,
            'rpe': set.rpe,
            'timestamp': set.timestamp.toIso8601String(),
          }).toList(),
        }).toList(),
      }).toList(),
    };
    
    AppLogger.debug('🔍 [Export] Generated JSON with ${workouts.length} workouts');
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  String _generateSummaryCSV(List<Workout> workouts) {
    AppLogger.debug('📊 [Export] Generating summary statistics...');
    final buffer = StringBuffer();
    
    // Calculate summary statistics
    final totalWorkouts = workouts.length;
    final totalVolume = workouts.fold<double>(0, (sum, w) => sum + w.totalVolume);
    final averageDuration = totalWorkouts > 0
        ? workouts.fold<int>(0, (sum, w) => sum + w.duration.inMinutes) / totalWorkouts
        : 0.0;
    
    AppLogger.debug('🔍 [Export] Total workouts: $totalWorkouts, Total volume: ${totalVolume.toStringAsFixed(2)} kg');
    
    // Exercise frequency
    final exerciseFrequency = <String, int>{};
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        exerciseFrequency[exercise.name] = (exerciseFrequency[exercise.name] ?? 0) + 1;
      }
    }
    AppLogger.debug('🔍 [Export] Unique exercises: ${exerciseFrequency.length}');
    
    // Monthly breakdown
    final monthlyBreakdown = <String, int>{};
    for (final workout in workouts) {
      final monthKey = '${workout.date.year}-${workout.date.month.toString().padLeft(2, '0')}';
      monthlyBreakdown[monthKey] = (monthlyBreakdown[monthKey] ?? 0) + 1;
    }
    AppLogger.debug('🔍 [Export] Months covered: ${monthlyBreakdown.length}');
    
    // CSV Header and Summary
    buffer.writeln('Workout Summary Report');
    buffer.writeln('Generated on,${DateTime.now().toIso8601String().split('T')[0]}');
    buffer.writeln('');
    buffer.writeln('Overall Statistics');
    buffer.writeln('Total Workouts,$totalWorkouts');
    buffer.writeln('Total Volume,${totalVolume.toStringAsFixed(2)} kg');
    buffer.writeln('Average Duration,${averageDuration.toStringAsFixed(1)} minutes');
    buffer.writeln('');
    
    // Exercise Frequency
    buffer.writeln('Exercise Frequency');
    buffer.writeln('Exercise,Count');
    final sortedExercises = exerciseFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedExercises) {
      buffer.writeln('${entry.key},${entry.value}');
    }
    buffer.writeln('');
    
    // Monthly Breakdown
    buffer.writeln('Monthly Breakdown');
    buffer.writeln('Month,Workouts');
    final sortedMonths = monthlyBreakdown.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedMonths) {
      buffer.writeln('${entry.key},${entry.value}');
    }
    
    AppLogger.debug('🔍 [Export] Summary CSV generated successfully');
    return buffer.toString();
  }

  String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}