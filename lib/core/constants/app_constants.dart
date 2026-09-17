/// Application-wide constants
class AppConstants {
  // Timing constants
  static const int defaultRestTimerSeconds = 90;
  static const int animationFeedbackMs = 100;
  static const int prAnimationMs = 200;
  static const int navigationTransitionMs = 200;
  static const int graphAnimationMs = 300;
  static const int macroWheelAnimationMs = 200;
  static const int debounceMs = 300;
  static const int timerUpdateMs = 100;

  // Performance constants
  static const int lazyLoadThreshold = 20;
  static const int maxChartDataPoints = 100;
  static const int storageRetryAttempts = 1;
  static const int storageRetryDelayMs = 100;

  // UI constants
  static const double cardBorderRadius = 16.0;
  static const double largeBorderRadius = 24.0;
  static const double glassOpacity = 0.5;
  static const double glassBlur = 10.0;

  // Workout constants
  static const int maxTapsForAction = 3;
  static const int exerciseHistoryLimit = 3;
  static const int prHistoryLimit = 100;
  static const double progressionWeightIncrease = 1.05; // 5% increase

  // Nutrition constants
  static const double proteinCaloriesPerGram = 4.0;
  static const double carbsCaloriesPerGram = 4.0;
  static const double fatsCaloriesPerGram = 9.0;

  // Default macro targets
  static const double defaultProteinTarget = 150.0;
  static const double defaultCarbsTarget = 200.0;
  static const double defaultFatsTarget = 60.0;

  // Meal suggestion thresholds
  static const double highProteinThreshold = 30.0;
  static const double highCarbThreshold = 40.0;
  static const double balancedProteinThreshold = 20.0;
  static const double balancedCarbThreshold = 30.0;
  static const double balancedFatThreshold = 10.0;

  // Storage box names
  static const String workoutsBoxName = 'workouts';
  static const String bodyEntriesBoxName = 'body_entries';
  static const String mealsBoxName = 'meals';
  static const String macroTargetsBoxName = 'macro_targets';
  static const String appStateBoxName = 'app_state';

  // State keys
  static const String activeWorkoutStateKey = 'active_workout_state';

  // Validation limits
  static const int minReps = 1;
  static const int maxReps = 1000;
  static const double minWeight = 0.0;
  static const double maxWeight = 10000.0;
  static const int minRPE = 1;
  static const int maxRPE = 10;

  // Private constructor to prevent instantiation
  AppConstants._();
}
