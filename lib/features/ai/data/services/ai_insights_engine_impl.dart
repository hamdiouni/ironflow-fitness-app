import 'package:progression_tracker/features/ai/data/services/ai_contextual_insight_generators.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insight_metrics_calculator.dart';
import 'package:progression_tracker/features/ai/data/services/ai_quick_feedback_generator.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

/// Implementation of the AI Insights Engine.
///
/// Generates context-specific coaching insights locally on-device by analyzing
/// workout history (30d), nutrition logs (7d), and body metrics (30d).
class AIInsightsEngineImpl implements AIInsightsEngine {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;

  static const AIInsightMetricsCalculator _calc = AIInsightMetricsCalculator();
  static const AIQuickFeedbackGenerator _quickFeedback =
      AIQuickFeedbackGenerator(_calc);
  static const AIContextualInsightGenerators _contextual =
      AIContextualInsightGenerators(_calc);

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
    final data = await _fetchDataForContext(context.context);

    switch (context.context) {
      case InsightContext.home:
        return _contextual.generateHomeInsights(
          context: context,
          workouts: data.workouts,
          nutrition: data.nutrition,
          bodyEntries: data.bodyEntries,
        );
      case InsightContext.workout:
        return _contextual.generateWorkoutInsights(
          context: context,
          workouts: data.workouts,
        );
      case InsightContext.nutrition:
        return _contextual.generateNutritionInsights(
          context: context,
          nutrition: data.nutrition,
          targets: context.nutritionTargets,
        );
      case InsightContext.profile:
        return _contextual.generateProfileInsights(
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
  ) =>
      _quickFeedback.generateQuickFeedback(completedWorkout, history);

  @override
  double calculateVolume(Workout workout) => _calc.calculateVolume(workout);

  @override
  bool detectProgressiveOverload(List<Workout> workouts) =>
      _calc.detectProgressiveOverload(workouts);

  bool detectPR(List<Workout> workouts, {String? specificExercise}) =>
      _calc.detectPR(workouts, specificExercise: specificExercise);

  Map<String, double> getPRDetails(List<Workout> workouts) =>
      _calc.getPRDetails(workouts);

  Map<MuscleGroup, int> analyzeMuscleGroupBalance(List<Workout> workouts) =>
      _calc.analyzeMuscleGroupBalance(workouts);

  List<Insight> prioritizeInsights(
    List<Insight> allInsights, {
    int maxInsights = 3,
  }) =>
      _calc.prioritizeInsights(allInsights, maxInsights: maxInsights);

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
  }) =>
      _calc.formatInsight(
        id: id,
        context: context,
        title: title,
        analysis: analysis,
        numbers: numbers,
        actionPlan: actionPlan,
        icon: icon,
        priority: priority,
        metadata: metadata,
      );

  Insight createHighPriorityInsight({
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    Map<String, dynamic>? metadata,
  }) =>
      _calc.createHighPriorityInsight(
        context: context,
        title: title,
        analysis: analysis,
        numbers: numbers,
        actionPlan: actionPlan,
        icon: icon,
        metadata: metadata,
      );

  Insight createMediumPriorityInsight({
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    Map<String, dynamic>? metadata,
  }) =>
      _calc.createMediumPriorityInsight(
        context: context,
        title: title,
        analysis: analysis,
        numbers: numbers,
        actionPlan: actionPlan,
        icon: icon,
        metadata: metadata,
      );

  Insight createLowPriorityInsight({
    required InsightContext context,
    required String title,
    required String analysis,
    required Map<String, dynamic> numbers,
    required String actionPlan,
    required String icon,
    Map<String, dynamic>? metadata,
  }) =>
      _calc.createLowPriorityInsight(
        context: context,
        title: title,
        analysis: analysis,
        numbers: numbers,
        actionPlan: actionPlan,
        icon: icon,
        metadata: metadata,
      );

  double calculatePercentageChange(double oldValue, double newValue) =>
      _calc.calculatePercentageChange(oldValue, newValue);

  List<Insight> generateFallbackInsights(InsightContext context) =>
      _calc.generateFallbackInsights(context);

  @override
  double calculateProteinDeficit(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) =>
      _calc.calculateProteinDeficit(nutrition, targets);

  Map<String, double> calculateMacroAdherence(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) =>
      _calc.calculateMacroAdherence(nutrition, targets);

  double calculateTrackingAccuracy(
    List<DailyNutritionSummary> nutrition,
    int totalDays,
  ) =>
      _calc.calculateTrackingAccuracy(nutrition, totalDays);

  double calculateCalorieDeviation(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) =>
      _calc.calculateCalorieDeviation(nutrition, targets);

  double getProteinIntakePercentage(
    List<DailyNutritionSummary> nutrition,
    NutritionTargets targets,
  ) =>
      _calc.getProteinIntakePercentage(nutrition, targets);

  List<String> getProteinFoodRecommendations(double proteinPercentage) =>
      _calc.getProteinFoodRecommendations(proteinPercentage);

  @override
  WeightTrend analyzeWeightTrend(List<BodyEntry> entries) =>
      _calc.analyzeWeightTrend(entries);

  double calculateWeightChange(List<BodyEntry> entries) =>
      _calc.calculateWeightChange(entries);

  double calculateAverageWeight(List<BodyEntry> entries) =>
      _calc.calculateAverageWeight(entries);

  double? getMostRecentWeight(List<BodyEntry> entries) =>
      _calc.getMostRecentWeight(entries);

  double calculateWeightChangeRate(List<BodyEntry> entries) =>
      _calc.calculateWeightChangeRate(entries);

  bool isWeightChangeAlignedWithGoal(
    List<BodyEntry> entries,
    String? userGoal,
  ) =>
      _calc.isWeightChangeAlignedWithGoal(entries, userGoal);

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
