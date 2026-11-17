import 'package:progression_tracker/core/utils/app_logger.dart';
import '../../domain/services/change_detection_service.dart';
import '../../domain/entities/insight.dart';
import '../../../workout/domain/entities/workout.dart';
import '../../../workout/domain/repositories/workout_repository.dart';
import '../../../nutrition/domain/entities/daily_nutrition_summary.dart';
import '../../../nutrition/domain/repositories/nutrition_repository.dart';
import '../../../body/domain/entities/body_entry.dart';
import '../../../body/domain/repositories/body_repository.dart';

/// Implementation of [ChangeDetectionService] for tracking data changes (Wave 7.2).
///
/// Uses `limit: 1` pagination for workouts and nutrition while detecting:
/// 1. New records (`date.isAfter(lastGenerated)`)
/// 2. In-place edits (`updatedAt.isAfter(lastGenerated)`)
/// 3. Deletions (when the top record ID or meal/body count changes between checks).
class ChangeDetectionServiceImpl implements ChangeDetectionService {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;

  String? _lastTopWorkoutId;
  bool _hadWorkoutPreviously = false;
  int? _lastTopDayMealCount;
  bool _hadNutritionPreviously = false;
  int? _lastObservedBodyCount;

  ChangeDetectionServiceImpl({
    required WorkoutRepository workoutRepository,
    required NutritionRepository nutritionRepository,
    required BodyRepository bodyRepository,
  })  : _workoutRepository = workoutRepository,
        _nutritionRepository = nutritionRepository,
        _bodyRepository = bodyRepository;

  /// Computes a deterministic integer epoch for a user's current dataset across
  /// workouts, nutrition logs, and body entries so caches invalidate on any
  /// insert, edit (`updatedAt`), or delete (count change).
  static int computeDataEpoch({
    List<Workout> workouts = const [],
    List<DailyNutritionSummary> nutrition = const [],
    List<BodyEntry> bodyEntries = const [],
  }) {
    var maxMillis = 0;
    var totalMeals = 0;

    for (final w in workouts) {
      final d = w.date.millisecondsSinceEpoch;
      final u = w.updatedAt?.millisecondsSinceEpoch ?? d;
      if (d > maxMillis) maxMillis = d;
      if (u > maxMillis) maxMillis = u;
    }

    for (final day in nutrition) {
      totalMeals += day.meals.length;
      final dayMs = day.date.millisecondsSinceEpoch;
      if (dayMs > maxMillis) maxMillis = dayMs;
      for (final m in day.meals) {
        final t = m.timestamp.millisecondsSinceEpoch;
        final u = m.updatedAt?.millisecondsSinceEpoch ?? t;
        if (t > maxMillis) maxMillis = t;
        if (u > maxMillis) maxMillis = u;
      }
    }

    for (final b in bodyEntries) {
      final d = b.date.millisecondsSinceEpoch;
      final u = b.updatedAt?.millisecondsSinceEpoch ?? d;
      if (d > maxMillis) maxMillis = d;
      if (u > maxMillis) maxMillis = u;
    }

    return Object.hash(
      workouts.length,
      totalMeals,
      bodyEntries.length,
      maxMillis,
    );
  }

  static DateTime _effectiveWorkoutTime(Workout w) {
    final updated = w.updatedAt;
    if (updated != null && updated.isAfter(w.date)) {
      return updated;
    }
    return w.date;
  }

  static DateTime _effectiveBodyTime(BodyEntry b) {
    final updated = b.updatedAt;
    if (updated != null && updated.isAfter(b.date)) {
      return updated;
    }
    return b.date;
  }

  @override
  Future<bool> hasWorkoutDataChanged(DateTime lastGenerated) async {
    try {
      AppLogger.debug('🔍 [ChangeDetection] Checking workout data changes...');
      final recentWorkouts = await _workoutRepository.getWorkoutsPaginated(
        offset: 0,
        limit: 1,
      );

      if (recentWorkouts.isEmpty) {
        final deletedAll = _hadWorkoutPreviously;
        _hadWorkoutPreviously = false;
        _lastTopWorkoutId = null;
        return deletedAll;
      }

      final latestWorkout = recentWorkouts.first;
      final previousTopId = _lastTopWorkoutId;
      _hadWorkoutPreviously = true;
      _lastTopWorkoutId = latestWorkout.id;

      // Detect top-record deletion or replacement even if dates are older
      if (previousTopId != null && previousTopId != latestWorkout.id) {
        return true;
      }

      return _effectiveWorkoutTime(latestWorkout).isAfter(lastGenerated);
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [ChangeDetection] Failed to check workout data changes: $e');
      AppLogger.debug('🔍 [ChangeDetection] Stack trace: $stackTrace');
      return true;
    }
  }

  @override
  Future<bool> hasNutritionDataChanged(DateTime lastGenerated) async {
    try {
      AppLogger.debug('🔍 [ChangeDetection] Checking nutrition data changes...');
      final recentNutrition = await _nutritionRepository.getNutritionHistoryPaginated(
        offset: 0,
        limit: 1,
      );

      if (recentNutrition.isEmpty) {
        final deletedAll = _hadNutritionPreviously;
        _hadNutritionPreviously = false;
        _lastTopDayMealCount = null;
        return deletedAll;
      }

      final latestNutrition = recentNutrition.first;
      final mealCount = latestNutrition.meals.length;
      final previousMealCount = _lastTopDayMealCount;
      _hadNutritionPreviously = true;
      _lastTopDayMealCount = mealCount;

      if (previousMealCount != null && previousMealCount != mealCount) {
        return true;
      }

      DateTime? mostRecentMealTime;
      for (final meal in latestNutrition.meals) {
        final mealTime = (meal.updatedAt != null &&
                meal.updatedAt!.isAfter(meal.timestamp))
            ? meal.updatedAt!
            : meal.timestamp;
        if (mostRecentMealTime == null || mealTime.isAfter(mostRecentMealTime)) {
          mostRecentMealTime = mealTime;
        }
      }

      final latestDataTime = mostRecentMealTime ?? latestNutrition.date;
      return latestDataTime.isAfter(lastGenerated);
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [ChangeDetection] Failed to check nutrition data changes: $e');
      AppLogger.debug('🔍 [ChangeDetection] Stack trace: $stackTrace');
      return true;
    }
  }

  @override
  Future<bool> hasBodyDataChanged(DateTime lastGenerated) async {
    try {
      AppLogger.debug('🔍 [ChangeDetection] Checking body data changes...');
      final allBodyEntries = await _bodyRepository.getAllBodyEntries();

      final currentCount = allBodyEntries.length;
      final previousCount = _lastObservedBodyCount;
      _lastObservedBodyCount = currentCount;

      if (previousCount != null && currentCount != previousCount) {
        return true;
      }

      if (allBodyEntries.isEmpty) {
        return false;
      }

      for (final entry in allBodyEntries) {
        if (_effectiveBodyTime(entry).isAfter(lastGenerated)) {
          return true;
        }
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [ChangeDetection] Failed to check body data changes: $e');
      AppLogger.debug('🔍 [ChangeDetection] Stack trace: $stackTrace');
      return true;
    }
  }

  @override
  Future<DateTime?> getLastDataChange(InsightContext context) async {
    try {
      final timestamps = <DateTime>[];

      switch (context) {
        case InsightContext.home:
          await _addWorkoutTimestamp(timestamps);
          await _addNutritionTimestamp(timestamps);
          await _addBodyTimestamp(timestamps);
          break;
        case InsightContext.workout:
          await _addWorkoutTimestamp(timestamps);
          break;
        case InsightContext.nutrition:
          await _addNutritionTimestamp(timestamps);
          break;
        case InsightContext.profile:
          await _addBodyTimestamp(timestamps);
          await _addWorkoutTimestamp(timestamps);
          break;
      }

      if (timestamps.isEmpty) {
        return null;
      }

      timestamps.sort((a, b) => b.compareTo(a));
      return timestamps.first;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [ChangeDetection] Failed to get last data change for context ${context.name}: $e');
      AppLogger.debug('🔍 [ChangeDetection] Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> _addWorkoutTimestamp(List<DateTime> timestamps) async {
    try {
      final recentWorkouts = await _workoutRepository.getWorkoutsPaginated(
        offset: 0,
        limit: 1,
      );
      if (recentWorkouts.isNotEmpty) {
        timestamps.add(_effectiveWorkoutTime(recentWorkouts.first));
      }
    } catch (e) {
      AppLogger.debug('⚠️ [ChangeDetection] Failed to get workout timestamp: $e');
    }
  }

  Future<void> _addNutritionTimestamp(List<DateTime> timestamps) async {
    try {
      final recentNutrition = await _nutritionRepository.getNutritionHistoryPaginated(
        offset: 0,
        limit: 1,
      );
      if (recentNutrition.isNotEmpty) {
        final latestNutrition = recentNutrition.first;
        DateTime? mostRecentMealTime;
        for (final meal in latestNutrition.meals) {
          final mealTime = (meal.updatedAt != null &&
                  meal.updatedAt!.isAfter(meal.timestamp))
              ? meal.updatedAt!
              : meal.timestamp;
          if (mostRecentMealTime == null || mealTime.isAfter(mostRecentMealTime)) {
            mostRecentMealTime = mealTime;
          }
        }
        timestamps.add(mostRecentMealTime ?? latestNutrition.date);
      }
    } catch (e) {
      AppLogger.debug('⚠️ [ChangeDetection] Failed to get nutrition timestamp: $e');
    }
  }

  Future<void> _addBodyTimestamp(List<DateTime> timestamps) async {
    try {
      final allBodyEntries = await _bodyRepository.getAllBodyEntries();
      if (allBodyEntries.isNotEmpty) {
        timestamps.add(_effectiveBodyTime(allBodyEntries.first));
      }
    } catch (e) {
      AppLogger.debug('⚠️ [ChangeDetection] Failed to get body timestamp: $e');
    }
  }
}
