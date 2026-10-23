import '../entities/entities.dart';
import '../repositories/workout_repository.dart';

/// Suggestion types for progression
enum ProgressionSuggestionType {
  increaseWeight,
  maintain,
  increaseReps,
  deload,
}

/// Use case for getting progression suggestions based on workout history.
///
/// Excludes warm-up sets ([SetType.warmup]) from volume, completion rate, and RPE analysis.
/// Uses genuine user-entered RPE when available, and never fabricates artificial RPE values (+6/+9).
class GetProgressionSuggestionUseCase {
  final WorkoutRepository repository;

  GetProgressionSuggestionUseCase(this.repository);

  /// Get progression suggestion for an exercise
  /// 
  /// Analyzes the last 3 workouts for the given exercise and suggests:
  /// - Weight increase if user completed all working sets easily (or low RPE)
  /// - Adding reps if user completed working sets but near fatigue
  /// - Deload if user failed multiple sets or logged max fatigue (RPE >= 9)
  /// - Maintaining weight otherwise
  Future<ProgressionSuggestion?> call(String exerciseName) async {
    try {
      // Get all workouts
      final allWorkouts = await repository.getAllWorkouts();
      
      // Filter workouts that contain this exercise (case-insensitive, to
      // match WorkoutRepository.getExerciseHistory's convention — exact ==
      // here disagreed with it on the same data; F-05)
      final exerciseWorkouts = allWorkouts
          .where((w) => w.exercises
              .any((e) => e.name.toLowerCase() == exerciseName.toLowerCase()))
          .toList();

      if (exerciseWorkouts.isEmpty) {
        return null;
      }

      // Take last 3 workouts
      final recentWorkouts = exerciseWorkouts.take(3).toList();

      // Get the exercise from each workout
      final exerciseHistory = recentWorkouts
          .map((w) => w.exercises.firstWhere(
              (e) => e.name.toLowerCase() == exerciseName.toLowerCase()))
          .toList();

      if (exerciseHistory.isEmpty) {
        return null;
      }

      // Analyze performance on working sets
      final lastExercise = exerciseHistory.first;
      final avgWeight = _calculateAverageWeight(exerciseHistory);
      final completionRate = _calculateCompletionRate(exerciseHistory);
      final rpeAverage = _calculateAverageRPE(exerciseHistory);

      if (avgWeight <= 0) return null;

      // Generate suggestion based on genuine performance
      if (rpeAverage != null) {
        // Genuine RPE available
        if (completionRate >= 0.9 && rpeAverage <= 7.5) {
          final increase = (avgWeight * 0.025).clamp(1.0, 5.0).roundToDouble();
          return ProgressionSuggestion(
            suggestedWeight: avgWeight + increase,
            suggestedReps: lastExercise.suggestedReps ?? 8,
            isStagnant: false,
            message: 'Great intensity control (RPE ${rpeAverage.toStringAsFixed(1)}). Try increasing weight by ${increase.toStringAsFixed(1)}kg',
          );
        } else if (completionRate < 0.7 || rpeAverage >= 9.0) {
          final decrease = (avgWeight * 0.05).clamp(2.5, 10.0).roundToDouble();
          return ProgressionSuggestion(
            suggestedWeight: (avgWeight - decrease).clamp(0.0, double.infinity),
            suggestedReps: lastExercise.suggestedReps ?? 8,
            isStagnant: true,
            message: 'High fatigue (RPE ${rpeAverage.toStringAsFixed(1)}). Consider deloading by ${decrease.toStringAsFixed(1)}kg to focus on form',
          );
        } else if (completionRate >= 0.9 && rpeAverage > 7.5) {
          return ProgressionSuggestion(
            suggestedWeight: avgWeight,
            suggestedReps: (lastExercise.suggestedReps ?? 8) + 1,
            isStagnant: false,
            message: 'Solid effort. Add 1 rep at this weight before bumping load',
          );
        } else {
          return ProgressionSuggestion(
            suggestedWeight: avgWeight,
            suggestedReps: lastExercise.suggestedReps ?? 8,
            isStagnant: false,
            message: 'Maintain current weight and focus on clean reps',
          );
        }
      } else {
        // No user RPE provided — rely solely on completion rate of working sets (no fabricated RPE)
        if (completionRate >= 0.95) {
          final increase = (avgWeight * 0.025).clamp(1.0, 5.0).roundToDouble();
          return ProgressionSuggestion(
            suggestedWeight: avgWeight + increase,
            suggestedReps: lastExercise.suggestedReps ?? 8,
            isStagnant: false,
            message: 'All target sets completed! Try increasing weight by ${increase.toStringAsFixed(1)}kg',
          );
        } else if (completionRate < 0.7) {
          final decrease = (avgWeight * 0.05).clamp(2.5, 10.0).roundToDouble();
          return ProgressionSuggestion(
            suggestedWeight: (avgWeight - decrease).clamp(0.0, double.infinity),
            suggestedReps: lastExercise.suggestedReps ?? 8,
            isStagnant: true,
            message: 'Consider reducing weight by ${decrease.toStringAsFixed(1)}kg to consolidate volume',
          );
        } else if (completionRate >= 0.85) {
          return ProgressionSuggestion(
            suggestedWeight: avgWeight,
            suggestedReps: (lastExercise.suggestedReps ?? 8) + 1,
            isStagnant: false,
            message: 'Try adding 1 rep next session',
          );
        } else {
          return ProgressionSuggestion(
            suggestedWeight: avgWeight,
            suggestedReps: lastExercise.suggestedReps ?? 8,
            isStagnant: false,
            message: 'Maintain current weight and focus on form',
          );
        }
      }
    } catch (e) {
      return null;
    }
  }

  /// Calculate average weight across working sets (excluding warm-ups)
  double _calculateAverageWeight(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;
    
    double totalWeight = 0;
    int count = 0;

    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.type == SetType.warmup) continue;
        totalWeight += set.weight;
        count++;
      }
    }

    return count > 0 ? totalWeight / count : 0;
  }

  /// Calculate completion rate of working sets (completed working sets / planned sets)
  double _calculateCompletionRate(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;

    int totalPlanned = 0;
    int totalWorkingCompleted = 0;

    for (final exercise in exercises) {
      totalPlanned += exercise.suggestedSets ?? 3;
      totalWorkingCompleted += exercise.sets.where((s) => s.type != SetType.warmup).length;
    }

    return totalPlanned > 0 ? totalWorkingCompleted / totalPlanned : 0;
  }

  /// Calculate average genuine RPE logged by the user on working sets.
  /// Returns null if user did not log RPE (never returns fabricated values).
  double? _calculateAverageRPE(List<Exercise> exercises) {
    if (exercises.isEmpty) return null;

    double totalRPE = 0;
    int count = 0;

    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.type == SetType.warmup) continue;
        if (set.rpe != null && set.rpe! >= 1 && set.rpe! <= 10) {
          totalRPE += set.rpe!;
          count++;
        }
      }
    }

    return count > 0 ? totalRPE / count : null;
  }
}
