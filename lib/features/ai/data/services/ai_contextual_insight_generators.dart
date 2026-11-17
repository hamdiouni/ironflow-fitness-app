import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insight_metrics_calculator.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

/// Context-specific insight generators (Home, Workout, Nutrition, Profile).
class AIContextualInsightGenerators {
  const AIContextualInsightGenerators(this._calc);

  final AIInsightMetricsCalculator _calc;

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
  Future<List<Insight>> generateHomeInsights({
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
      allInsights.add(_calc.createHighPriorityInsight(
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
      allInsights.add(_calc.createMediumPriorityInsight(
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
      final hasProgressiveOverload = workouts.length >= 4 && _calc.detectProgressiveOverload(workouts);
      if (hasProgressiveOverload) {
        allInsights.add(_calc.createHighPriorityInsight(
          context: InsightContext.home,
          title: '🚀 You\'re Progressing!',
          analysis: 'You\'ve trained $workoutsThisWeek times this week and your volume is trending up.',
          numbers: {'workouts_this_week': workoutsThisWeek},
          actionPlan: 'Keep up the progressive overload — your strength is building week over week.',
          icon: '📈',
          metadata: {'type': 'consistency_encouragement'},
        ));
      } else {
        allInsights.add(_calc.createMediumPriorityInsight(
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
        return _calc.generateFallbackInsights(InsightContext.home);
      }
      allInsights.add(_calc.createMediumPriorityInsight(
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

    return _calc.prioritizeInsights(allInsights, maxInsights: 3);
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
  Future<List<Insight>> generateWorkoutInsights({
    required InsightGenerationContext context,
    required List<Workout> workouts,
  }) async {
    if (workouts.isEmpty) {
      return _calc.generateFallbackInsights(InsightContext.workout);
    }

    final allInsights = <Insight>[];

    final weightUnit = UnitsConverter.getWeightUnit(context.units);

    // --- 7.6: Recent PR achievements ---
    final prDetails = _calc.getPRDetails(workouts);
    if (prDetails.isNotEmpty) {
      final prEntry = prDetails.entries.first;
      final displayPrWeight =
          UnitsConverter.convertWeightToDisplay(prEntry.value, context.units);
      allInsights.add(_calc.createHighPriorityInsight(
        context: InsightContext.workout,
        title: '🏆 Personal Record!',
        analysis:
            'You set a new PR on ${prEntry.key} with ${_calc.formatNumber(displayPrWeight)} $weightUnit.',
        numbers: {
          'pr_weight ($weightUnit)': displayPrWeight,
          'total_prs': prDetails.length,
        },
        actionPlan: 'Keep progressive overloading — aim to beat this record in your next session.',
        icon: '🏆',
        metadata: {'type': 'pr_achievement', 'exercise': prEntry.key, 'weight': prEntry.value},
      ));
    }

    // --- 7.3: Progressive overload detection ---
    final hasProgressiveOverload = workouts.length >= 4 && _calc.detectProgressiveOverload(workouts);
    if (hasProgressiveOverload) {
      // Calculate volume trend
      final sortedWorkouts = List<Workout>.from(workouts)
        ..sort((a, b) => a.date.compareTo(b.date));
      final midpoint = sortedWorkouts.length ~/ 2;
      final firstHalfAvg = sortedWorkouts
              .sublist(0, midpoint)
              .map((w) => _calc.calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          midpoint;
      final secondHalfAvg = sortedWorkouts
              .sublist(midpoint)
              .map((w) => _calc.calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          (sortedWorkouts.length - midpoint);
      final volumeIncrease = _calc.calculatePercentageChange(firstHalfAvg, secondHalfAvg);

      allInsights.add(_calc.createHighPriorityInsight(
        context: InsightContext.workout,
        title: '📈 Progressive Overload Detected',
        analysis: 'Your training volume has increased by ${_calc.formatNumber(volumeIncrease)}% over the last 30 days.',
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
              .map((w) => _calc.calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          midpoint;
      final secondHalfAvg = sortedWorkouts
              .sublist(midpoint)
              .map((w) => _calc.calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          (sortedWorkouts.length - midpoint);

      if (secondHalfAvg < firstHalfAvg * 0.9) {
        final volumeDecrease = _calc.calculatePercentageChange(firstHalfAvg, secondHalfAvg).abs();
        allInsights.add(_calc.createMediumPriorityInsight(
          context: InsightContext.workout,
          title: '😴 Consider a Deload Week',
          analysis: 'Your training volume has dropped by ${_calc.formatNumber(volumeDecrease)}% recently.',
          numbers: {'volume_decrease_pct': volumeDecrease},
          actionPlan: 'A planned deload week (50-60% of normal volume) can help recovery and prevent overtraining.',
          icon: '🔄',
          metadata: {'type': 'deload_suggestion', 'decrease_pct': volumeDecrease},
        ));
      }
    }

    // --- 7.4 & 7.5: Muscle group balance analysis ---
    final muscleGroupBalance = _calc.analyzeMuscleGroupBalance(workouts);
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
      allInsights.add(_calc.createMediumPriorityInsight(
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
      final totalVolume = workouts.map((w) => _calc.calculateVolume(w)).fold(0.0, (a, b) => a + b);
      final avgVolume = totalVolume / workouts.length;
      final displayAvgVolume =
          UnitsConverter.convertWeightToDisplay(avgVolume, context.units);
      allInsights.add(_calc.createMediumPriorityInsight(
        context: InsightContext.workout,
        title: '💪 Training Summary',
        analysis:
            'You\'ve completed ${workouts.length} workouts with an average volume of ${_calc.formatNumber(displayAvgVolume)} $weightUnit.',
        numbers: {
          'total_workouts': workouts.length,
          'avg_volume ($weightUnit)': displayAvgVolume,
        },
        actionPlan: 'Focus on progressive overload — try to beat your average volume each session.',
        icon: '💪',
        metadata: {'type': 'volume_summary'},
      ));
    }

    return _calc.prioritizeInsights(allInsights, maxInsights: 3);
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
  Future<List<Insight>> generateNutritionInsights({
    required InsightGenerationContext context,
    required List<DailyNutritionSummary> nutrition,
    required NutritionTargets? targets,
  }) async {
    if (nutrition.isEmpty || targets == null) {
      return _calc.generateFallbackInsights(InsightContext.nutrition);
    }

    final allInsights = <Insight>[];
    final totalDays = 7; // Last 7 days

    // --- 8.3 & 8.4: Protein intake percentage and food recommendations ---
    final proteinPct = _calc.getProteinIntakePercentage(nutrition, targets);
    if (proteinPct < 80.0) {
      final deficit = _calc.calculateProteinDeficit(nutrition, targets);
      final recommendations = _calc.getProteinFoodRecommendations(proteinPct);
      final topRec = recommendations.isNotEmpty ? recommendations.first : 'protein-rich foods';
      allInsights.add(_calc.createHighPriorityInsight(
        context: InsightContext.nutrition,
        title: '🥩 Protein Intake Low',
        analysis: 'You\'re hitting ${_calc.formatNumber(proteinPct)}% of your protein target (${_calc.formatNumber(deficit)}g deficit/day).',
        numbers: {'protein_pct': proteinPct, 'deficit_g': deficit},
        actionPlan: 'Add more $topRec to close the gap and support muscle recovery.',
        icon: '🥩',
        metadata: {'type': 'protein_deficit', 'pct': proteinPct, 'deficit': deficit},
      ));
    }

    // --- 8.6: Calorie deviation recommendations (200+ kcal) ---
    final calorieDeviation = _calc.calculateCalorieDeviation(nutrition, targets);
    if (calorieDeviation.abs() >= 200) {
      final isOver = calorieDeviation > 0;
      allInsights.add(_calc.createHighPriorityInsight(
        context: InsightContext.nutrition,
        title: isOver ? '⚠️ Calorie Surplus' : '⚠️ Calorie Deficit',
        analysis: 'Your average daily calories are ${isOver ? "over" : "under"} target by ${_calc.formatNumber(calorieDeviation.abs())} kcal.',
        numbers: {'deviation_kcal': calorieDeviation.abs(), 'target_kcal': targets.macros.calories},
        actionPlan: isOver
            ? 'Reduce portion sizes or swap high-calorie snacks to stay within your target.'
            : 'Increase meal frequency or add calorie-dense foods to meet your energy needs.',
        icon: isOver ? '⬆️' : '⬇️',
        metadata: {'type': 'calorie_deviation', 'deviation': calorieDeviation},
      ));
    }

    // --- 8.5: Calorie tracking accuracy ---
    final trackingAccuracy = _calc.calculateTrackingAccuracy(nutrition, totalDays);
    if (trackingAccuracy < 70.0) {
      final daysLogged = (trackingAccuracy / 100 * totalDays).round();
      allInsights.add(_calc.createMediumPriorityInsight(
        context: InsightContext.nutrition,
        title: '📝 Track More Consistently',
        analysis: 'You\'ve logged meals on $daysLogged of the last $totalDays days (${_calc.formatNumber(trackingAccuracy)}% accuracy).',
        numbers: {'days_logged': daysLogged, 'tracking_pct': trackingAccuracy},
        actionPlan: 'Log every meal to get accurate macro insights and stay on track with your goals.',
        icon: '📝',
        metadata: {'type': 'tracking_accuracy', 'accuracy': trackingAccuracy},
      ));
    }

    // --- 8.2 & 8.7: Macro adherence and balance ---
    final macroAdherence = _calc.calculateMacroAdherence(nutrition, targets);
    final proteinAdh = macroAdherence['protein'] ?? 0.0;
    final carbsAdh = macroAdherence['carbs'] ?? 0.0;
    final fatsAdh = macroAdherence['fats'] ?? 0.0;
    final avgAdherence = (proteinAdh + carbsAdh + fatsAdh) / 3;

    if (avgAdherence >= 80.0 && allInsights.isEmpty) {
      allInsights.add(_calc.createMediumPriorityInsight(
        context: InsightContext.nutrition,
        title: '✅ Great Macro Balance!',
        analysis: 'You\'re averaging ${_calc.formatNumber(avgAdherence)}% adherence to your macro targets.',
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
      return _calc.generateFallbackInsights(InsightContext.nutrition);
    }

    return _calc.prioritizeInsights(allInsights, maxInsights: 3);
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
  Future<List<Insight>> generateProfileInsights({
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
              .map((w) => _calc.calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          midpoint;
      final secondHalfAvg = sortedWorkouts
              .sublist(midpoint)
              .map((w) => _calc.calculateVolume(w))
              .fold(0.0, (a, b) => a + b) /
          (sortedWorkouts.length - midpoint);
      final volumeChange = _calc.calculatePercentageChange(firstHalfAvg, secondHalfAvg);

      if (volumeChange >= 5.0) {
        allInsights.add(_calc.createHighPriorityInsight(
          context: InsightContext.profile,
          title: '🚀 Strength Improving!',
          analysis: 'Your average workout volume is up ${_calc.formatNumber(volumeChange)}% compared to 30 days ago.',
          numbers: {
            'volume_increase_pct': volumeChange,
            'total_workouts': totalWorkouts,
          },
          actionPlan: 'You\'re making real progress — keep the consistency and the gains will compound.',
          icon: '🚀',
          metadata: {'type': 'performance_improvement', 'change_pct': volumeChange},
        ));
      } else if (volumeChange <= -10.0) {
        allInsights.add(_calc.createMediumPriorityInsight(
          context: InsightContext.profile,
          title: '📉 Volume Declining',
          analysis: 'Your average workout volume has dropped ${_calc.formatNumber(volumeChange.abs())}% over the last 30 days.',
          numbers: {'volume_decrease_pct': volumeChange.abs(), 'total_workouts': totalWorkouts},
          actionPlan: 'Consider a structured program to rebuild consistency and progressive overload.',
          icon: '📉',
          metadata: {'type': 'performance_decline', 'change_pct': volumeChange},
        ));
      }
    }

    // --- 9.2 & 9.5: Body weight trend and magnitude ---
    if (bodyEntries.length >= 2) {
      final weightTrend = _calc.analyzeWeightTrend(bodyEntries);
      final weightChange = _calc.calculateWeightChange(bodyEntries);
      final weightChangeRate = _calc.calculateWeightChangeRate(bodyEntries);
      final currentWeight = _calc.getMostRecentWeight(bodyEntries);

      if (weightTrend != WeightTrend.insufficientData && currentWeight != null) {
        // --- 9.6 & 9.7: Goal alignment ---
        // We don't have user goal here, so provide informational insight
        String title;
        String analysis;
        String actionPlan;
        String icon;
        InsightPriority priority;

        final weightUnit = UnitsConverter.getWeightUnit(context.units);
        final displayChange = UnitsConverter.convertWeightToDisplay(
          weightChange.abs(),
          context.units,
        );
        final displayRate = UnitsConverter.convertWeightToDisplay(
          weightChangeRate.abs(),
          context.units,
        );
        final displayCurrent = UnitsConverter.convertWeightToDisplay(
          currentWeight,
          context.units,
        );

        if (weightTrend == WeightTrend.increasing) {
          title = '⬆️ Weight Trending Up';
          analysis =
              'Your weight has increased by ${_calc.formatNumber(displayChange)} $weightUnit over the last 30 days (${_calc.formatNumber(displayRate)} $weightUnit/week).';
          actionPlan = 'If this aligns with your goal (muscle gain), great! If not, review your calorie intake.';
          icon = '⬆️';
          priority = InsightPriority.medium;
        } else if (weightTrend == WeightTrend.decreasing) {
          title = '⬇️ Weight Trending Down';
          analysis =
              'Your weight has decreased by ${_calc.formatNumber(displayChange)} $weightUnit over the last 30 days (${_calc.formatNumber(displayRate)} $weightUnit/week).';
          actionPlan = 'If this aligns with your goal (fat loss), great! Ensure you\'re eating enough protein to preserve muscle.';
          icon = '⬇️';
          priority = InsightPriority.medium;
        } else {
          title = '⚖️ Weight Stable';
          analysis =
              'Your weight has remained stable at ~${_calc.formatNumber(displayCurrent)} $weightUnit over the last 30 days.';
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
      allInsights.add(_calc.createLowPriorityInsight(
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
      return _calc.generateFallbackInsights(InsightContext.profile);
    }

    return _calc.prioritizeInsights(allInsights, maxInsights: 3);
  }
}
