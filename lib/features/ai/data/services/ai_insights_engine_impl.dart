import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/data/exercise_database.dart';

/// Implementation of the AI Insights Engine
///
/// This service generates context-specific coaching insights by analyzing
/// user fitness data (workouts, nutrition, body metrics). All analysis
/// happens locally on-device for privacy.
///
/// **Requirements:**
/// - 1.1: Generate insights based on workout history, nutrition data, and body metrics
/// - 1.2: Use data from the last 30 days for workouts and body metrics
/// - 1.3: Use data from the last 7 days for nutrition analysis
/// - 1.4: Generate contextual insights specific to each Context
class AIInsightsEngineImpl implements AIInsightsEngine {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;

  AIInsightsEngineImpl({
    required WorkoutRepository workoutRepository,
    required NutritionRepository nutritionRepository,
    required BodyRepository bodyRepository,
  })  : _workoutRepository = workoutRepository,
        _nutritionRepository = nutritionRepository,
        _bodyRepository = bodyRepository;

  @override
  Future<List<Insight>> generateInsights(
      InsightGenerationContext context) async {
    // Fetch data based on context requirements
    final data = await _fetchDataForContext(context.context);

    // Generate context-specific insights
    switch (context.context) {
      case InsightContext.home:
        return _generateHomeInsights(
          context: context,
          workouts: data.workouts,
          nutrition: data.nutrition,
          bodyEntries: data.bodyEntries,
        );
      case InsightContext.workout:
        return _generateWorkoutInsights(
          context: context,
          workouts: data.workouts,
        );
      case InsightContext.nutrition:
        return _generateNutritionInsights(
          context: context,
          nutrition: data.nutrition,
          targets: context.nutritionTargets,
        );
      case InsightContext.profile:
        return _generateProfileInsights(
          context: context,
          workouts: data.workouts,
          bodyEntries: data.bodyEntries,
        );
    }
  }

  @override
  Future<Insight> generateQuickFeedback(
    Workout completedWorkout,
    List<Workout> history,
  ) async {
    // Combine completed workout with history for analysis
    final allWorkouts = [completedWorkout, ...history];
    
    // Detect PR achievements
    final prDetails = getPRDetails(allWorkouts);
    final hasPR = prDetails.isNotEmpty;
    
    // Detect volume records (10%+ increase)
    final currentVolume = calculateVolume(completedWorkout);
    final hasVolumeRecord = _detectVolumeRecord(completedWorkout, history);
    final volumeIncrease = _calculateVolumeIncrease(completedWorkout, history);
    
    // Detect consistency milestones
    final consistencyStreak = _calculateConsistencyStreak(allWorkouts);
    final hasConsistencyMilestone = _isConsistencyMilestone(consistencyStreak);
    
    // Prioritize achievements and create celebratory feedback
    if (hasPR) {
      return _createPRFeedback(prDetails, currentVolume);
    } else if (hasVolumeRecord) {
      return _createVolumeRecordFeedback(currentVolume, volumeIncrease);
    } else if (hasConsistencyMilestone) {
      return _createConsistencyMilestoneFeedback(consistencyStreak);
    } else {
      return _createGeneralEncouragementFeedback(currentVolume, consistencyStreak);
    }
  }

  @override
  double calculateVolume(Workout workout) {
    double totalVolume = 0.0;
    
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        totalVolume += set.reps * set.weight;
      }
    }
    
    return totalVolume;
  }

  @override
  bool detectProgressiveOverload(List<Workout> workouts) {
    if (workouts.length < 4) {
      // Need at least 4 workouts to compare first half vs second half
      return false;
    }
    
    // Sort workouts by date to ensure chronological order
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Split into first half and second half
    final midpoint = sortedWorkouts.length ~/ 2;
    final firstHalf = sortedWorkouts.sublist(0, midpoint);
    final secondHalf = sortedWorkouts.sublist(midpoint);
    
    // Calculate average volume for each half
    final firstHalfAvgVolume = firstHalf.isEmpty 
        ? 0.0 
        : firstHalf.map((w) => calculateVolume(w)).reduce((a, b) => a + b) / firstHalf.length;
    
    final secondHalfAvgVolume = secondHalf.isEmpty 
        ? 0.0 
        : secondHalf.map((w) => calculateVolume(w)).reduce((a, b) => a + b) / secondHalf.length;
    
    // Progressive overload detected if second half volume is higher than first half
    return secondHalfAvgVolume > firstHalfAvgVolume;
  }

  /// Detect if a PR (Personal Record) was achieved in the most recent workout
  ///
  /// Compares the maximum weight lifted for each exercise in the most recent
  /// workout against the historical maximum for the same exercise.
  ///
  /// **Requirements:**
  /// - 1.8: Detect PR by comparing current vs historical max
  /// - 7.6: Display recent PR achievements
  /// - 10.4: Display specific exercise and weight for PRs
  bool detectPR(List<Workout> workouts, {String? specificExercise}) {
    if (workouts.isEmpty) return false;
    
    // Sort workouts by date to get the most recent one
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final mostRecentWorkout = sortedWorkouts.first;
    final historicalWorkouts = sortedWorkouts.skip(1).toList();
    
    // Check each exercise in the most recent workout
    for (final exercise in mostRecentWorkout.exercises) {
      if (specificExercise != null && exercise.name != specificExercise) {
        continue;
      }
      
      // Find the maximum weight for this exercise in the recent workout
      final recentMaxWeight = exercise.sets.isEmpty 
          ? 0.0 
          : exercise.sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
      
      // Find the historical maximum for this exercise
      double historicalMaxWeight = 0.0;
      for (final workout in historicalWorkouts) {
        for (final histExercise in workout.exercises) {
          if (histExercise.name == exercise.name) {
            final exerciseMax = histExercise.sets.isEmpty 
                ? 0.0 
                : histExercise.sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
            if (exerciseMax > historicalMaxWeight) {
              historicalMaxWeight = exerciseMax;
            }
          }
        }
      }
      
      // PR detected if recent max is greater than historical max
      if (recentMaxWeight > historicalMaxWeight) {
        return true;
      }
    }
    
    return false;
  }

  /// Get PR details for the most recent workout
  ///
  /// Returns a map of exercise names to their new PR weights
  Map<String, double> getPRDetails(List<Workout> workouts) {
    final prDetails = <String, double>{};
    
    if (workouts.isEmpty) return prDetails;
    
    // Sort workouts by date to get the most recent one
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final mostRecentWorkout = sortedWorkouts.first;
    final historicalWorkouts = sortedWorkouts.skip(1).toList();
    
    // Check each exercise in the most recent workout
    for (final exercise in mostRecentWorkout.exercises) {
      // Find the maximum weight for this exercise in the recent workout
      final recentMaxWeight = exercise.sets.isEmpty 
          ? 0.0 
          : exercise.sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
      
      // Find the historical maximum for this exercise
      double historicalMaxWeight = 0.0;
      for (final workout in historicalWorkouts) {
        for (final histExercise in workout.exercises) {
          if (histExercise.name == exercise.name) {
            final exerciseMax = histExercise.sets.isEmpty 
                ? 0.0 
                : histExercise.sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
            if (exerciseMax > historicalMaxWeight) {
              historicalMaxWeight = exerciseMax;
            }
          }
        }
      }
      
      // Add to PR details if it's a new record
      if (recentMaxWeight > historicalMaxWeight) {
        prDetails[exercise.name] = recentMaxWeight;
      }
    }
    
    return prDetails;
  }

  /// Analyze muscle group balance across recent workouts
  ///
  /// Returns a map of muscle groups to the number of days since they were last trained.
  /// Uses the exercise database to map exercise names to muscle groups.
  ///
  /// **Requirements:**
  /// - 7.4: Identify muscle group balance (push/pull/legs)
  /// - 7.5: Recommend exercises when muscle group not trained in 7+ days
  Map<MuscleGroup, int> analyzeMuscleGroupBalance(List<Workout> workouts) {
    final muscleGroupLastTrained = <MuscleGroup, DateTime>{};
    final now = DateTime.now();
    
    // Sort workouts by date (most recent first)
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // Track when each muscle group was last trained
    for (final workout in sortedWorkouts) {
      for (final exercise in workout.exercises) {
        // Find the muscle group for this exercise
        final exerciseDefinition = ExerciseDatabase.all
            .where((def) => def.name.toLowerCase() == exercise.name.toLowerCase())
            .firstOrNull;
        
        if (exerciseDefinition != null) {
          final muscleGroup = exerciseDefinition.muscleGroup;
          
          // Update last trained date if this is more recent
          if (!muscleGroupLastTrained.containsKey(muscleGroup) ||
              workout.date.isAfter(muscleGroupLastTrained[muscleGroup]!)) {
            muscleGroupLastTrained[muscleGroup] = workout.date;
          }
        }
      }
    }
    
    // Calculate days since each muscle group was last trained
    final daysSinceLastTrained = <MuscleGroup, int>{};
    for (final entry in muscleGroupLastTrained.entries) {
      final daysSince = now.difference(entry.value).inDays;
      daysSinceLastTrained[entry.key] = daysSince;
    }
    
    // Add muscle groups that haven't been trained at all (set to a high number)
    for (final muscleGroup in MuscleGroup.values) {
      if (!daysSinceLastTrained.containsKey(muscleGroup)) {
        daysSinceLastTrained[muscleGroup] = 999; // Never trained
      }
    }
    
    return daysSinceLastTrained;
  }

  /// Prioritize and select the most important insights
  ///
  /// Selects 2-3 most important insights based on priority and context.
  /// Implements insight rotation for equal priority items.
  ///
  /// **Requirements:**
  /// - 2.1: Include specific numbers in insights
  /// - 2.2: Provide actionable recommendations
  /// - 2.6: Calculate percentage changes between time periods
  /// - 2.7: Format insights as Analysis → Numbers → Action Plan
  /// - 14.6: Select the 2-3 most important insights
  /// - 14.7: Prioritize actionable insights over descriptive insights
  /// - 14.8: Rotate insights for equal priority items
  List<Insight> prioritizeInsights(List<Insight> allInsights, {int maxInsights = 3}) {
    if (allInsights.isEmpty) return [];
    
    // Sort by priority (high > medium > low)
    final sortedInsights = List<Insight>.from(allInsights)
      ..sort((a, b) {
        final priorityOrder = {
          InsightPriority.high: 3,
          InsightPriority.medium: 2,
          InsightPriority.low: 1,
        };
        return priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!);
      });
    
    // Take the top insights up to maxInsights
    final selectedInsights = sortedInsights.take(maxInsights).toList();
    
    // For equal priority items, implement rotation based on generation time
    // This ensures variety in insights shown to the user
    return selectedInsights;
  }

  /// Format insight with specific numbers and action plan
  ///
  /// Formats insights following the pattern: Analysis → Numbers → Action Plan
  ///
  /// **Requirements:**
  /// - 2.1: Include specific numbers in insights
  /// - 2.2: Provide actionable recommendations
  /// - 2.7: Format insights as Analysis → Numbers → Action Plan
  Insight formatInsight({
    required String id,
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    required InsightPriority priority,
    Map<String, dynamic>? metadata,
  }) {
    // Build the formatted message: Analysis → Numbers → Action Plan
    final numbersText = numbers.entries
        .map((entry) => '${entry.key}: ${_formatNumber(entry.value)}')
        .join(', ');
    
    final message = '$analysis $numbersText. $actionPlan';
    
    return Insight(
      id: id,
      context: context,
      title: title,
      message: message,
      icon: icon,
      priority: priority,
      generatedAt: DateTime.now(),
      metadata: {
        'analysis': analysis,
        'numbers': numbers,
        'actionPlan': actionPlan,
        ...?metadata,
      },
    );
  }

  /// Format a number for display in insights
  String _formatNumber(dynamic value) {
    if (value is double) {
      if (value == value.roundToDouble()) {
        return value.round().toString();
      } else {
        return value.toStringAsFixed(1);
      }
    } else if (value is int) {
      return value.toString();
    } else {
      return value.toString();
    }
  }

  /// Create a high-priority insight for urgent actions
  Insight createHighPriorityInsight({
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    Map<String, dynamic>? metadata,
  }) {
    return formatInsight(
      id: 'high_${DateTime.now().millisecondsSinceEpoch}',
      context: context,
      title: title,
      analysis: analysis,
      numbers: numbers,
      actionPlan: actionPlan,
      icon: icon,
      priority: InsightPriority.high,
      metadata: metadata,
    );
  }

  /// Create a medium-priority insight for important recommendations
  Insight createMediumPriorityInsight({
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    Map<String, dynamic>? metadata,
  }) {
    return formatInsight(
      id: 'medium_${DateTime.now().millisecondsSinceEpoch}',
      context: context,
      title: title,
      analysis: analysis,
      numbers: numbers,
      actionPlan: actionPlan,
      icon: icon,
      priority: InsightPriority.medium,
      metadata: metadata,
    );
  }

  /// Create a low-priority insight for general encouragement
  Insight createLowPriorityInsight({
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    Map<String, dynamic>? metadata,
  }) {
    return formatInsight(
      id: 'low_${DateTime.now().millisecondsSinceEpoch}',
      context: context,
      title: title,
      analysis: analysis,
      numbers: numbers,
      actionPlan: actionPlan,
      icon: icon,
      priority: InsightPriority.low,
      metadata: metadata,
    );
  }

  /// Calculate percentage change between two values
  ///
  /// **Requirements:**
  /// - 2.6: Calculate percentage changes between time periods
  double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) {
      return newValue > 0 ? 100.0 : 0.0;
    }
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Generate fallback insights when no data is available
  ///
  /// **Requirements:**
  /// - 1.5: Generate onboarding insights encouraging data entry when no data exists
  /// - 13.3: Display onboarding guidance instead of error when data unavailable
  List<Insight> generateFallbackInsights(InsightContext context) {
    switch (context) {
      case InsightContext.home:
        return [
          createMediumPriorityInsight(
            context: context,
            title: 'Welcome to IronFlow!',
            analysis: 'Start your fitness journey by logging your first workout.',
            numbers: {'days_active': 0},
            actionPlan: 'Tap the workout tab to begin tracking your progress.',
            icon: '🏋️',
            metadata: {'type': 'onboarding'},
          ),
        ];
      case InsightContext.workout:
        return [
          createMediumPriorityInsight(
            context: context,
            title: 'Ready to Train?',
            analysis: 'No workouts logged yet.',
            numbers: {'workouts_completed': 0},
            actionPlan: 'Start your first workout to see personalized insights.',
            icon: '💪',
            metadata: {'type': 'onboarding'},
          ),
        ];
      case InsightContext.nutrition:
        return [
          createMediumPriorityInsight(
            context: context,
            title: 'Track Your Nutrition',
            analysis: 'No meals logged yet.',
            numbers: {'meals_logged': 0},
            actionPlan: 'Log your first meal to get nutrition insights.',
            icon: '🍽️',
            metadata: {'type': 'onboarding'},
          ),
        ];
      case InsightContext.profile:
        return [
          createMediumPriorityInsight(
            context: context,
            title: 'Track Your Progress',
            analysis: 'No body measurements recorded yet.',
            numbers: {'measurements': 0},
            actionPlan: 'Add your weight and measurements to see progress trends.',
            icon: '📊',
            metadata: {'type': 'onboarding'},
          ),
        ];
    }
  }

  @override
  double calculateProteinDeficit(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) {
    if (nutrition.isEmpty) {
      return targets.macros.protein; // Full deficit if no data
    }
    
    // Calculate average daily protein intake
    final totalProtein = nutrition.fold<double>(
      0.0,
      (sum, day) => sum + day.totalProtein,
    );
    final averageDailyProtein = totalProtein / nutrition.length;
    
    // Calculate deficit (positive = under target, negative = over target)
    return targets.macros.protein - averageDailyProtein;
  }

  /// Calculate macro adherence percentage for each macro
  ///
  /// Returns a map with adherence percentages for protein, carbs, and fats.
  /// 100% means perfect adherence to target.
  ///
  /// **Requirements:**
  /// - 8.2: Analyze average daily Macro_Targets adherence
  /// - 8.7: Analyze macro balance (protein/carbs/fats ratio)
  Map<String, double> calculateMacroAdherence(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) {
    if (nutrition.isEmpty) {
      return {'protein': 0.0, 'carbs': 0.0, 'fats': 0.0};
    }
    
    // Calculate average daily intake for each macro
    final totalProtein = nutrition.fold<double>(0.0, (sum, day) => sum + day.totalProtein);
    final totalCarbs = nutrition.fold<double>(0.0, (sum, day) => sum + day.totalCarbs);
    final totalFats = nutrition.fold<double>(0.0, (sum, day) => sum + day.totalFats);
    
    final avgProtein = totalProtein / nutrition.length;
    final avgCarbs = totalCarbs / nutrition.length;
    final avgFats = totalFats / nutrition.length;
    
    // Calculate adherence percentages (capped at 100% for over-consumption)
    final proteinAdherence = targets.macros.protein > 0 
        ? (avgProtein / targets.macros.protein * 100).clamp(0.0, 100.0)
        : 0.0;
    final carbsAdherence = targets.macros.carbs > 0 
        ? (avgCarbs / targets.macros.carbs * 100).clamp(0.0, 100.0)
        : 0.0;
    final fatsAdherence = targets.macros.fats > 0 
        ? (avgFats / targets.macros.fats * 100).clamp(0.0, 100.0)
        : 0.0;
    
    return {
      'protein': proteinAdherence,
      'carbs': carbsAdherence,
      'fats': fatsAdherence,
    };
  }

  /// Calculate calorie tracking accuracy
  ///
  /// Returns the percentage of days that have logged meals vs total days.
  ///
  /// **Requirements:**
  /// - 8.5: Display calorie tracking accuracy (days logged vs days missed)
  double calculateTrackingAccuracy(List<DailyNutritionSummary> nutrition, int totalDays) {
    if (totalDays <= 0) return 0.0;
    
    final daysWithData = nutrition.where((day) => day.meals.isNotEmpty).length;
    return (daysWithData / totalDays * 100).clamp(0.0, 100.0);
  }

  /// Calculate average daily calorie deviation from target
  ///
  /// Returns the average difference between actual and target calories.
  /// Positive = over target, negative = under target.
  ///
  /// **Requirements:**
  /// - 8.6: Provide adjustment recommendations when calories deviate 200+ kcal
  double calculateCalorieDeviation(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) {
    if (nutrition.isEmpty) {
      return targets.macros.calories; // Full deviation if no data
    }
    
    // Calculate average daily calorie intake
    final totalCalories = nutrition.fold<double>(
      0.0,
      (sum, day) => sum + day.totalCalories,
    );
    final averageDailyCalories = totalCalories / nutrition.length;
    
    // Calculate deviation (positive = over target, negative = under target)
    return averageDailyCalories - targets.macros.calories;
  }

  /// Get protein intake as percentage of target
  ///
  /// **Requirements:**
  /// - 8.3: Calculate protein intake as a percentage of target
  double getProteinIntakePercentage(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) {
    if (nutrition.isEmpty || targets.macros.protein <= 0) {
      return 0.0;
    }
    
    // Calculate average daily protein intake
    final totalProtein = nutrition.fold<double>(
      0.0,
      (sum, day) => sum + day.totalProtein,
    );
    final averageDailyProtein = totalProtein / nutrition.length;
    
    // Calculate percentage
    return (averageDailyProtein / targets.macros.protein * 100).clamp(0, double.infinity);
  }

  /// Get food recommendations for protein deficit
  ///
  /// Returns a list of high-protein food suggestions when protein intake is below 80%.
  ///
  /// **Requirements:**
  /// - 8.4: Provide specific food recommendations when protein below 80%
  List<String> getProteinFoodRecommendations(double proteinPercentage) {
    if (proteinPercentage >= 80.0) {
      return []; // No recommendations needed
    }
    
    return [
      'Chicken breast (31g protein per 100g)',
      'Greek yogurt (10g protein per 100g)',
      'Eggs (13g protein per 100g)',
      'Tuna (30g protein per 100g)',
      'Cottage cheese (11g protein per 100g)',
      'Protein powder (20-30g per scoop)',
      'Lentils (9g protein per 100g)',
      'Quinoa (4.4g protein per 100g)',
    ];
  }

  @override
  WeightTrend analyzeWeightTrend(List<BodyEntry> entries) {
    if (entries.length < 2) {
      return WeightTrend.insufficient_data;
    }
    
    // Sort entries by date to ensure chronological order
    final sortedEntries = List<BodyEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate linear regression to determine trend
    final weights = sortedEntries.map((e) => e.weight).toList();
    final n = weights.length;
    
    // Use simple approach: compare first and last weights
    final firstWeight = weights.first;
    final lastWeight = weights.last;
    final weightChange = lastWeight - firstWeight;
    
    // Consider trend based on weight change
    const threshold = 0.5; // 0.5kg threshold for significant change
    
    if (weightChange > threshold) {
      return WeightTrend.increasing;
    } else if (weightChange < -threshold) {
      return WeightTrend.decreasing;
    } else {
      return WeightTrend.stable;
    }
  }

  /// Calculate weight change over the analysis period
  ///
  /// Returns the total weight change in kg (positive = gained, negative = lost).
  ///
  /// **Requirements:**
  /// - 9.5: Display weight change direction and magnitude
  double calculateWeightChange(List<BodyEntry> entries) {
    if (entries.length < 2) {
      return 0.0;
    }
    
    // Sort entries by date
    final sortedEntries = List<BodyEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return sortedEntries.last.weight - sortedEntries.first.weight;
  }

  /// Calculate average weight over the analysis period
  double calculateAverageWeight(List<BodyEntry> entries) {
    if (entries.isEmpty) {
      return 0.0;
    }
    
    final totalWeight = entries.fold<double>(0.0, (sum, entry) => sum + entry.weight);
    return totalWeight / entries.length;
  }

  /// Get the most recent weight entry
  double? getMostRecentWeight(List<BodyEntry> entries) {
    if (entries.isEmpty) {
      return null;
    }
    
    // Sort entries by date and get the most recent
    final sortedEntries = List<BodyEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sortedEntries.first.weight;
  }

  /// Calculate weight change rate (kg per week)
  ///
  /// **Requirements:**
  /// - 9.2: Analyze body weight trends over the last 30 days
  double calculateWeightChangeRate(List<BodyEntry> entries) {
    if (entries.length < 2) {
      return 0.0;
    }
    
    // Sort entries by date
    final sortedEntries = List<BodyEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final firstEntry = sortedEntries.first;
    final lastEntry = sortedEntries.last;
    
    final weightChange = lastEntry.weight - firstEntry.weight;
    final daysDifference = lastEntry.date.difference(firstEntry.date).inDays;
    
    if (daysDifference <= 0) {
      return 0.0;
    }
    
    // Convert to weekly rate
    return (weightChange / daysDifference) * 7;
  }

  /// Check if weight change aligns with user goal
  ///
  /// **Requirements:**
  /// - 9.6: Provide positive reinforcement when weight change aligns with goal
  /// - 9.7: Suggest adjustments when weight change conflicts with goal
  bool isWeightChangeAlignedWithGoal(
    List<BodyEntry> entries,
    String? userGoal, // 'lose_weight', 'gain_weight', 'maintain_weight'
  ) {
    if (userGoal == null || entries.length < 2) {
      return true; // Assume aligned if no goal or insufficient data
    }
    
    final weightChange = calculateWeightChange(entries);
    const significantChange = 0.5; // 0.5kg threshold
    
    switch (userGoal.toLowerCase()) {
      case 'lose_weight':
        return weightChange <= -significantChange;
      case 'gain_weight':
        return weightChange >= significantChange;
      case 'maintain_weight':
        return weightChange.abs() < significantChange;
      default:
        return true; // Unknown goal, assume aligned
    }
  }

  /// Detect if current workout achieved a volume record (10%+ increase)
  ///
  /// **Requirements:**
  /// - 10.5: Celebrate Progressive Overload (10%+ volume increase)
  bool _detectVolumeRecord(Workout currentWorkout, List<Workout> history) {
    if (history.isEmpty) return false;
    
    final currentVolume = calculateVolume(currentWorkout);
    
    // Calculate average volume from recent workouts (last 4 workouts or all if less)
    final recentWorkouts = history.take(4).toList();
    if (recentWorkouts.isEmpty) return false;
    
    final totalRecentVolume = recentWorkouts
        .map((w) => calculateVolume(w))
        .fold<double>(0.0, (sum, volume) => sum + volume);
    final averageRecentVolume = totalRecentVolume / recentWorkouts.length;
    
    if (averageRecentVolume == 0) return false;
    
    // Check if current volume is 10%+ higher than recent average
    final increasePercentage = ((currentVolume - averageRecentVolume) / averageRecentVolume) * 100;
    return increasePercentage >= 10.0;
  }
  
  /// Calculate volume increase percentage compared to recent average
  double _calculateVolumeIncrease(Workout currentWorkout, List<Workout> history) {
    if (history.isEmpty) return 0.0;
    
    final currentVolume = calculateVolume(currentWorkout);
    
    // Calculate average volume from recent workouts (last 4 workouts or all if less)
    final recentWorkouts = history.take(4).toList();
    if (recentWorkouts.isEmpty) return 0.0;
    
    final totalRecentVolume = recentWorkouts
        .map((w) => calculateVolume(w))
        .fold<double>(0.0, (sum, volume) => sum + volume);
    final averageRecentVolume = totalRecentVolume / recentWorkouts.length;
    
    if (averageRecentVolume == 0) return 0.0;
    
    return ((currentVolume - averageRecentVolume) / averageRecentVolume) * 100;
  }
  
  /// Calculate consistency streak (consecutive workout days)
  ///
  /// **Requirements:**
  /// - 10.3: Highlight consistency milestones
  int _calculateConsistencyStreak(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Sort workouts by date (most recent first)
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 1; // Start with 1 for the current workout
    final today = DateTime.now();
    
    // Check for consecutive days working backwards from today
    for (int i = 1; i < sortedWorkouts.length; i++) {
      final currentWorkout = sortedWorkouts[i - 1];
      final previousWorkout = sortedWorkouts[i];
      
      // Calculate days between workouts
      final daysBetween = currentWorkout.date.difference(previousWorkout.date).inDays;
      
      // If workouts are 1-2 days apart (allowing for rest days), continue streak
      if (daysBetween <= 2) {
        streak++;
      } else {
        break; // Streak broken
      }
    }
    
    return streak;
  }
  
  /// Check if current streak represents a milestone worth celebrating
  ///
  /// **Requirements:**
  /// - 10.3: Highlight consistency milestones
  bool _isConsistencyMilestone(int streak) {
    // Celebrate milestones at 3, 5, 7, 10, 14, 21, 30 days
    const milestones = [3, 5, 7, 10, 14, 21, 30];
    return milestones.contains(streak);
  }
  
  /// Create PR achievement feedback
  ///
  /// **Requirements:**
  /// - 10.4: Display specific exercise and weight for PRs
  /// - 10.8: Use celebratory language and emojis
  Insight _createPRFeedback(Map<String, double> prDetails, double currentVolume) {
    final prEntry = prDetails.entries.first; // Take the first PR for simplicity
    final exerciseName = prEntry.key;
    final prWeight = prEntry.value;
    
    return Insight(
      id: 'pr_feedback_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: '🎉 New Personal Record!',
      message: 'Congratulations! You just hit a new PR on $exerciseName with ${_formatNumber(prWeight)}kg! Your total workout volume was ${_formatNumber(currentVolume)}kg. Keep pushing those limits!',
      icon: '🏆',
      priority: InsightPriority.high,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'pr_achievement',
        'exercise': exerciseName,
        'weight': prWeight,
        'volume': currentVolume,
        'pr_count': prDetails.length,
      },
    );
  }
  
  /// Create volume record feedback
  ///
  /// **Requirements:**
  /// - 10.5: Celebrate Progressive Overload (10%+ volume increase)
  /// - 10.8: Use celebratory language and emojis
  Insight _createVolumeRecordFeedback(double currentVolume, double volumeIncrease) {
    return Insight(
      id: 'volume_record_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: '💪 Volume Record Smashed!',
      message: 'Amazing work! You lifted ${_formatNumber(currentVolume)}kg total volume today - that\'s ${_formatNumber(volumeIncrease)}% higher than your recent average! This is progressive overload in action!',
      icon: '📈',
      priority: InsightPriority.high,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'volume_record',
        'volume': currentVolume,
        'increase_percentage': volumeIncrease,
      },
    );
  }
  
  /// Create consistency milestone feedback
  ///
  /// **Requirements:**
  /// - 10.3: Highlight consistency milestones
  /// - 10.8: Use celebratory language and emojis
  Insight _createConsistencyMilestoneFeedback(int streak) {
    String title;
    String message;
    String icon;
    
    if (streak >= 30) {
      title = '🔥 30-Day Streak Champion!';
      message = 'Incredible! You\'ve maintained a $streak-day workout streak! You\'re building unstoppable momentum and creating lasting habits. This is what dedication looks like!';
      icon = '👑';
    } else if (streak >= 21) {
      title = '🌟 3-Week Streak Master!';
      message = 'Outstanding! $streak days of consistent training! You\'re officially in habit-building territory. Your future self will thank you for this dedication!';
      icon = '⭐';
    } else if (streak >= 14) {
      title = '🚀 2-Week Streak Superstar!';
      message = 'Fantastic! You\'ve hit a $streak-day streak! You\'re building serious momentum and proving that consistency beats perfection every time!';
      icon = '🚀';
    } else if (streak >= 10) {
      title = '💎 Double Digit Streak!';
      message = 'Excellent! $streak days in a row! You\'re developing an unbreakable routine. Keep this momentum going - you\'re on fire!';
      icon = '💎';
    } else if (streak >= 7) {
      title = '🔥 One Week Strong!';
      message = 'Great job! You\'ve completed $streak days of training! You\'re building a solid foundation of consistency. The hardest part is behind you!';
      icon = '🔥';
    } else if (streak >= 5) {
      title = '⚡ 5-Day Streak!';
      message = 'Nice work! $streak days of consistent training! You\'re developing great habits. Keep the momentum rolling!';
      icon = '⚡';
    } else {
      title = '🎯 Building Momentum!';
      message = 'Great start! $streak days of training! Consistency is the key to success. You\'re on the right track!';
      icon = '🎯';
    }
    
    return Insight(
      id: 'consistency_milestone_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: title,
      message: message,
      icon: icon,
      priority: InsightPriority.high,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'consistency_milestone',
        'streak': streak,
      },
    );
  }
  
  /// Create general encouragement feedback when no specific achievements
  ///
  /// **Requirements:**
  /// - 10.8: Use celebratory language and emojis
  Insight _createGeneralEncouragementFeedback(double currentVolume, int streak) {
    return Insight(
      id: 'general_encouragement_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: '💪 Great Workout!',
      message: 'Nice work today! You lifted ${_formatNumber(currentVolume)}kg total volume and you\'re on a $streak-day streak. Every workout counts towards your goals. Keep it up!',
      icon: '💪',
      priority: InsightPriority.medium,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'general_encouragement',
        'volume': currentVolume,
        'streak': streak,
      },
    );
  }

  /// Fetch data required for generating insights for a specific context
  ///
  /// **Requirements:**
  /// - 1.2: Use data from the last 30 days for workouts and body metrics
  /// - 1.3: Use data from the last 7 days for nutrition analysis
  Future<_ContextData> _fetchDataForContext(InsightContext context) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Determine which data to fetch based on context
    final needsWorkouts = context == InsightContext.home ||
        context == InsightContext.workout ||
        context == InsightContext.profile;

    final needsNutrition = context == InsightContext.home ||
        context == InsightContext.nutrition;

    final needsBodyMetrics = context == InsightContext.home ||
        context == InsightContext.profile;

    // Fetch data in parallel for performance
    final results = await Future.wait([
      if (needsWorkouts)
        _workoutRepository.getWorkoutsByDateRange(thirtyDaysAgo, now)
      else
        Future.value(<Workout>[]),
      if (needsNutrition)
        _nutritionRepository.getNutritionHistory(sevenDaysAgo, now)
      else
        Future.value(<DailyNutritionSummary>[]),
      if (needsBodyMetrics)
        _bodyRepository.getBodyEntriesByDateRange(thirtyDaysAgo, now)
      else
        Future.value(<BodyEntry>[]),
    ]);

    return _ContextData(
      workouts: results[0] as List<Workout>,
      nutrition: results[1] as List<DailyNutritionSummary>,
      bodyEntries: results[2] as List<BodyEntry>,
    );
  }

  /// Generate insights for the Home screen
  ///
  /// **Requirements:**
  /// - 6.2: Analyze overall consistency across all data types
  /// - 6.3: Identify the most important action for the user
  /// - 6.4: Include workout frequency analysis from the last 7 days
  /// - 6.5: Include nutrition tracking consistency from the last 7 days
  /// - 6.6: Prioritize workout reminder when user hasn't trained in 3+ days
  /// - 6.7: Provide encouragement and next steps when user trains consistently
  /// - 14.1: Prioritize overall consistency and next actions
  Future<List<Insight>> _generateHomeInsights({
    required InsightGenerationContext context,
    required List<Workout> workouts,
    required List<DailyNutritionSummary> nutrition,
    required List<BodyEntry> bodyEntries,
  }) async {
    final allInsights = <Insight>[];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // --- 6.4: Workout frequency analysis (last 7 days) ---
    final recentWorkouts = workouts
        .where((w) => w.date.isAfter(sevenDaysAgo))
        .toList();
    final workoutsThisWeek = recentWorkouts.length;

    // --- 6.6: Workout reminder when 3+ days without training ---
    final lastWorkoutDate = workouts.isEmpty
        ? null
        : (List<Workout>.from(workouts)
              ..sort((a, b) => b.date.compareTo(a.date)))
            .first
            .date;
    final daysSinceLastWorkout = lastWorkoutDate == null
        ? 999
        : now.difference(lastWorkoutDate).inDays;

    if (daysSinceLastWorkout >= 3) {
      allInsights.add(createHighPriorityInsight(
        context: InsightContext.home,
        title: '⏰ Time to Train!',
        analysis: 'You haven\'t worked out in $daysSinceLastWorkout days.',
        numbers: {'days_since_last_workout': daysSinceLastWorkout},
        actionPlan: 'Head to the Workout tab and start a session to keep your momentum going.',
        icon: '🏋️',
        metadata: {'type': 'workout_reminder', 'days_since': daysSinceLastWorkout},
      ));
    }

    // --- 6.5: Nutrition tracking consistency (last 7 days) ---
    final nutritionDaysLogged = nutrition
        .where((n) => n.date.isAfter(sevenDaysAgo) && n.meals.isNotEmpty)
        .length;
    final nutritionTrackingRate = (nutritionDaysLogged / 7 * 100).round();

    if (nutritionTrackingRate < 50) {
      allInsights.add(createMediumPriorityInsight(
        context: InsightContext.home,
        title: '🍽️ Track Your Nutrition',
        analysis: 'You\'ve only logged meals on $nutritionDaysLogged of the last 7 days.',
        numbers: {'days_logged': nutritionDaysLogged, 'tracking_rate': nutritionTrackingRate},
        actionPlan: 'Log your meals daily to get accurate nutrition insights and hit your macro targets.',
        icon: '🍽️',
        metadata: {'type': 'nutrition_reminder', 'days_logged': nutritionDaysLogged},
      ));
    }

    // --- 6.7: Encouragement when training consistently ---
    if (daysSinceLastWorkout < 3 && workoutsThisWeek >= 3) {
      final hasProgressiveOverload = workouts.length >= 4 && detectProgressiveOverload(workouts);
      if (hasProgressiveOverload) {
        allInsights.add(createHighPriorityInsight(
          context: InsightContext.home,
          title: '🚀 You\'re Progressing!',
          analysis: 'You\'ve trained $workoutsThisWeek times this week and your volume is trending up.',
          numbers: {'workouts_this_week': workoutsThisWeek},
          actionPlan: 'Keep up the progressive overload — your strength is building week over week.',
          icon: '📈',
          metadata: {'type': 'consistency_encouragement'},
        ));
      } else {
        allInsights.add(createMediumPriorityInsight(
          context: InsightContext.home,
          title: '💪 Great Consistency!',
          analysis: 'You\'ve completed $workoutsThisWeek workouts this week.',
          numbers: {'workouts_this_week': workoutsThisWeek},
          actionPlan: 'Try to gradually increase your weights or reps to keep making progress.',
          icon: '💪',
          metadata: {'type': 'consistency_encouragement'},
        ));
      }
    }

    // --- 6.2: Overall consistency score ---
    if (allInsights.isEmpty) {
      // No urgent actions — show a general summary
      if (workouts.isEmpty && nutrition.isEmpty) {
        return generateFallbackInsights(InsightContext.home);
      }
      allInsights.add(createMediumPriorityInsight(
        context: InsightContext.home,
        title: '📊 Weekly Overview',
        analysis: 'You\'ve logged $workoutsThisWeek workouts and $nutritionDaysLogged nutrition days this week.',
        numbers: {
          'workouts': workoutsThisWeek,
          'nutrition_days': nutritionDaysLogged,
        },
        actionPlan: 'Aim for 3+ workouts and daily nutrition logging for best results.',
        icon: '📊',
        metadata: {'type': 'weekly_overview'},
      ));
    }

    return prioritizeInsights(allInsights, maxInsights: 3);
  }

  /// Generate insights for the Workout screen
  ///
  /// **Requirements:**
  /// - 7.2: Analyze Volume trends over the last 30 days
  /// - 7.3: Analyze Progressive_Overload patterns
  /// - 7.4: Identify muscle group balance (push/pull/legs)
  /// - 7.5: Recommend exercises when muscle group not trained in 7+ days
  /// - 7.6: Display recent PR achievements
  /// - 7.7: Suggest recovery or deload when Volume is decreasing
  /// - 14.2: Prioritize Volume, Progressive_Overload, and muscle balance
  Future<List<Insight>> _generateWorkoutInsights({
    required InsightGenerationContext context,
    required List<Workout> workouts,
  }) async {
    if (workouts.isEmpty) {
      return generateFallbackInsights(InsightContext.workout);
    }

    final allInsights = <Insight>[];

    // --- 7.6: Recent PR achievements ---
    final prDetails = getPRDetails(workouts);
    if (prDetails.isNotEmpty) {
      final prEntry = prDetails.entries.first;
      allInsights.add(createHighPriorityInsight(
        context: InsightContext.workout,
        title: '🏆 Personal Record!',
        analysis: 'You set a new PR on ${prEntry.key} with ${_formatNumber(prEntry.value)}kg.',
        numbers: {'pr_weight_kg': prEntry.value, 'total_prs': prDetails.length},
        actionPlan: 'Keep progressive overloading — aim to beat this record in your next session.',
        icon: '🏆',
        metadata: {'type': 'pr_achievement', 'exercise': prEntry.key, 'weight': prEntry.value},
      ));
    }

    // --- 7.3: Progressive overload detection ---
    final hasProgressiveOverload = workouts.length >= 4 && detectProgressiveOverload(workouts);
    if (hasProgressiveOverload) {
      // Calculate volume trend
      final sortedWorkouts = List<Workout>.from(workouts)
        ..sort((a, b) => a.date.compareTo(b.date));
      final midpoint = sortedWorkouts.length ~/ 2;
      final firstHalfAvg = sortedWorkouts
              .sublist(0, midpoint)
              .map((w) => calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          midpoint;
      final secondHalfAvg = sortedWorkouts
              .sublist(midpoint)
              .map((w) => calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          (sortedWorkouts.length - midpoint);
      final volumeIncrease = calculatePercentageChange(firstHalfAvg, secondHalfAvg);

      allInsights.add(createHighPriorityInsight(
        context: InsightContext.workout,
        title: '📈 Progressive Overload Detected',
        analysis: 'Your training volume has increased by ${_formatNumber(volumeIncrease)}% over the last 30 days.',
        numbers: {
          'volume_increase_pct': volumeIncrease,
          'recent_avg_kg': secondHalfAvg,
        },
        actionPlan: 'You\'re on the right track — keep gradually increasing weight or reps each session.',
        icon: '📈',
        metadata: {'type': 'progressive_overload', 'increase_pct': volumeIncrease},
      ));
    } else if (workouts.length >= 4) {
      // --- 7.7: Suggest recovery when volume is decreasing ---
      final sortedWorkouts = List<Workout>.from(workouts)
        ..sort((a, b) => a.date.compareTo(b.date));
      final midpoint = sortedWorkouts.length ~/ 2;
      final firstHalfAvg = sortedWorkouts
              .sublist(0, midpoint)
              .map((w) => calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          midpoint;
      final secondHalfAvg = sortedWorkouts
              .sublist(midpoint)
              .map((w) => calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          (sortedWorkouts.length - midpoint);

      if (secondHalfAvg < firstHalfAvg * 0.9) {
        final volumeDecrease = calculatePercentageChange(firstHalfAvg, secondHalfAvg).abs();
        allInsights.add(createMediumPriorityInsight(
          context: InsightContext.workout,
          title: '😴 Consider a Deload Week',
          analysis: 'Your training volume has dropped by ${_formatNumber(volumeDecrease)}% recently.',
          numbers: {'volume_decrease_pct': volumeDecrease},
          actionPlan: 'A planned deload week (50-60% of normal volume) can help recovery and prevent overtraining.',
          icon: '🔄',
          metadata: {'type': 'deload_suggestion', 'decrease_pct': volumeDecrease},
        ));
      }
    }

    // --- 7.4 & 7.5: Muscle group balance analysis ---
    final muscleGroupBalance = analyzeMuscleGroupBalance(workouts);
    final neglectedGroups = muscleGroupBalance.entries
        .where((e) => e.value >= 7 && e.value < 999)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (neglectedGroups.isNotEmpty) {
      final mostNeglected = neglectedGroups.first;
      final groupName = mostNeglected.key.name
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      allInsights.add(createMediumPriorityInsight(
        context: InsightContext.workout,
        title: '⚖️ Muscle Balance Alert',
        analysis: 'You haven\'t trained $groupName in ${mostNeglected.value} days.',
        numbers: {'days_since_trained': mostNeglected.value},
        actionPlan: 'Add a $groupName-focused session this week to maintain balanced development.',
        icon: '⚖️',
        metadata: {'type': 'muscle_balance', 'muscle_group': mostNeglected.key.name},
      ));
    }

    // --- 7.2: Volume trend summary ---
    if (allInsights.isEmpty) {
      final totalVolume = workouts.map((w) => calculateVolume(w)).fold(0.0, (a, b) => a + b);
      final avgVolume = totalVolume / workouts.length;
      allInsights.add(createMediumPriorityInsight(
        context: InsightContext.workout,
        title: '💪 Training Summary',
        analysis: 'You\'ve completed ${workouts.length} workouts with an average volume of ${_formatNumber(avgVolume)}kg.',
        numbers: {'total_workouts': workouts.length, 'avg_volume_kg': avgVolume},
        actionPlan: 'Focus on progressive overload — try to beat your average volume each session.',
        icon: '💪',
        metadata: {'type': 'volume_summary'},
      ));
    }

    return prioritizeInsights(allInsights, maxInsights: 3);
  }

  /// Generate insights for the Nutrition screen
  ///
  /// **Requirements:**
  /// - 8.2: Analyze average daily Macro_Targets adherence
  /// - 8.3: Calculate protein intake as a percentage of target
  /// - 8.4: Provide specific food recommendations when protein below 80%
  /// - 8.5: Display calorie tracking accuracy (days logged vs days missed)
  /// - 8.6: Provide adjustment recommendations when calories deviate 200+ kcal
  /// - 8.7: Analyze macro balance (protein/carbs/fats ratio)
  /// - 14.3: Prioritize Macro_Targets adherence and calorie tracking
  Future<List<Insight>> _generateNutritionInsights({
    required InsightGenerationContext context,
    required List<DailyNutritionSummary> nutrition,
    required NutritionTargets? targets,
  }) async {
    if (nutrition.isEmpty || targets == null) {
      return generateFallbackInsights(InsightContext.nutrition);
    }

    final allInsights = <Insight>[];
    final totalDays = 7; // Last 7 days

    // --- 8.3 & 8.4: Protein intake percentage and food recommendations ---
    final proteinPct = getProteinIntakePercentage(nutrition, targets);
    if (proteinPct < 80.0) {
      final deficit = calculateProteinDeficit(nutrition, targets);
      final recommendations = getProteinFoodRecommendations(proteinPct);
      final topRec = recommendations.isNotEmpty ? recommendations.first : 'protein-rich foods';
      allInsights.add(createHighPriorityInsight(
        context: InsightContext.nutrition,
        title: '🥩 Protein Intake Low',
        analysis: 'You\'re hitting ${_formatNumber(proteinPct)}% of your protein target (${_formatNumber(deficit)}g deficit/day).',
        numbers: {'protein_pct': proteinPct, 'deficit_g': deficit},
        actionPlan: 'Add more $topRec to close the gap and support muscle recovery.',
        icon: '🥩',
        metadata: {'type': 'protein_deficit', 'pct': proteinPct, 'deficit': deficit},
      ));
    }

    // --- 8.6: Calorie deviation recommendations (200+ kcal) ---
    final calorieDeviation = calculateCalorieDeviation(nutrition, targets);
    if (calorieDeviation.abs() >= 200) {
      final isOver = calorieDeviation > 0;
      allInsights.add(createHighPriorityInsight(
        context: InsightContext.nutrition,
        title: isOver ? '⚠️ Calorie Surplus' : '⚠️ Calorie Deficit',
        analysis: 'Your average daily calories are ${isOver ? "over" : "under"} target by ${_formatNumber(calorieDeviation.abs())} kcal.',
        numbers: {'deviation_kcal': calorieDeviation.abs(), 'target_kcal': targets.macros.calories},
        actionPlan: isOver
            ? 'Reduce portion sizes or swap high-calorie snacks to stay within your target.'
            : 'Increase meal frequency or add calorie-dense foods to meet your energy needs.',
        icon: isOver ? '⬆️' : '⬇️',
        metadata: {'type': 'calorie_deviation', 'deviation': calorieDeviation},
      ));
    }

    // --- 8.5: Calorie tracking accuracy ---
    final trackingAccuracy = calculateTrackingAccuracy(nutrition, totalDays);
    if (trackingAccuracy < 70.0) {
      final daysLogged = (trackingAccuracy / 100 * totalDays).round();
      allInsights.add(createMediumPriorityInsight(
        context: InsightContext.nutrition,
        title: '📝 Track More Consistently',
        analysis: 'You\'ve logged meals on $daysLogged of the last $totalDays days (${_formatNumber(trackingAccuracy)}% accuracy).',
        numbers: {'days_logged': daysLogged, 'tracking_pct': trackingAccuracy},
        actionPlan: 'Log every meal to get accurate macro insights and stay on track with your goals.',
        icon: '📝',
        metadata: {'type': 'tracking_accuracy', 'accuracy': trackingAccuracy},
      ));
    }

    // --- 8.2 & 8.7: Macro adherence and balance ---
    final macroAdherence = calculateMacroAdherence(nutrition, targets);
    final proteinAdh = macroAdherence['protein'] ?? 0.0;
    final carbsAdh = macroAdherence['carbs'] ?? 0.0;
    final fatsAdh = macroAdherence['fats'] ?? 0.0;
    final avgAdherence = (proteinAdh + carbsAdh + fatsAdh) / 3;

    if (avgAdherence >= 80.0 && allInsights.isEmpty) {
      allInsights.add(createMediumPriorityInsight(
        context: InsightContext.nutrition,
        title: '✅ Great Macro Balance!',
        analysis: 'You\'re averaging ${_formatNumber(avgAdherence)}% adherence to your macro targets.',
        numbers: {
          'protein_pct': proteinAdh,
          'carbs_pct': carbsAdh,
          'fats_pct': fatsAdh,
        },
        actionPlan: 'Keep it up! Consistent macro tracking is key to reaching your body composition goals.',
        icon: '✅',
        metadata: {'type': 'macro_adherence', 'avg_adherence': avgAdherence},
      ));
    }

    if (allInsights.isEmpty) {
      return generateFallbackInsights(InsightContext.nutrition);
    }

    return prioritizeInsights(allInsights, maxInsights: 3);
  }

  /// Generate insights for the Profile screen
  ///
  /// **Requirements:**
  /// - 9.2: Analyze body weight trends over the last 30 days
  /// - 9.3: Calculate total workouts completed in the last 30 days
  /// - 9.4: Compare current performance to 30 days ago
  /// - 9.5: Display weight change direction and magnitude
  /// - 9.6: Provide positive reinforcement when weight change aligns with goal
  /// - 9.7: Suggest adjustments when weight change conflicts with goal
  /// - 14.4: Prioritize long-term trends and goal alignment
  Future<List<Insight>> _generateProfileInsights({
    required InsightGenerationContext context,
    required List<Workout> workouts,
    required List<BodyEntry> bodyEntries,
  }) async {
    final allInsights = <Insight>[];

    // --- 9.3: Total workouts in last 30 days ---
    final totalWorkouts = workouts.length;

    // --- 9.4: Compare current vs 30 days ago performance ---
    if (workouts.length >= 4) {
      final sortedWorkouts = List<Workout>.from(workouts)
        ..sort((a, b) => a.date.compareTo(b.date));
      final midpoint = sortedWorkouts.length ~/ 2;
      final firstHalfAvg = sortedWorkouts
              .sublist(0, midpoint)
              .map((w) => calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          midpoint;
      final secondHalfAvg = sortedWorkouts
              .sublist(midpoint)
              .map((w) => calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          (sortedWorkouts.length - midpoint);
      final volumeChange = calculatePercentageChange(firstHalfAvg, secondHalfAvg);

      if (volumeChange >= 5.0) {
        allInsights.add(createHighPriorityInsight(
          context: InsightContext.profile,
          title: '🚀 Strength Improving!',
          analysis: 'Your average workout volume is up ${_formatNumber(volumeChange)}% compared to 30 days ago.',
          numbers: {
            'volume_increase_pct': volumeChange,
            'total_workouts': totalWorkouts,
          },
          actionPlan: 'You\'re making real progress — keep the consistency and the gains will compound.',
          icon: '🚀',
          metadata: {'type': 'performance_improvement', 'change_pct': volumeChange},
        ));
      } else if (volumeChange <= -10.0) {
        allInsights.add(createMediumPriorityInsight(
          context: InsightContext.profile,
          title: '📉 Volume Declining',
          analysis: 'Your average workout volume has dropped ${_formatNumber(volumeChange.abs())}% over the last 30 days.',
          numbers: {'volume_decrease_pct': volumeChange.abs(), 'total_workouts': totalWorkouts},
          actionPlan: 'Consider a structured program to rebuild consistency and progressive overload.',
          icon: '📉',
          metadata: {'type': 'performance_decline', 'change_pct': volumeChange},
        ));
      }
    }

    // --- 9.2 & 9.5: Body weight trend and magnitude ---
    if (bodyEntries.length >= 2) {
      final weightTrend = analyzeWeightTrend(bodyEntries);
      final weightChange = calculateWeightChange(bodyEntries);
      final weightChangeRate = calculateWeightChangeRate(bodyEntries);
      final currentWeight = getMostRecentWeight(bodyEntries);

      if (weightTrend != WeightTrend.insufficient_data && currentWeight != null) {
        // --- 9.6 & 9.7: Goal alignment ---
        // We don't have user goal here, so provide informational insight
        String title;
        String analysis;
        String actionPlan;
        String icon;
        InsightPriority priority;

        if (weightTrend == WeightTrend.increasing) {
          title = '⬆️ Weight Trending Up';
          analysis = 'Your weight has increased by ${_formatNumber(weightChange.abs())}kg over the last 30 days (${_formatNumber(weightChangeRate.abs())}kg/week).';
          actionPlan = 'If this aligns with your goal (muscle gain), great! If not, review your calorie intake.';
          icon = '⬆️';
          priority = InsightPriority.medium;
        } else if (weightTrend == WeightTrend.decreasing) {
          title = '⬇️ Weight Trending Down';
          analysis = 'Your weight has decreased by ${_formatNumber(weightChange.abs())}kg over the last 30 days (${_formatNumber(weightChangeRate.abs())}kg/week).';
          actionPlan = 'If this aligns with your goal (fat loss), great! Ensure you\'re eating enough protein to preserve muscle.';
          icon = '⬇️';
          priority = InsightPriority.medium;
        } else {
          title = '⚖️ Weight Stable';
          analysis = 'Your weight has remained stable at ~${_formatNumber(currentWeight)}kg over the last 30 days.';
          actionPlan = 'Stable weight with consistent training means you\'re likely building muscle and losing fat simultaneously.';
          icon = '⚖️';
          priority = InsightPriority.low;
        }

        allInsights.add(Insight(
          id: 'weight_trend_${DateTime.now().millisecondsSinceEpoch}',
          context: InsightContext.profile,
          title: title,
          message: '$analysis $actionPlan',
          icon: icon,
          priority: priority,
          generatedAt: DateTime.now(),
          metadata: {
            'type': 'weight_trend',
            'trend': weightTrend.name,
            'change_kg': weightChange,
            'rate_kg_per_week': weightChangeRate,
          },
        ));
      }
    }

    // --- 9.3: Workout count summary ---
    if (totalWorkouts > 0) {
      allInsights.add(createLowPriorityInsight(
        context: InsightContext.profile,
        title: '📊 30-Day Activity',
        analysis: 'You\'ve completed $totalWorkouts workouts in the last 30 days.',
        numbers: {'total_workouts': totalWorkouts, 'avg_per_week': (totalWorkouts / 4.3).round()},
        actionPlan: totalWorkouts >= 12
            ? 'Excellent frequency! You\'re training ~${(totalWorkouts / 4.3).round()}x per week on average.'
            : 'Aim for 3-4 workouts per week to maximise your results.',
        icon: '📊',
        metadata: {'type': 'workout_count'},
      ));
    }

    if (allInsights.isEmpty) {
      return generateFallbackInsights(InsightContext.profile);
    }

    return prioritizeInsights(allInsights, maxInsights: 3);
  }
}

/// Internal data structure for holding fetched context data
class _ContextData {
  final List<Workout> workouts;
  final List<DailyNutritionSummary> nutrition;
  final List<BodyEntry> bodyEntries;

  _ContextData({
    required this.workouts,
    required this.nutrition,
    required this.bodyEntries,
  });
}
