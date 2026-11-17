import 'package:progression_tracker/core/utils/local_date_window.dart';
import 'package:progression_tracker/core/utils/workout_streak_calculator.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/domain/services/muscle_recovery_calculator.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';

/// Use case for building comprehensive AI context from user data.
///
/// Gathers all relevant user data and formats it into a context string
/// that the AI can use to provide personalized coaching advice.
///
/// **Validates: Requirements 7.2**
class BuildAIContextUseCase {
  final AuthRepository _authRepository;
  final WorkoutRepository _workoutRepository;
  final ActiveProgramRepository _activeProgramRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;

  BuildAIContextUseCase({
    required AuthRepository authRepository,
    required WorkoutRepository workoutRepository,
    required ActiveProgramRepository activeProgramRepository,
    required NutritionRepository nutritionRepository,
    required BodyRepository bodyRepository,
  })  : _authRepository = authRepository,
        _workoutRepository = workoutRepository,
        _activeProgramRepository = activeProgramRepository,
        _nutritionRepository = nutritionRepository,
        _bodyRepository = bodyRepository;

  /// Build comprehensive context string for AI (Wave 7.2 — consent-first, units, streaks, recovery).
  Future<String> execute({
    bool hasConsent = true,
    String unitLabel = 'kg',
  }) async {
    if (!hasConsent) {
      return 'USER PRIVACY:\n- Personalization consent is disabled.\n- Preferred units: $unitLabel';
    }

    final buffer = StringBuffer();
    buffer.writeln('PREFERRED UNITS: $unitLabel');
    buffer.writeln();

    // Get current user
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      return 'No user authenticated';
    }

    // 1. User Profile
    final profile = await _authRepository.getUserProfile(user.id);
    buffer.writeln(_buildUserProfileSection(profile));
    buffer.writeln();

    // 2. Current Program
    final activeProgram = await _activeProgramRepository.loadActiveProgram();
    buffer.writeln(_buildCurrentProgramSection(activeProgram));
    buffer.writeln();

    // 3. Recent Workouts (Last 12 weeks) + Streaks + Muscle Recovery
    final twelveWeeksAgo = DateTime.now().subtract(const Duration(days: 84));
    final recentWorkouts = await _workoutRepository.getWorkoutsByDateRange(
      twelveWeeksAgo,
      DateTime.now(),
    );
    buffer.writeln(_buildRecentWorkoutsSection(recentWorkouts, unitLabel: unitLabel));
    buffer.writeln();

    // 4. Nutrition (Last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final nutritionHistory = await _nutritionRepository.getNutritionHistory(
      sevenDaysAgo,
      DateTime.now(),
    );
    final nutritionTargets = await _nutritionRepository.getNutritionTargets();
    buffer.writeln(_buildNutritionSection(nutritionHistory, nutritionTargets));
    buffer.writeln();

    // 5. Body Metrics
    final bodyEntries = await _bodyRepository.getBodyEntriesByDateRange(
      twelveWeeksAgo,
      DateTime.now(),
    );
    buffer.writeln(_buildBodyMetricsSection(bodyEntries));
    buffer.writeln();

    // 6. Progress Trends
    buffer.writeln(_buildProgressTrendsSection(
      recentWorkouts,
      bodyEntries,
      activeProgram,
    ));

    return buffer.toString();
  }

  String _buildUserProfileSection(UserProfile? profile) {
    if (profile == null) {
      return 'USER PROFILE:\n- No profile data available';
    }

    final buffer = StringBuffer('USER PROFILE:');
    buffer.writeln('\n- Age: ${profile.age ?? "Not set"}');
    buffer.writeln('- Gender: ${profile.gender ?? "Not set"}');
    buffer.writeln('- Fitness Level: ${profile.fitnessLevel ?? "Not set"}');
    
    if (profile.goals != null && profile.goals!.isNotEmpty) {
      buffer.writeln('- Goals: ${profile.goals!.join(", ")}');
    } else {
      buffer.writeln('- Goals: Not set');
    }
    
    if (profile.equipment != null && profile.equipment!.isNotEmpty) {
      buffer.writeln('- Equipment: ${profile.equipment!.join(", ")}');
    } else {
      buffer.writeln('- Equipment: Not set');
    }

    return buffer.toString();
  }

  String _buildCurrentProgramSection(ActiveProgram? activeProgram) {
    if (activeProgram == null) {
      return 'CURRENT PROGRAM:\n- No active program';
    }

    final program = activeProgram.program;
    final buffer = StringBuffer('CURRENT PROGRAM:');
    buffer.writeln('\n- Name: ${program.name}');
    buffer.writeln('- Days per week: ${program.days.length}');
    buffer.writeln('- Current day: ${activeProgram.currentDayIndex + 1}/${program.days.length}');
    
    // List key exercises from the program
    final allExercises = <String>{};
    for (final day in program.days) {
      if (!day.isRestDay) {
        for (final exercise in day.exercises) {
          allExercises.add(exercise.exerciseName);
        }
      }
    }
    
    if (allExercises.isNotEmpty) {
      buffer.writeln('- Key exercises: ${allExercises.take(10).join(", ")}');
      if (allExercises.length > 10) {
        buffer.writeln('  (and ${allExercises.length - 10} more)');
      }
    }

    return buffer.toString();
  }

  String _buildRecentWorkoutsSection(
    List<Workout> workouts, {
    String unitLabel = 'kg',
  }) {
    if (workouts.isEmpty) {
      return 'RECENT WORKOUTS (Last 12 weeks):\n- No workouts logged';
    }

    final buffer = StringBuffer('RECENT WORKOUTS (Last 12 weeks):');
    buffer.writeln('\n- Total workouts: ${workouts.length}');
    final streak = WorkoutStreakCalculator.calculateFromDates(
      workouts.map((w) => w.date),
    );
    buffer.writeln(
      '- Active streak: ${streak.currentStreak} days (Longest: ${streak.longestStreak} days)',
    );
    final recoveryMap = const MuscleRecoveryCalculator().calculate(
      workouts: workouts,
    );
    final freshCount = recoveryMap.values.where((r) => r.score >= 0.85).length;
    buffer.writeln('- Muscle recovery: $freshCount / ${recoveryMap.length} regions fresh (>=85% est.)');

    // Calculate average weekly volume
    final totalVolume = workouts.fold<double>(
      0,
      (sum, workout) => sum + workout.totalVolume,
    );
    final avgWeeklyVolume = totalVolume / 12;
    buffer.writeln('- Average weekly volume: ${avgWeeklyVolume.toStringAsFixed(0)} $unitLabel');
    
    // Track exercise progression
    final exerciseProgressions = _calculateExerciseProgressions(workouts);
    if (exerciseProgressions.isNotEmpty) {
      buffer.writeln('- Exercise progressions:');
      for (final entry in exerciseProgressions.entries.take(5)) {
        final exerciseName = entry.key;
        final progression = entry.value;
        final change = progression['change'] as double;
        final changeStr = change >= 0 ? '+${change.toStringAsFixed(0)}' : change.toStringAsFixed(0);
        buffer.writeln('  • $exerciseName: ${progression['start']?.toStringAsFixed(0)}$unitLabel → ${progression['end']?.toStringAsFixed(0)}$unitLabel ($changeStr $unitLabel)');
      }
    }

    return buffer.toString();
  }

  Map<String, Map<String, double>> _calculateExerciseProgressions(List<Workout> workouts) {
    final exerciseData = <String, List<double>>{};
    
    // Collect all weight data per exercise
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        if (!exerciseData.containsKey(exercise.name)) {
          exerciseData[exercise.name] = [];
        }
        
        // Get max weight from all sets
        final maxWeight = exercise.sets.fold<double>(
          0,
          (max, set) => set.weight > max ? set.weight : max,
        );
        
        if (maxWeight > 0) {
          exerciseData[exercise.name]!.add(maxWeight);
        }
      }
    }
    
    // Calculate progression for each exercise
    final progressions = <String, Map<String, double>>{};
    for (final entry in exerciseData.entries) {
      if (entry.value.length >= 2) {
        final start = entry.value.first;
        final end = entry.value.last;
        final change = end - start;
        
        progressions[entry.key] = {
          'start': start,
          'end': end,
          'change': change,
        };
      }
    }
    
    // Sort by absolute change (biggest improvements first)
    final sortedEntries = progressions.entries.toList()
      ..sort((a, b) => b.value['change']!.abs().compareTo(a.value['change']!.abs()));
    
    return Map.fromEntries(sortedEntries);
  }

  String _buildNutritionSection(
    List<DailyNutritionSummary> nutritionHistory,
    NutritionTargets? targets,
  ) {
    if (nutritionHistory.isEmpty) {
      return 'NUTRITION (Last 7 days):\n- No nutrition data logged';
    }

    final buffer = StringBuffer('NUTRITION (Last 7 days):');
    
    // Calculate averages
    final avgCalories = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalCalories,
    ) / nutritionHistory.length;
    
    final avgProtein = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalProtein,
    ) / nutritionHistory.length;
    
    final avgCarbs = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalCarbs,
    ) / nutritionHistory.length;
    
    final avgFats = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalFats,
    ) / nutritionHistory.length;
    
    final avgFiber = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalFiber,
    ) / nutritionHistory.length;

    buffer.writeln('\n- Avg Calories: ${avgCalories.toStringAsFixed(0)} kcal/day');
    buffer.writeln('- Avg Protein: ${avgProtein.toStringAsFixed(0)}g/day');
    buffer.writeln('- Avg Carbs: ${avgCarbs.toStringAsFixed(0)}g/day');
    buffer.writeln('- Avg Fats: ${avgFats.toStringAsFixed(0)}g/day');
    buffer.writeln('- Avg Fiber: ${avgFiber.toStringAsFixed(0)}g/day');
    
    // Compare to targets if available
    if (targets != null) {
      buffer.writeln('\nTargets vs Actual:');
      
      final proteinDiff = avgProtein - targets.macros.protein;
      final proteinStatus = proteinDiff >= 0 ? 'above' : 'below';
      buffer.writeln('- Protein: ${proteinDiff.abs().toStringAsFixed(0)}g $proteinStatus target (${targets.macros.protein.toStringAsFixed(0)}g)');
      
      final fiberDiff = avgFiber - targets.micros.fiber;
      final fiberStatus = fiberDiff >= 0 ? 'above' : 'below';
      buffer.writeln('- Fiber: ${fiberDiff.abs().toStringAsFixed(0)}g $fiberStatus target (${targets.micros.fiber.toStringAsFixed(0)}g)');
      
      // Identify deficiencies (below 80% of target)
      final deficiencies = <String>[];
      if (avgProtein < targets.macros.protein * 0.8) {
        deficiencies.add('Protein');
      }
      if (avgFiber < targets.micros.fiber * 0.8) {
        deficiencies.add('Fiber');
      }
      
      if (deficiencies.isNotEmpty) {
        buffer.writeln('\nDeficiencies detected: ${deficiencies.join(", ")}');
      }
    }

    return buffer.toString();
  }

  String _buildBodyMetricsSection(List<BodyEntry> bodyEntries) {
    if (bodyEntries.isEmpty) {
      return 'BODY METRICS:\n- No body measurements logged';
    }

    final buffer = StringBuffer('BODY METRICS:');
    
    // Get most recent entry
    final latest = bodyEntries.first;
    buffer.writeln('\n- Current weight: ${latest.weight.toStringAsFixed(1)} lbs');
    
    // Calculate weight change if we have multiple entries
    if (bodyEntries.length >= 2) {
      final oldest = bodyEntries.last;
      final weightChange = latest.weight - oldest.weight;
      final changeStr = weightChange >= 0 ? '+${weightChange.toStringAsFixed(1)}' : weightChange.toStringAsFixed(1);
      buffer.writeln('- Weight change (12 weeks): $changeStr lbs');
    }
    
    // Show measurements if available
    if (latest.measurements.isNotEmpty) {
      buffer.writeln('- Measurements:');
      latest.measurements.forEach((type, value) {
        buffer.writeln('  • ${type.name}: ${value.toStringAsFixed(1)}"');
      });
    }

    return buffer.toString();
  }

  String _buildProgressTrendsSection(
    List<Workout> workouts,
    List<BodyEntry> bodyEntries,
    ActiveProgram? activeProgram,
  ) {
    final buffer = StringBuffer('PROGRESS:');
    
    // Workout streak
    final streak = _calculateWorkoutStreak(workouts);
    buffer.writeln('\n- Workout streak: $streak days');
    
    // PRs this month
    final prsThisMonth = _calculatePRsThisMonth(workouts);
    buffer.writeln('- PRs this month: $prsThisMonth');
    
    // Consistency
    final consistency = _calculateConsistency(workouts);
    buffer.writeln('- Consistency (12 weeks): ${consistency.toStringAsFixed(0)}%');
    
    // Weight trend
    if (bodyEntries.length >= 2) {
      final trend = _calculateWeightTrend(bodyEntries);
      buffer.writeln('- Weight trend: $trend');
    }

    return buffer.toString();
  }

  int _calculateWorkoutStreak(List<Workout> workouts) {
    return WorkoutStreakCalculator.calculateFromDates(
      workouts.map((w) => w.date),
    ).currentStreak;
  }

  int _calculatePRsThisMonth(List<Workout> workouts) {
    final oneMonthAgo = LocalDateWindow.rollingDaysWindow(30).start;
    final recentWorkouts = workouts.where((w) => !w.date.toLocal().isBefore(oneMonthAgo)).toList();
    
    if (recentWorkouts.isEmpty) return 0;
    
    // Track max weight per exercise
    final exerciseMaxes = <String, double>{};
    int prs = 0;
    
    // Sort by date ascending to track PRs chronologically
    recentWorkouts.sort((a, b) => a.date.compareTo(b.date));
    
    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final maxWeight = exercise.sets.fold<double>(
          0,
          (max, set) => set.weight > max ? set.weight : max,
        );
        
        if (maxWeight > 0) {
          final currentMax = exerciseMaxes[exercise.name] ?? 0;
          if (maxWeight > currentMax) {
            prs++;
            exerciseMaxes[exercise.name] = maxWeight;
          }
        }
      }
    }
    
    return prs;
  }

  double _calculateConsistency(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Calculate workouts per week over 12 weeks
    final workoutsPerWeek = workouts.length / 12;
    
    // Assume target is 4 workouts per week
    const targetWorkoutsPerWeek = 4;
    
    return (workoutsPerWeek / targetWorkoutsPerWeek * 100).clamp(0, 100);
  }

  String _calculateWeightTrend(List<BodyEntry> bodyEntries) {
    if (bodyEntries.length < 2) return 'Stable';
    
    final latest = bodyEntries.first.weight;
    final oldest = bodyEntries.last.weight;
    final change = latest - oldest;
    
    if (change.abs() < 2) {
      return 'Stable';
    } else if (change > 0) {
      return 'Gaining (+${change.toStringAsFixed(1)} lbs)';
    } else {
      return 'Losing (${change.toStringAsFixed(1)} lbs)';
    }
  }
}
