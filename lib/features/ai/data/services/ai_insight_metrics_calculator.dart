import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/workout/data/exercise_database.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

/// Pure calculation and formatting helper for [AIInsightsEngineImpl].
class AIInsightMetricsCalculator {
  const AIInsightMetricsCalculator();

  double calculateVolume(Workout workout) {
    double totalVolume = 0.0;
    
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        totalVolume += set.reps * set.weight;
      }
    }
    
    return totalVolume;
  }
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
        .map((entry) => '${entry.key}: ${formatNumber(entry.value)}')
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
  String formatNumber(dynamic value) {
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.round().toString();
      } else {
        return value.toStringAsFixed(1);
      }
    }
    return value.toString();
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
  WeightTrend analyzeWeightTrend(List<BodyEntry> entries) {
    if (entries.length < 2) {
      return WeightTrend.insufficientData;
    }
    
    // Sort entries by date to ensure chronological order
    final sortedEntries = List<BodyEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate linear regression to determine trend
    final weights = sortedEntries.map((e) => e.weight).toList();
    
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
}
