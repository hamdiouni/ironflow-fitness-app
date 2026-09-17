import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

/// Weight trend analysis result
enum WeightTrend {
  increasing,
  decreasing,
  stable,
  insufficient_data,
}

/// Service interface for generating AI-powered coaching insights
///
/// The AIInsightsEngine analyzes user fitness data (workouts, nutrition, body metrics)
/// and generates contextual coaching insights for different screens in the app.
///
/// All analysis happens locally on-device for privacy.
///
/// **Requirements:**
/// - 1.1: Generate insights based on workout history, nutrition data, and body metrics
/// - 1.2: Use data from the last 30 days for workouts and body metrics
/// - 1.3: Use data from the last 7 days for nutrition analysis
/// - 1.4: Generate contextual insights specific to each Context
/// - 1.6: Calculate Volume as sum of (reps × weight) for all sets
/// - 1.7: Analyze Progressive Overload by comparing volume between time periods
/// - 1.8: Detect PR by comparing current performance against historical maximum
abstract class AIInsightsEngine {
  /// Generate insights for a specific context
  ///
  /// Analyzes the provided data and generates 2-3 prioritized insights
  /// relevant to the given context (Home, Workout, Nutrition, Profile).
  ///
  /// The insights include specific numbers, actionable recommendations,
  /// and are formatted as: Analysis → Numbers → Action Plan.
  ///
  /// **Parameters:**
  /// - [context]: The generation context containing all required data
  ///
  /// **Returns:**
  /// A list of 2-3 insights prioritized by importance
  ///
  /// **Requirements:**
  /// - 1.1: Generate insights based on workout, nutrition, and body data
  /// - 1.4: Generate contextual insights specific to each Context
  /// - 2.1: Include specific numbers in insights
  /// - 2.2: Provide actionable recommendations
  /// - 2.7: Format insights as Analysis → Numbers → Action Plan
  /// - 14.6: Select the 2-3 most important insights
  /// - 14.7: Prioritize actionable insights over descriptive insights
  Future<List<Insight>> generateInsights(InsightGenerationContext context);

  /// Generate quick feedback after workout completion
  ///
  /// Analyzes the completed workout and generates immediate feedback
  /// highlighting notable achievements such as PRs, volume records,
  /// or consistency milestones.
  ///
  /// **Parameters:**
  /// - [completedWorkout]: The workout that was just completed
  /// - [history]: Historical workouts for comparison
  ///
  /// **Returns:**
  /// A single insight with celebratory feedback
  ///
  /// **Requirements:**
  /// - 10.3: Highlight notable achievements (PR, volume records, consistency)
  /// - 10.4: Display specific exercise and weight for PRs
  /// - 10.5: Celebrate Progressive Overload (10%+ volume increase)
  /// - 10.8: Use celebratory language and emojis
  Future<Insight> generateQuickFeedback(
    Workout completedWorkout,
    List<Workout> history,
  );

  /// Calculate workout volume
  ///
  /// Calculates the total volume as the sum of (reps × weight) for all sets
  /// in the workout.
  ///
  /// **Parameters:**
  /// - [workout]: The workout to calculate volume for
  ///
  /// **Returns:**
  /// Total volume in kg (or lbs depending on user's unit preference)
  ///
  /// **Requirements:**
  /// - 1.6: Calculate Volume as sum of (reps × weight) for all sets
  double calculateVolume(Workout workout);

  /// Detect progressive overload
  ///
  /// Analyzes whether the user is achieving progressive overload by comparing
  /// volume between the first half and second half of recent workouts.
  ///
  /// **Parameters:**
  /// - [workouts]: List of recent workouts (should be sorted by date)
  ///
  /// **Returns:**
  /// True if progressive overload is detected (volume increasing over time)
  ///
  /// **Requirements:**
  /// - 1.7: Compare volume between first half and second half of recent workouts
  /// - 2.6: Calculate percentage changes between time periods
  bool detectProgressiveOverload(List<Workout> workouts);

  /// Calculate protein deficit
  ///
  /// Calculates the difference between target protein intake and actual
  /// average protein intake over the given period.
  ///
  /// **Parameters:**
  /// - [nutrition]: List of daily nutrition summaries
  /// - [targets]: User's nutrition targets
  ///
  /// **Returns:**
  /// Protein deficit in grams (negative if over target, positive if under)
  ///
  /// **Requirements:**
  /// - 2.3: Specify exact protein deficit in grams when below target
  /// - 2.5: Base protein recommendations on 1.6-2.2g per kg body weight
  double calculateProteinDeficit(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  );

  /// Analyze weight trend
  ///
  /// Analyzes body weight entries to determine the overall trend
  /// (increasing, decreasing, stable, or insufficient data).
  ///
  /// **Parameters:**
  /// - [entries]: List of body weight entries (should be sorted by date)
  ///
  /// **Returns:**
  /// The detected weight trend
  ///
  /// **Requirements:**
  /// - 9.2: Analyze body weight trends over the last 30 days
  /// - 9.5: Display weight change direction and magnitude
  WeightTrend analyzeWeightTrend(List<BodyEntry> entries);
}
