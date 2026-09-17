import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/retention/domain/entities/streak.dart';

/// Entity representing a weekly report.
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalWorkouts;
  final double totalVolume;
  final int personalRecords;
  final int totalMeals;
  final Map<String, double> averageMacros;
  final int currentStreak;
  final double consistencyRate;
  final List<String> highlights;
  final List<String> recommendations;

  const WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.totalWorkouts,
    required this.totalVolume,
    required this.personalRecords,
    required this.totalMeals,
    required this.averageMacros,
    required this.currentStreak,
    required this.consistencyRate,
    required this.highlights,
    required this.recommendations,
  });

  /// Converts report to shareable text format.
  String toShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('📊 IronFlow Weekly Report');
    buffer.writeln('Week: ${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}');
    buffer.writeln('');
    buffer.writeln('💪 Workouts: $totalWorkouts');
    buffer.writeln('🏋️ Total Volume: ${totalVolume.toStringAsFixed(0)} kg');
    buffer.writeln('🏆 Personal Records: $personalRecords');
    buffer.writeln('🔥 Streak: $currentStreak days');
    buffer.writeln('📈 Consistency: ${(consistencyRate * 100).toStringAsFixed(0)}%');
    buffer.writeln('');
    buffer.writeln('🍽️ Nutrition:');
    buffer.writeln('  Meals Logged: $totalMeals');
    buffer.writeln('  Avg Protein: ${averageMacros['protein']?.toStringAsFixed(0)}g');
    buffer.writeln('  Avg Carbs: ${averageMacros['carbs']?.toStringAsFixed(0)}g');
    buffer.writeln('  Avg Fats: ${averageMacros['fats']?.toStringAsFixed(0)}g');
    
    if (highlights.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('✨ Highlights:');
      for (final highlight in highlights) {
        buffer.writeln('  • $highlight');
      }
    }

    return buffer.toString();
  }
}

/// Use case for generating weekly workout and nutrition reports.
class GenerateWeeklyReportUseCase {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;

  GenerateWeeklyReportUseCase(
    this._workoutRepository,
    this._nutritionRepository,
  );

  /// Generates a weekly report for the specified week.
  ///
  /// [weekStart] - Start date of the week (defaults to last Sunday)
  ///
  /// Returns [WeeklyReport] with comprehensive weekly statistics.
  Future<WeeklyReport> call({DateTime? weekStart}) async {
    // Default to last Sunday if not specified
    final start = weekStart ?? _getLastSunday();
    final end = start.add(const Duration(days: 7));

    // Get workouts for the week
    final workouts = await _workoutRepository.getWorkoutsByDateRange(start, end);

    // Calculate workout metrics
    final totalWorkouts = workouts.length;
    final totalVolume = workouts.fold<double>(
      0,
      (sum, w) => sum + (w.totalVolume ?? 0),
    );

    // Calculate PRs (simplified - compare with previous week)
    final previousWeekStart = start.subtract(const Duration(days: 7));
    final previousWorkouts = await _workoutRepository.getWorkoutsByDateRange(
      previousWeekStart,
      start,
    );
    final personalRecords = _calculatePRs(workouts, previousWorkouts);

    // Get nutrition data
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(
      startDate: start,
      endDate: end,
    );

    final totalMeals = nutritionLogs.length;
    final averageMacros = _calculateAverageMacros(nutritionLogs);

    // Calculate streak
    final allWorkouts = await _workoutRepository.getAllWorkouts();
    final currentStreak = _calculateStreak(allWorkouts);

    // Calculate consistency rate
    final consistencyRate = totalWorkouts / 5; // Assume 5 workouts per week target

    // Generate highlights
    final highlights = _generateHighlights(
      totalWorkouts: totalWorkouts,
      totalVolume: totalVolume,
      personalRecords: personalRecords,
      currentStreak: currentStreak,
      consistencyRate: consistencyRate,
    );

    // Generate recommendations
    final recommendations = _generateRecommendations(
      totalWorkouts: totalWorkouts,
      consistencyRate: consistencyRate,
      averageMacros: averageMacros,
    );

    return WeeklyReport(
      weekStart: start,
      weekEnd: end,
      totalWorkouts: totalWorkouts,
      totalVolume: totalVolume,
      personalRecords: personalRecords,
      totalMeals: totalMeals,
      averageMacros: averageMacros,
      currentStreak: currentStreak,
      consistencyRate: consistencyRate.clamp(0.0, 1.0),
      highlights: highlights,
      recommendations: recommendations,
    );
  }

  /// Generates report for the current week.
  Future<WeeklyReport> generateCurrentWeek() async {
    return await call();
  }

  /// Generates report for a specific week number.
  ///
  /// [weeksAgo] - Number of weeks ago (0 = current week, 1 = last week, etc.)
  Future<WeeklyReport> generateWeeksAgo(int weeksAgo) async {
    final weekStart = _getLastSunday().subtract(Duration(days: weeksAgo * 7));
    return await call(weekStart: weekStart);
  }

  DateTime _getLastSunday() {
    final now = DateTime.now();
    final daysFromSunday = now.weekday % 7;
    return now.subtract(Duration(days: daysFromSunday));
  }

  int _calculatePRs(List<dynamic> currentWeek, List<dynamic> previousWeek) {
    int prs = 0;

    for (final workout in currentWeek) {
      for (final exercise in workout.exercises) {
        final maxWeight = exercise.sets.fold<double>(
          0,
          (max, set) => (set.weight ?? 0) > max ? (set.weight ?? 0) : max,
        );

        // Check if this is a PR compared to previous week
        bool isPR = true;
        for (final prevWorkout in previousWeek) {
          for (final prevExercise in prevWorkout.exercises) {
            if (prevExercise.name == exercise.name) {
              final prevMaxWeight = prevExercise.sets.fold<double>(
                0,
                (max, set) => (set.weight ?? 0) > max ? (set.weight ?? 0) : max,
              );
              if (prevMaxWeight >= maxWeight) {
                isPR = false;
                break;
              }
            }
          }
          if (!isPR) break;
        }

        if (isPR && maxWeight > 0) prs++;
      }
    }

    return prs;
  }

  Map<String, double> _calculateAverageMacros(List<dynamic> nutritionLogs) {
    if (nutritionLogs.isEmpty) {
      return {'protein': 0, 'carbs': 0, 'fats': 0, 'calories': 0};
    }

    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    double totalCalories = 0;

    for (final log in nutritionLogs) {
      totalProtein += log.protein ?? 0;
      totalCarbs += log.carbs ?? 0;
      totalFats += log.fats ?? 0;
      totalCalories += log.calories ?? 0;
    }

    final count = nutritionLogs.length;

    return {
      'protein': totalProtein / count,
      'carbs': totalCarbs / count,
      'fats': totalFats / count,
      'calories': totalCalories / count,
    };
  }

  int _calculateStreak(List<dynamic> workouts) {
    if (workouts.isEmpty) return 0;

    final sorted = List.from(workouts);
    sorted.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (final workout in sorted) {
      if (lastDate == null) {
        streak = 1;
      } else {
        final daysDiff = lastDate.difference(workout.date).inDays;
        if (daysDiff == 1) {
          streak++;
        } else {
          break;
        }
      }
      lastDate = workout.date;
    }

    return streak;
  }

  List<String> _generateHighlights(
      {required int totalWorkouts,
      required double totalVolume,
      required int personalRecords,
      required int currentStreak,
      required double consistencyRate}) {
    final highlights = <String>[];

    if (totalWorkouts >= 5) {
      highlights.add('Completed $totalWorkouts workouts - excellent consistency!');
    } else if (totalWorkouts >= 3) {
      highlights.add('Completed $totalWorkouts workouts this week');
    }

    if (personalRecords > 0) {
      highlights.add('Set $personalRecords personal record${personalRecords > 1 ? 's' : ''}!');
    }

    if (currentStreak >= 7) {
      highlights.add('$currentStreak day streak - you\'re on fire! 🔥');
    }

    if (totalVolume > 10000) {
      highlights.add('Lifted ${(totalVolume / 1000).toStringAsFixed(1)}k kg total volume!');
    }

    if (consistencyRate >= 0.8) {
      highlights.add('${(consistencyRate * 100).toStringAsFixed(0)}% consistency rate - amazing!');
    }

    return highlights;
  }

  List<String> _generateRecommendations(
      {required int totalWorkouts,
      required double consistencyRate,
      required Map<String, double> averageMacros}) {
    final recommendations = <String>[];

    if (totalWorkouts < 3) {
      recommendations.add('Try to hit at least 3 workouts next week');
    }

    if (consistencyRate < 0.6) {
      recommendations.add('Focus on consistency - aim for 4-5 workouts per week');
    }

    final protein = averageMacros['protein'] ?? 0;
    if (protein < 100) {
      recommendations.add('Consider increasing protein intake to support muscle growth');
    }

    return recommendations;
  }
}
