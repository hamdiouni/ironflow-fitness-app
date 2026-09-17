import '../entities/entities.dart';
import '../repositories/workout_repository.dart';

/// Suggestion types for progression
enum ProgressionSuggestionType {
  increaseWeight,
  maintain,
  increaseReps,
  deload,
}

/// Use case for getting progression suggestions based on workout history
class GetProgressionSuggestionUseCase {
  final WorkoutRepository repository;

  GetProgressionSuggestionUseCase(this.repository);

  /// Get progression suggestion for an exercise
  /// 
  /// Analyzes the last 3 workouts for the given exercise and suggests:
  /// - Weight increase if user completed all sets easily
  /// - Maintaining weight if user struggled
  /// - Adding reps if user completed all sets but not easily
  /// - Deload if user failed multiple sets
  Future<ProgressionSuggestion?> call(String exerciseName) async {
    try {
      // Get last 3 workouts
      final allWorkouts = await repository.getAllWorkouts();
      
      // Filter workouts that contain this exercise
      final exerciseWorkouts = allWorkouts
          .where((w) => w.exercises.any((e) => e.name == exerciseName))
          .toList();

      if (exerciseWorkouts.isEmpty) {
        return null;
      }

      // Take last 3 workouts
      final recentWorkouts = exerciseWorkouts.take(3).toList();

      // Get the exercise from each workout
      final exerciseHistory = recentWorkouts
          .map((w) => w.exercises.firstWhere((e) => e.name == exerciseName))
          .toList();

      if (exerciseHistory.isEmpty) {
        return null;
      }

      // Analyze performance
      final lastExercise = exerciseHistory.first;
      final avgWeight = _calculateAverageWeight(exerciseHistory);
      final completionRate = _calculateCompletionRate(exerciseHistory);
      final rpeAverage = _calculateAverageRPE(exerciseHistory);

      // Generate suggestion based on analysis
      if (completionRate >= 0.9 && rpeAverage <= 7) {
        // Easy completion - suggest weight increase
        final increase = (avgWeight * 0.025).roundToDouble(); // 2.5% increase
        return ProgressionSuggestion(
          suggestedWeight: avgWeight + increase,
          suggestedReps: lastExercise.suggestedReps ?? 8,
          isStagnant: false,
          message: 'Great job! Try increasing weight by ${increase.toStringAsFixed(1)}kg',
        );
      } else if (completionRate < 0.7 || rpeAverage >= 9) {
        // Struggled - suggest deload
        final decrease = (avgWeight * 0.05).roundToDouble(); // 5% decrease
        return ProgressionSuggestion(
          suggestedWeight: (avgWeight - decrease).clamp(0.0, double.infinity),
          suggestedReps: lastExercise.suggestedReps ?? 8,
          isStagnant: true,
          message: 'Consider reducing weight by ${decrease.toStringAsFixed(1)}kg to focus on form',
        );
      } else if (completionRate >= 0.9 && rpeAverage > 7) {
        // Completed but challenging - suggest adding reps
        return ProgressionSuggestion(
          suggestedWeight: avgWeight,
          suggestedReps: (lastExercise.suggestedReps ?? 8) + 1,
          isStagnant: false,
          message: 'Try adding 1-2 reps next time',
        );
      } else {
        // Maintain current weight
        return ProgressionSuggestion(
          suggestedWeight: avgWeight,
          suggestedReps: lastExercise.suggestedReps ?? 8,
          isStagnant: false,
          message: 'Maintain current weight and focus on form',
        );
      }
    } catch (e) {
      return null;
    }
  }

  /// Calculate average weight across exercises
  double _calculateAverageWeight(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;
    
    double totalWeight = 0;
    int count = 0;

    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        totalWeight += set.weight;
        count++;
      }
    }

    return count > 0 ? totalWeight / count : 0;
  }

  /// Calculate completion rate (sets completed / sets planned)
  double _calculateCompletionRate(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;

    int totalPlanned = 0;
    int totalCompleted = 0;

    for (final exercise in exercises) {
      totalPlanned += exercise.suggestedSets ?? 3;
      totalCompleted += exercise.sets.length;
    }

    return totalPlanned > 0 ? totalCompleted / totalPlanned : 0;
  }

  /// Calculate average RPE (Rate of Perceived Exertion)
  /// RPE is estimated based on reps completed vs reps planned
  double _calculateAverageRPE(List<Exercise> exercises) {
    if (exercises.isEmpty) return 5;

    double totalRPE = 0;
    int count = 0;

    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        // Estimate RPE: if user completed all reps, RPE is lower
        // If user failed, RPE is higher
        final repsCompleted = set.reps;
        final repsPlanned = exercise.suggestedReps ?? 8;
        
        if (repsCompleted >= repsPlanned) {
          totalRPE += 6; // Easy
        } else if (repsCompleted >= repsPlanned - 2) {
          totalRPE += 7; // Moderate
        } else if (repsCompleted >= repsPlanned - 4) {
          totalRPE += 8; // Hard
        } else {
          totalRPE += 9; // Very hard
        }
        
        count++;
      }
    }

    return count > 0 ? totalRPE / count : 5;
  }
}
