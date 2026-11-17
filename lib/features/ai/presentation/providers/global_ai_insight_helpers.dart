import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/local_date_window.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/change_detection_service.dart';
import 'package:progression_tracker/features/ai/domain/services/insight_cache_service.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:uuid/uuid.dart';

/// Stateless helper functions extracted from [GlobalAINotifier] to keep
/// provider orchestration focused and concise.
class GlobalAIInsightHelpers {
  const GlobalAIInsightHelpers._();

  /// Check if data has changed for a specific context since [since].
  static Future<bool> hasDataChangedForContext({
    required ChangeDetectionService changeDetectionService,
    required InsightContext context,
    required DateTime since,
  }) async {
    try {
      switch (context) {
        case InsightContext.home:
          final workoutChanged =
              await changeDetectionService.hasWorkoutDataChanged(since);
          final nutritionChanged =
              await changeDetectionService.hasNutritionDataChanged(since);
          final bodyChanged =
              await changeDetectionService.hasBodyDataChanged(since);
          return workoutChanged || nutritionChanged || bodyChanged;
        case InsightContext.workout:
          return await changeDetectionService.hasWorkoutDataChanged(since);
        case InsightContext.nutrition:
          return await changeDetectionService.hasNutritionDataChanged(since);
        case InsightContext.profile:
          final workoutChanged =
              await changeDetectionService.hasWorkoutDataChanged(since);
          final bodyChanged =
              await changeDetectionService.hasBodyDataChanged(since);
          return workoutChanged || bodyChanged;
      }
    } catch (e) {
      AppLogger.debug(
        '⚠️ [GlobalAI] Failed to check data changes for ${context.name}: $e',
      );
      return true;
    }
  }

  /// Build [InsightGenerationContext] with only the data required for [context].
  static Future<InsightGenerationContext> buildInsightGenerationContext({
    required InsightContext context,
    required WorkoutRepository workoutRepository,
    required NutritionRepository nutritionRepository,
    required BodyRepository bodyRepository,
    NutritionTargets? nutritionTargets,
    UnitsSystem units = UnitsSystem.metric,
  }) async {
    final now = DateTime.now();
    final thirtyDaysAgo = LocalDateWindow.rollingDaysWindow(30, now: now).start;
    final sevenDaysAgo = LocalDateWindow.rollingDaysWindow(7, now: now).start;

    final needsWorkouts = context == InsightContext.home ||
        context == InsightContext.workout ||
        context == InsightContext.profile;
    final needsNutrition =
        context == InsightContext.home || context == InsightContext.nutrition;
    final needsBody =
        context == InsightContext.home || context == InsightContext.profile;

    try {
      final futures = <Future<dynamic>>[
        needsWorkouts
            ? workoutRepository.getWorkoutsByDateRange(thirtyDaysAgo, now)
            : Future.value(<Workout>[]),
        needsNutrition
            ? nutritionRepository.getNutritionHistory(sevenDaysAgo, now)
            : Future.value(<DailyNutritionSummary>[]),
        needsBody
            ? bodyRepository.getBodyEntriesByDateRange(thirtyDaysAgo, now)
            : Future.value(<BodyEntry>[]),
      ];

      final results = await Future.wait(futures);
      final workouts = results[0] as List<Workout>;
      final nutrition = results[1] as List<DailyNutritionSummary>;
      final bodyEntries = results[2] as List<BodyEntry>;

      AppLogger.debug(
        '🔍 [GlobalAI] Fetched data for ${context.name}: '
        '${workouts.length} workouts, ${nutrition.length} nutrition days, '
        '${bodyEntries.length} body entries',
      );

      return InsightGenerationContext(
        context: context,
        profile: null,
        recentWorkouts: workouts,
        nutritionHistory: nutrition,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
        generatedAt: now,
        units: units,
      );
    } catch (e) {
      AppLogger.debug(
        '⚠️ [GlobalAI] Failed to fetch some data for ${context.name}: $e',
      );
      return InsightGenerationContext(
        context: context,
        profile: null,
        recentWorkouts: const [],
        nutritionHistory: const [],
        nutritionTargets: nutritionTargets,
        bodyEntries: const [],
        generatedAt: now,
        units: units,
      );
    }
  }

  /// Update Hive cache with newly generated insights.
  static Future<void> updateHiveCache({
    required InsightCacheService cacheService,
    required ChangeDetectionService changeDetectionService,
    required InsightContext context,
    required List<Insight> insights,
    required DateTime cachedAt,
  }) async {
    try {
      final dataTimestamps = <String, DateTime>{};

      final lastWorkoutChange =
          await changeDetectionService.getLastDataChange(InsightContext.workout);
      if (lastWorkoutChange != null) {
        dataTimestamps['workout'] = lastWorkoutChange;
      }

      final lastNutritionChange = await changeDetectionService
          .getLastDataChange(InsightContext.nutrition);
      if (lastNutritionChange != null) {
        dataTimestamps['nutrition'] = lastNutritionChange;
      }

      final lastBodyChange =
          await changeDetectionService.getLastDataChange(InsightContext.profile);
      if (lastBodyChange != null) {
        dataTimestamps['body'] = lastBodyChange;
      }

      final cache = InsightCache(
        context: context,
        insights: insights,
        cachedAt: cachedAt,
        dataTimestamps: dataTimestamps,
      );

      await cacheService.cacheInsights(cache);
      AppLogger.debug('✅ [GlobalAI] Updated Hive cache for ${context.name}');
    } catch (e) {
      AppLogger.debug(
        '⚠️ [GlobalAI] Failed to update Hive cache for ${context.name}: $e',
      );
    }
  }

  /// Generate generic motivational fallback insights when generation fails and
  /// no cached insights are available.
  static List<Insight> generateFallbackInsights(InsightContext context) {
    const uuid = Uuid();
    final now = DateTime.now();

    switch (context) {
      case InsightContext.home:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Welcome to Your Fitness Journey',
            message:
                'Start logging workouts and meals to get personalized coaching insights that help you reach your goals faster.',
            icon: '🎯',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Consistency is Key',
            message:
                'The most successful fitness journeys start with small, consistent actions. Log your first workout or meal today!',
            icon: '📈',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
      case InsightContext.workout:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Track Your Progress',
            message:
                'Log your workouts to see strength gains, volume trends, and get personalized training recommendations.',
            icon: '💪',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Progressive Overload',
            message:
                'Gradually increase weight, reps, or sets each week to build strength and muscle effectively.',
            icon: '⬆️',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
      case InsightContext.nutrition:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Fuel Your Goals',
            message:
                'Track your meals to ensure you\'re eating enough protein and calories to support your training.',
            icon: '🍽️',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Protein Matters',
            message:
                'Aim for 1.6-2.2g of protein per kg of body weight daily to maximize muscle growth and recovery.',
            icon: '🥩',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
      case InsightContext.profile:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Your Journey Starts Here',
            message:
                'Track your body weight and measurements to monitor progress toward your fitness goals.',
            icon: '📊',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Long-term Success',
            message:
                'Focus on sustainable habits rather than quick fixes. Small changes compound into big results over time.',
            icon: '🌱',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
    }
  }
}

