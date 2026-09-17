import 'package:progression_tracker/features/analytics/domain/entities/consistency_metrics.dart';
import 'package:progression_tracker/features/analytics/domain/entities/performance_prediction.dart';
import 'package:progression_tracker/features/analytics/domain/entities/strength_progression.dart';
import 'package:progression_tracker/features/analytics/domain/entities/weight_tracking.dart';
import 'package:progression_tracker/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

/// Implementation of [AnalyticsRepository].
///
/// Aggregates data from workout and body repositories to calculate analytics.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final WorkoutRepository _workoutRepository;
  final BodyRepository _bodyRepository;

  AnalyticsRepositoryImpl(
    this._workoutRepository,
    this._bodyRepository,
  );

  @override
  Future<StrengthProgression> getStrengthProgression({
    required String exerciseId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get workouts in date range
    final workouts = await _workoutRepository.getWorkoutsByDateRange(
      startDate,
      endDate,
    );

    // Extract exercise data points
    final dataPoints = <StrengthDataPoint>[];
    String? exerciseName;
    String? muscleGroup;

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.id == exerciseId) {
          exerciseName ??= exercise.name;
          muscleGroup ??= exercise.muscleGroup?.toString() ?? 'Unknown';

          // Calculate volume and 1RM for this session
          double totalVolume = 0;
          double maxWeight = 0;
          int totalReps = 0;
          int totalSets = exercise.sets.length;

          for (final set in exercise.sets) {
            final weight = set.weight ?? 0;
            final reps = set.reps ?? 0;
            totalVolume += weight * reps;
            if (weight > maxWeight) maxWeight = weight;
            totalReps += reps;
          }

          // Estimate 1RM using Epley formula: weight * (1 + reps/30)
          final avgReps = totalSets > 0 ? totalReps / totalSets : 0;
          final estimated1RM = maxWeight * (1 + avgReps / 30);

          dataPoints.add(StrengthDataPoint(
            date: workout.date,
            weight: maxWeight,
            reps: avgReps.round(),
            sets: totalSets,
            volume: totalVolume,
            estimatedOneRepMax: estimated1RM,
          ));
        }
      }
    }

    // Sort by date
    dataPoints.sort((a, b) => a.date.compareTo(b.date));

    // Calculate current and previous 1RM
    final current1RM = dataPoints.isNotEmpty
        ? dataPoints.last.estimatedOneRepMax
        : 0.0;
    final previous1RM = dataPoints.length > 1
        ? dataPoints[dataPoints.length ~/ 2].estimatedOneRepMax
        : current1RM;

    // Calculate percentage change
    final percentageChange = previous1RM > 0
        ? ((current1RM - previous1RM) / previous1RM) * 100
        : 0.0;

    // Calculate total volume
    final totalVolume = dataPoints.fold<double>(
      0,
      (sum, point) => sum + point.volume,
    );

    return StrengthProgression(
      exerciseId: exerciseId,
      exerciseName: exerciseName ?? 'Unknown',
      muscleGroup: muscleGroup ?? 'Unknown',
      dataPoints: dataPoints,
      currentOneRepMax: current1RM,
      previousOneRepMax: previous1RM,
      percentageChange: percentageChange,
      totalVolume: totalVolume,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<StrengthProgression>> getAllStrengthProgressions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get all workouts in date range
    final workouts = await _workoutRepository.getWorkoutsByDateRange(
      startDate,
      endDate,
    );

    // Collect unique exercise IDs
    final exerciseIds = <String>{};
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        exerciseIds.add(exercise.id);
      }
    }

    // Get progression for each exercise
    final progressions = <StrengthProgression>[];
    for (final exerciseId in exerciseIds) {
      final progression = await getStrengthProgression(
        exerciseId: exerciseId,
        startDate: startDate,
        endDate: endDate,
      );
      progressions.add(progression);
    }

    return progressions;
  }

  @override
  Future<WeightTracking> getWeightTracking({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get weight measurements from body repository
    final measurements = await _bodyRepository.getWeightHistory(
      startDate: startDate,
      endDate: endDate,
    );

    // Convert to WeightMeasurement entities
    final weightMeasurements = measurements.map((m) {
      return WeightMeasurement(
        date: m.date,
        weight: m.weight,
        note: m.note,
        bodyFatPercentage: m.bodyFatPercentage,
        muscleMass: m.muscleMass,
      );
    }).toList();

    // Sort by date
    weightMeasurements.sort((a, b) => a.date.compareTo(b.date));

    // Calculate metrics
    final currentWeight = weightMeasurements.isNotEmpty
        ? weightMeasurements.last.weight
        : 0.0;
    final startingWeight = weightMeasurements.isNotEmpty
        ? weightMeasurements.first.weight
        : 0.0;
    final goalWeight = await _bodyRepository.getGoalWeight() ?? currentWeight;

    final totalChange = currentWeight - startingWeight;

    // Calculate average weekly change
    final weeks = (endDate.difference(startDate).inDays / 7).ceil();
    final averageWeeklyChange = weeks > 0 ? totalChange / weeks : 0.0;

    // Project goal date
    DateTime? projectedGoalDate;
    if (averageWeeklyChange.abs() > 0.1) {
      final remainingChange = goalWeight - currentWeight;
      final weeksToGoal = (remainingChange / averageWeeklyChange).abs();
      projectedGoalDate = DateTime.now().add(Duration(days: (weeksToGoal * 7).round()));
    }

    return WeightTracking(
      userId: userId,
      measurements: weightMeasurements,
      currentWeight: currentWeight,
      startingWeight: startingWeight,
      goalWeight: goalWeight,
      totalChange: totalChange,
      averageWeeklyChange: averageWeeklyChange,
      projectedGoalDate: projectedGoalDate,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<ConsistencyMetrics> getConsistencyMetrics({
    required String userId,
    required UserProfile? userProfile,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get workouts in date range
    final workouts = await _workoutRepository.getWorkoutsByDateRange(
      startDate,
      endDate,
    );

    final totalWorkouts = workouts.length;
    final totalWeeks = (endDate.difference(startDate).inDays / 7).ceil();
    final averageWorkoutsPerWeek = totalWeeks > 0
        ? totalWorkouts / totalWeeks
        : 0.0;

    // Calculate streaks
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    final sortedWorkouts = List.from(workouts);
    sortedWorkouts.sort((a, b) => a.date.compareTo(b.date));

    for (final workout in sortedWorkouts) {
      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final daysDiff = workout.date.difference(lastDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else {
          if (tempStreak > longestStreak) longestStreak = tempStreak;
          tempStreak = 1;
        }
      }
      lastDate = workout.date;
    }

    if (tempStreak > longestStreak) longestStreak = tempStreak;
    currentStreak = tempStreak;

    // Calculate adherence using user's workoutDaysPerWeek
    final targetWorkouts = totalWeeks * (userProfile?.workoutDaysPerWeek ?? 1);
    final adherenceRate = targetWorkouts > 0
        ? (totalWorkouts / targetWorkouts).clamp(0.0, 1.0)
        : 0.0;

    // Calculate weekly data
    final weeklyData = <WeeklyConsistency>[];
    for (int i = 0; i < totalWeeks; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekWorkouts = workouts.where(
        (w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd),
      ).toList();

      final dailyStatus = List.generate(7, (day) {
        final date = weekStart.add(Duration(days: day));
        return weekWorkouts.any((w) =>
          w.date.year == date.year &&
          w.date.month == date.month &&
          w.date.day == date.day
        );
      });

      final weekVolume = weekWorkouts.fold<double>(
        0,
        (sum, w) => sum + (w.totalVolume ?? 0),
      );

      weeklyData.add(WeeklyConsistency(
        weekStart: weekStart,
        workoutsCompleted: weekWorkouts.length,
        workoutsPlanned: userProfile?.workoutDaysPerWeek ?? 1,
        dailyStatus: dailyStatus,
        totalVolume: weekVolume,
        adherenceRate: (weekWorkouts.length / (userProfile?.workoutDaysPerWeek ?? 1)).clamp(0.0, 1.0),
      ));
    }

    // Find most/least active days
    final dayCount = List.filled(7, 0);
    for (final workout in workouts) {
      dayCount[workout.date.weekday - 1]++;
    }

    int mostActiveDay = 0;
    int leastActiveDay = 0;
    int maxCount = dayCount[0];
    int minCount = dayCount[0];

    for (int i = 1; i < 7; i++) {
      if (dayCount[i] > maxCount) {
        maxCount = dayCount[i];
        mostActiveDay = i;
      }
      if (dayCount[i] < minCount) {
        minCount = dayCount[i];
        leastActiveDay = i;
      }
    }

    // Calculate average duration
    final totalDuration = workouts.fold<int>(
      0,
      (sum, w) => sum + (w.duration ?? 0),
    );
    final averageDuration = totalWorkouts > 0
        ? totalDuration / totalWorkouts
        : 0.0;

    return ConsistencyMetrics(
      userId: userId,
      totalWorkouts: totalWorkouts,
      totalWeeks: totalWeeks,
      averageWorkoutsPerWeek: averageWorkoutsPerWeek,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      adherenceRate: adherenceRate,
      weeklyData: weeklyData,
      mostActiveDay: mostActiveDay,
      leastActiveDay: leastActiveDay,
      averageDuration: averageDuration,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<PerformancePrediction> predictPerformance({
    required String userId,
    required int predictionDays,
  }) async {
    // Get historical data (last 90 days)
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 90));

    // Get all strength progressions
    final progressions = await getAllStrengthProgressions(
      startDate: startDate,
      endDate: endDate,
    );

    // Generate exercise predictions
    final exercisePredictions = <ExercisePrediction>[];
    for (final progression in progressions) {
      if (progression.dataPoints.length < 3) continue; // Need at least 3 data points

      // Simple linear regression for prediction
      final current1RM = progression.currentOneRepMax;
      final improvementRate = progression.percentageChange / 90; // per day
      final predicted1RM = current1RM * (1 + (improvementRate * predictionDays / 100));

      final improvementPercentage = ((predicted1RM - current1RM) / current1RM) * 100;

      // Generate recommendation based on trend
      String recommendation;
      if (progression.trend == ProgressionTrend.increasing) {
        recommendation = 'Continue current program. Consider progressive overload.';
      } else if (progression.trend == ProgressionTrend.decreasing) {
        recommendation = 'Review form and recovery. Consider deload week.';
      } else {
        recommendation = 'Increase volume or intensity to break plateau.';
      }

      exercisePredictions.add(ExercisePrediction(
        exerciseId: progression.exerciseId,
        exerciseName: progression.exerciseName,
        currentOneRepMax: current1RM,
        predictedOneRepMax: predicted1RM,
        improvementPercentage: improvementPercentage,
        trainingRecommendation: recommendation,
        confidence: _calculateConfidence(progression.dataPoints.length),
        dataPointsUsed: progression.dataPoints.length,
      ));
    }

    // Calculate overall strength prediction
    final avgImprovement = exercisePredictions.isNotEmpty
        ? exercisePredictions.fold<double>(
            0,
            (sum, p) => sum + p.improvementPercentage,
          ) / exercisePredictions.length
        : 0.0;

    final overallStrength = OverallPrediction(
      currentValue: 100.0,
      predictedValue: 100.0 + avgImprovement,
      change: avgImprovement,
      percentageChange: avgImprovement,
      trend: _getTrendFromPercentage(avgImprovement),
      recommendation: _getOverallRecommendation(avgImprovement),
      confidence: _calculateConfidence(exercisePredictions.length),
    );

    // Calculate consistency prediction
    final metrics = await getConsistencyMetrics(
      userId: userId,
      userProfile: null, // TODO: Pass userProfile when available in predictPerformance
      startDate: startDate,
      endDate: endDate,
    );

    final consistency = OverallPrediction(
      currentValue: metrics.adherenceRate * 100,
      predictedValue: metrics.adherenceRate * 100,
      change: 0.0,
      percentageChange: 0.0,
      trend: PredictionTrend.stable,
      recommendation: metrics.isConsistent
          ? 'Maintain current consistency'
          : 'Aim for 75% adherence rate',
      confidence: 0.8,
    );

    return PerformancePrediction(
      userId: userId,
      exercisePredictions: exercisePredictions,
      overallStrength: overallStrength,
      consistency: consistency,
      confidenceLevel: _calculateConfidence(exercisePredictions.length),
      generatedAt: DateTime.now(),
      predictionDays: predictionDays,
    );
  }

  double _calculateConfidence(int dataPoints) {
    if (dataPoints >= 10) return 0.9;
    if (dataPoints >= 5) return 0.7;
    if (dataPoints >= 3) return 0.5;
    return 0.3;
  }

  PredictionTrend _getTrendFromPercentage(double percentage) {
    if (percentage > 10) return PredictionTrend.strongIncrease;
    if (percentage > 5) return PredictionTrend.increase;
    if (percentage < -10) return PredictionTrend.strongDecrease;
    if (percentage < -5) return PredictionTrend.decrease;
    return PredictionTrend.stable;
  }

  String _getOverallRecommendation(double improvement) {
    if (improvement > 10) {
      return 'Excellent progress! Continue current training approach.';
    } else if (improvement > 5) {
      return 'Good progress. Consider increasing training volume.';
    } else if (improvement > 0) {
      return 'Slow progress. Review program and nutrition.';
    } else {
      return 'No progress detected. Consider program change or deload.';
    }
  }
}
