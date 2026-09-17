import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

/// Context data required for generating insights
class InsightGenerationContext {
  final InsightContext context;
  final UserProfile? profile;
  final List<Workout> recentWorkouts;
  final List<DailyNutritionSummary> nutritionHistory;
  final NutritionTargets? nutritionTargets;
  final List<BodyEntry> bodyEntries;
  final DateTime generatedAt;

  const InsightGenerationContext({
    required this.context,
    this.profile,
    required this.recentWorkouts,
    required this.nutritionHistory,
    this.nutritionTargets,
    required this.bodyEntries,
    required this.generatedAt,
  });
}
