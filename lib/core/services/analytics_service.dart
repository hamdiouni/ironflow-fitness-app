import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking analytics events throughout the app
/// Provides centralized analytics tracking with Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
      );

  // ============================================================================
  // USER EVENTS
  // ============================================================================

  /// Track app opened
  Future<void> logAppOpened() async {
    await _logEvent('app_opened');
  }

  /// Track user sign up
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Track user login
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Track user logout
  Future<void> logLogout() async {
    await _logEvent('logout');
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? fitnessLevel,
    String? goal,
    int? daysSinceInstall,
  }) async {
    if (fitnessLevel != null) {
      await _analytics.setUserProperty(
        name: 'fitness_level',
        value: fitnessLevel,
      );
    }
    if (goal != null) {
      await _analytics.setUserProperty(
        name: 'fitness_goal',
        value: goal,
      );
    }
    if (daysSinceInstall != null) {
      await _analytics.setUserProperty(
        name: 'days_since_install',
        value: daysSinceInstall.toString(),
      );
    }
  }

  // ============================================================================
  // WORKOUT EVENTS
  // ============================================================================

  /// Track workout started
  Future<void> logWorkoutStarted({
    required String workoutId,
    String? workoutName,
    String? programName,
  }) async {
    await _logEvent('workout_started', parameters: {
      'workout_id': workoutId,
      if (workoutName != null) 'workout_name': workoutName,
      if (programName != null) 'program_name': programName,
    });
  }

  /// Track workout completed
  Future<void> logWorkoutCompleted({
    required String workoutId,
    required int durationMinutes,
    required int exerciseCount,
    required int setCount,
    String? workoutName,
  }) async {
    await _logEvent('workout_completed', parameters: {
      'workout_id': workoutId,
      'duration_minutes': durationMinutes,
      'exercise_count': exerciseCount,
      'set_count': setCount,
      if (workoutName != null) 'workout_name': workoutName,
    });
  }

  /// Track workout cancelled
  Future<void> logWorkoutCancelled({
    required String workoutId,
    required int durationMinutes,
  }) async {
    await _logEvent('workout_cancelled', parameters: {
      'workout_id': workoutId,
      'duration_minutes': durationMinutes,
    });
  }

  /// Track exercise added to workout
  Future<void> logExerciseAdded({
    required String exerciseId,
    required String exerciseName,
    String? muscleGroup,
  }) async {
    await _logEvent('exercise_added', parameters: {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
    });
  }

  /// Track set completed
  Future<void> logSetCompleted({
    required String exerciseId,
    required int setNumber,
    required double weight,
    required int reps,
  }) async {
    await _logEvent('set_completed', parameters: {
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
    });
  }

  /// Track rest timer started
  Future<void> logRestTimerStarted({
    required int durationSeconds,
  }) async {
    await _logEvent('rest_timer_started', parameters: {
      'duration_seconds': durationSeconds,
    });
  }

  /// Track rest timer completed
  Future<void> logRestTimerCompleted({
    required int durationSeconds,
  }) async {
    await _logEvent('rest_timer_completed', parameters: {
      'duration_seconds': durationSeconds,
    });
  }

  /// Track rest timer skipped
  Future<void> logRestTimerSkipped({
    required int remainingSeconds,
  }) async {
    await _logEvent('rest_timer_skipped', parameters: {
      'remaining_seconds': remainingSeconds,
    });
  }

  // ============================================================================
  // NUTRITION EVENTS
  // ============================================================================

  /// Track meal logged
  Future<void> logMealLogged({
    required String mealType,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    await _logEvent('meal_logged', parameters: {
      'meal_type': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    });
  }

  /// Track food item added
  Future<void> logFoodItemAdded({
    required String foodName,
    required int calories,
  }) async {
    await _logEvent('food_item_added', parameters: {
      'food_name': foodName,
      'calories': calories,
    });
  }

  /// Track nutrition goal set
  Future<void> logNutritionGoalSet({
    required int calorieGoal,
    required double proteinGoal,
    required double carbsGoal,
    required double fatGoal,
  }) async {
    await _logEvent('nutrition_goal_set', parameters: {
      'calorie_goal': calorieGoal,
      'protein_goal': proteinGoal,
      'carbs_goal': carbsGoal,
      'fat_goal': fatGoal,
    });
  }

  // ============================================================================
  // AI EVENTS
  // ============================================================================

  /// Track AI query sent
  Future<void> logAIQuery({
    required String queryType,
    required String query,
    int? responseLength,
  }) async {
    await _logEvent('ai_query', parameters: {
      'query_type': queryType,
      'query_length': query.length,
      if (responseLength != null) 'response_length': responseLength,
    });
  }

  /// Track AI voice used
  Future<void> logAIVoiceUsed({
    required String voicePersona,
    required double speed,
    required double pitch,
  }) async {
    await _logEvent('ai_voice_used', parameters: {
      'voice_persona': voicePersona,
      'speed': speed,
      'pitch': pitch,
    });
  }

  /// Track AI image generation
  Future<void> logAIImageGeneration({
    required String prompt,
    required bool success,
  }) async {
    await _logEvent('ai_image_generation', parameters: {
      'prompt_length': prompt.length,
      'success': success,
    });
  }

  // ============================================================================
  // PROGRESS EVENTS
  // ============================================================================

  /// Track progress photo added
  Future<void> logProgressPhotoAdded() async {
    await _logEvent('progress_photo_added');
  }

  /// Track body measurement added
  Future<void> logBodyMeasurementAdded({
    required String measurementType,
    required double value,
  }) async {
    await _logEvent('body_measurement_added', parameters: {
      'measurement_type': measurementType,
      'value': value,
    });
  }

  /// Track progress chart viewed
  Future<void> logProgressChartViewed({
    required String chartType,
  }) async {
    await _logEvent('progress_chart_viewed', parameters: {
      'chart_type': chartType,
    });
  }

  // ============================================================================
  // FEATURE USAGE EVENTS
  // ============================================================================

  /// Track feature used
  Future<void> logFeatureUsed({
    required String featureName,
    Map<String, dynamic>? additionalParams,
  }) async {
    await _logEvent('feature_used', parameters: {
      'feature_name': featureName,
      ...?additionalParams,
    });
  }

  /// Track screen viewed
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Track search performed
  Future<void> logSearch({
    required String searchTerm,
    required String searchCategory,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        'search_category': searchCategory,
      },
    );
  }

  /// Track share action
  Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: 'app_share',
    );
  }

  // ============================================================================
  // ERROR EVENTS
  // ============================================================================

  /// Track error occurred
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _logEvent('error_occurred', parameters: {
      'error_type': errorType,
      'error_message': errorMessage,
      if (stackTrace != null) 'has_stack_trace': true,
    });
  }

  // ============================================================================
  // ENGAGEMENT EVENTS
  // ============================================================================

  /// Track tutorial started
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  /// Track tutorial completed
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }

  /// Track level up (e.g., fitness level progression)
  Future<void> logLevelUp({
    required int level,
    String? character,
  }) async {
    await _analytics.logLevelUp(
      level: level,
      character: character,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Log custom event
  Future<void> _logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    try {
      // Convert Map<String, Object?> to Map<String, Object> by filtering out null values
      final nonNullParameters = parameters?.map((key, value) => MapEntry(key, value ?? ''))
          .cast<String, Object>();
      
      await _analytics.logEvent(
        name: name,
        parameters: nonNullParameters,
      );
      if (kDebugMode) {
        print('📊 Analytics: $name ${parameters ?? ""}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Analytics error: $e');
      }
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Reset analytics data (e.g., on logout)
  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }
}
