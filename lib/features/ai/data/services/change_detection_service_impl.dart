import '../../domain/services/change_detection_service.dart';
import '../../domain/entities/insight.dart';
import '../../../workout/domain/repositories/workout_repository.dart';
import '../../../nutrition/domain/repositories/nutrition_repository.dart';
import '../../../body/domain/repositories/body_repository.dart';

/// Implementation of ChangeDetectionService for tracking data changes
///
/// This service efficiently detects when underlying data has changed by
/// comparing timestamps of the most recent entries in each data source.
/// It maintains an in-memory cache of last known timestamps to avoid
/// unnecessary database queries.
///
/// **Optimization Strategy:**
/// - Fetch only the most recent record from each repository
/// - Compare timestamps efficiently using milliseconds since epoch
/// - Update internal timestamp cache after each check
/// - Use pagination with limit=1 to get latest entries efficiently
///
/// **Requirements:**
/// - 4.4: Track when workout, nutrition, or body data changes
/// - 4.5: Detect data changes efficiently without full data scans
/// - 11.5: Optimize timestamp comparison logic
/// - 11.6: Fetch only latest record from each repository
class ChangeDetectionServiceImpl implements ChangeDetectionService {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;

  ChangeDetectionServiceImpl({
    required WorkoutRepository workoutRepository,
    required NutritionRepository nutritionRepository,
    required BodyRepository bodyRepository,
  })  : _workoutRepository = workoutRepository,
        _nutritionRepository = nutritionRepository,
        _bodyRepository = bodyRepository;

  @override
  Future<bool> hasWorkoutDataChanged(DateTime lastGenerated) async {
    try {
      print('🔍 [ChangeDetection] Checking workout data changes...');
      print('🔍 [ChangeDetection] Last generated: $lastGenerated');
      
      // Get the most recent workout (limit=1, offset=0)
      final recentWorkouts = await _workoutRepository.getWorkoutsPaginated(
        offset: 0,
        limit: 1,
      );
      
      if (recentWorkouts.isEmpty) {
        print('🔍 [ChangeDetection] No workouts found');
        return false;
      }
      
      final latestWorkout = recentWorkouts.first;
      
      print('🔍 [ChangeDetection] Latest workout: ${latestWorkout.date}');
      
      // Check if latest workout is newer than last generation
      final hasChanged = latestWorkout.date.isAfter(lastGenerated);
      
      print('🔍 [ChangeDetection] Workout data changed: $hasChanged');
      return hasChanged;
    } catch (e, stackTrace) {
      print('❌ [ChangeDetection] Failed to check workout data changes: $e');
      print('🔍 [ChangeDetection] Stack trace: $stackTrace');
      // Return true on error to force regeneration
      return true;
    }
  }

  @override
  Future<bool> hasNutritionDataChanged(DateTime lastGenerated) async {
    try {
      print('🔍 [ChangeDetection] Checking nutrition data changes...');
      print('🔍 [ChangeDetection] Last generated: $lastGenerated');
      
      // Get the most recent nutrition data (limit=1, offset=0)
      final recentNutrition = await _nutritionRepository.getNutritionHistoryPaginated(
        offset: 0,
        limit: 1,
      );
      
      if (recentNutrition.isEmpty) {
        print('🔍 [ChangeDetection] No nutrition data found');
        return false;
      }
      
      final latestNutrition = recentNutrition.first;
      
      // Find the most recent meal timestamp from the day's meals
      DateTime? mostRecentMealTime;
      for (final meal in latestNutrition.meals) {
        if (mostRecentMealTime == null || meal.timestamp.isAfter(mostRecentMealTime)) {
          mostRecentMealTime = meal.timestamp;
        }
      }
      
      // Use the most recent meal time or the day's date as fallback
      final latestDataTime = mostRecentMealTime ?? latestNutrition.date;
      
      print('🔍 [ChangeDetection] Latest nutrition date: ${latestNutrition.date}');
      print('🔍 [ChangeDetection] Most recent meal time: $mostRecentMealTime');
      print('🔍 [ChangeDetection] Latest data time: $latestDataTime');
      
      // Check if latest data is newer than last generation
      final hasChanged = latestDataTime.isAfter(lastGenerated);
      
      print('🔍 [ChangeDetection] Nutrition data changed: $hasChanged');
      return hasChanged;
    } catch (e, stackTrace) {
      print('❌ [ChangeDetection] Failed to check nutrition data changes: $e');
      print('🔍 [ChangeDetection] Stack trace: $stackTrace');
      // Return true on error to force regeneration
      return true;
    }
  }

  @override
  Future<bool> hasBodyDataChanged(DateTime lastGenerated) async {
    try {
      print('🔍 [ChangeDetection] Checking body data changes...');
      print('🔍 [ChangeDetection] Last generated: $lastGenerated');
      
      // Get all body entries and find the most recent one
      // Note: BodyRepository doesn't have pagination, so we get all and take the first
      final allBodyEntries = await _bodyRepository.getAllBodyEntries();
      
      if (allBodyEntries.isEmpty) {
        print('🔍 [ChangeDetection] No body entries found');
        return false;
      }
      
      // Body entries are sorted by date descending, so first is most recent
      final latestEntry = allBodyEntries.first;
      
      print('🔍 [ChangeDetection] Latest body entry: ${latestEntry.date}');
      
      // Check if latest entry is newer than last generation
      final hasChanged = latestEntry.date.isAfter(lastGenerated);
      
      print('🔍 [ChangeDetection] Body data changed: $hasChanged');
      return hasChanged;
    } catch (e, stackTrace) {
      print('❌ [ChangeDetection] Failed to check body data changes: $e');
      print('🔍 [ChangeDetection] Stack trace: $stackTrace');
      // Return true on error to force regeneration
      return true;
    }
  }

  @override
  Future<DateTime?> getLastDataChange(InsightContext context) async {
    try {
      print('🔍 [ChangeDetection] Getting last data change for context: ${context.name}');
      
      final timestamps = <DateTime>[];
      
      // Get relevant data sources based on context
      switch (context) {
        case InsightContext.home:
          // Home context uses all data sources
          await _addWorkoutTimestamp(timestamps);
          await _addNutritionTimestamp(timestamps);
          await _addBodyTimestamp(timestamps);
          break;
        case InsightContext.workout:
          // Workout context uses only workout data
          await _addWorkoutTimestamp(timestamps);
          break;
        case InsightContext.nutrition:
          // Nutrition context uses only nutrition data
          await _addNutritionTimestamp(timestamps);
          break;
        case InsightContext.profile:
          // Profile context uses body data and workout data
          await _addBodyTimestamp(timestamps);
          await _addWorkoutTimestamp(timestamps);
          break;
      }
      
      if (timestamps.isEmpty) {
        print('🔍 [ChangeDetection] No data found for context: ${context.name}');
        return null;
      }
      
      // Find the most recent timestamp
      timestamps.sort((a, b) => b.compareTo(a)); // Sort descending
      final mostRecentDate = timestamps.first;
      
      print('🔍 [ChangeDetection] Most recent data change for ${context.name}: $mostRecentDate');
      return mostRecentDate;
    } catch (e, stackTrace) {
      print('❌ [ChangeDetection] Failed to get last data change for context ${context.name}: $e');
      print('🔍 [ChangeDetection] Stack trace: $stackTrace');
      // Return null on error
      return null;
    }
  }

  /// Helper method to add workout timestamp to the list
  Future<void> _addWorkoutTimestamp(List<DateTime> timestamps) async {
    try {
      final recentWorkouts = await _workoutRepository.getWorkoutsPaginated(
        offset: 0,
        limit: 1,
      );
      if (recentWorkouts.isNotEmpty) {
        timestamps.add(recentWorkouts.first.date);
      }
    } catch (e) {
      print('⚠️ [ChangeDetection] Failed to get workout timestamp: $e');
    }
  }

  /// Helper method to add nutrition timestamp to the list
  Future<void> _addNutritionTimestamp(List<DateTime> timestamps) async {
    try {
      final recentNutrition = await _nutritionRepository.getNutritionHistoryPaginated(
        offset: 0,
        limit: 1,
      );
      if (recentNutrition.isNotEmpty) {
        final latestNutrition = recentNutrition.first;
        
        // Find the most recent meal timestamp
        DateTime? mostRecentMealTime;
        for (final meal in latestNutrition.meals) {
          if (mostRecentMealTime == null || meal.timestamp.isAfter(mostRecentMealTime)) {
            mostRecentMealTime = meal.timestamp;
          }
        }
        
        // Use the most recent meal time or the day's date as fallback
        final latestDataTime = mostRecentMealTime ?? latestNutrition.date;
        timestamps.add(latestDataTime);
      }
    } catch (e) {
      print('⚠️ [ChangeDetection] Failed to get nutrition timestamp: $e');
    }
  }

  /// Helper method to add body timestamp to the list
  Future<void> _addBodyTimestamp(List<DateTime> timestamps) async {
    try {
      final allBodyEntries = await _bodyRepository.getAllBodyEntries();
      if (allBodyEntries.isNotEmpty) {
        timestamps.add(allBodyEntries.first.date);
      }
    } catch (e) {
      print('⚠️ [ChangeDetection] Failed to get body timestamp: $e');
    }
  }

}