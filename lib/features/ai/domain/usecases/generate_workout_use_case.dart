import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';

/// Suggestion for workout program generation
class WorkoutSuggestion {
  final String type; // 'new_program', 'exercise_swap', 'progression', 'deload'
  final String title;
  final String description;
  final String reasoning;
  final Map<String, dynamic> data;

  WorkoutSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.reasoning,
    required this.data,
  });
}

/// Use case for generating AI-powered workout coaching suggestions
///
/// Analyzes user's current program and recent workouts to provide:
/// - New program generation
/// - Exercise swap suggestions
/// - Progression strategies
/// - Stagnation detection
///
/// **Validates: Requirements 7.3**
class GenerateWorkoutUseCase {
  final AuthRepository _authRepository;
  final WorkoutRepository _workoutRepository;
  final ActiveProgramRepository _activeProgramRepository;

  GenerateWorkoutUseCase({
    required AuthRepository authRepository,
    required WorkoutRepository workoutRepository,
    required ActiveProgramRepository activeProgramRepository,
  })  : _authRepository = authRepository,
        _workoutRepository = workoutRepository,
        _activeProgramRepository = activeProgramRepository;

  /// Generate workout coaching suggestions
  Future<List<WorkoutSuggestion>> execute() async {
    final suggestions = <WorkoutSuggestion>[];

    // Get user profile
    final user = await _authRepository.getCurrentUser();
    if (user == null) return suggestions;

    final profile = await _authRepository.getUserProfile(user.id);
    if (profile == null) return suggestions;

    // Get current program
    final activeProgram = await _activeProgramRepository.loadActiveProgram();

    // Get recent workouts (last 12 weeks)
    final twelveWeeksAgo = DateTime.now().subtract(const Duration(days: 84));
    final recentWorkouts = await _workoutRepository.getWorkoutsByDateRange(
      twelveWeeksAgo,
      DateTime.now(),
    );

    // 1. Check for stagnation
    final stagnationSuggestions = _detectStagnation(recentWorkouts);
    suggestions.addAll(stagnationSuggestions);

    // 2. Suggest exercise swaps for variety
    if (activeProgram != null && recentWorkouts.length >= 8) {
      final swapSuggestions = _suggestExerciseSwaps(
        activeProgram,
        recentWorkouts,
        profile,
      );
      suggestions.addAll(swapSuggestions);
    }

    // 3. Recommend progression strategies
    if (recentWorkouts.isNotEmpty) {
      final progressionSuggestions = _recommendProgression(
        recentWorkouts,
        profile,
      );
      suggestions.addAll(progressionSuggestions);
    }

    // 4. Generate new program if needed
    if (activeProgram == null || recentWorkouts.isEmpty) {
      final newProgramSuggestion = _generateNewProgram(profile);
      suggestions.add(newProgramSuggestion);
    }

    return suggestions;
  }

  /// Detect exercises that haven't progressed in 3+ weeks
  List<WorkoutSuggestion> _detectStagnation(List<Workout> workouts) {
    final suggestions = <WorkoutSuggestion>[];
    
    if (workouts.length < 3) return suggestions;

    // Track exercise performance over time
    final exerciseHistory = <String, List<Map<String, dynamic>>>{};
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        if (!exerciseHistory.containsKey(exercise.name)) {
          exerciseHistory[exercise.name] = [];
        }
        
        // Get max weight from all sets
        final maxWeight = exercise.sets.fold<double>(
          0,
          (max, set) => set.weight > max ? set.weight : max,
        );
        
        exerciseHistory[exercise.name]!.add({
          'date': workout.date,
          'weight': maxWeight,
        });
      }
    }

    // Check for stagnation (same weight for 3+ weeks)
    for (final entry in exerciseHistory.entries) {
      final exerciseName = entry.key;
      final history = entry.value;
      
      if (history.length >= 3) {
        // Get last 3 sessions
        final recentSessions = history.sublist(history.length - 3);
        final weights = recentSessions.map((s) => s['weight'] as double).toList();
        
        // Check if all weights are the same
        if (weights.toSet().length == 1 && weights.first > 0) {
          suggestions.add(WorkoutSuggestion(
            type: 'stagnation',
            title: 'Stagnation detected: $exerciseName',
            description: 'Your $exerciseName has been at ${weights.first.toStringAsFixed(0)} lbs for 3+ sessions',
            reasoning: 'Time to increase weight, change rep range, or swap the exercise',
            data: {
              'exercise': exerciseName,
              'current_weight': weights.first,
              'suggested_weight': weights.first + 5,
              'sessions_stagnant': 3,
            },
          ));
        }
      }
    }

    return suggestions;
  }

  /// Suggest exercise swaps for variety and targeting weak points
  List<WorkoutSuggestion> _suggestExerciseSwaps(
    ActiveProgram activeProgram,
    List<Workout> recentWorkouts,
    UserProfile profile,
  ) {
    final suggestions = <WorkoutSuggestion>[];

    // Common exercise swaps by muscle group
    final exerciseSwaps = {
      'Bench Press': ['Incline Bench Press', 'Dumbbell Bench Press', 'Close-Grip Bench Press'],
      'Squat': ['Front Squat', 'Bulgarian Split Squat', 'Leg Press'],
      'Deadlift': ['Romanian Deadlift', 'Sumo Deadlift', 'Trap Bar Deadlift'],
      'Overhead Press': ['Dumbbell Shoulder Press', 'Arnold Press', 'Push Press'],
      'Barbell Row': ['Dumbbell Row', 'T-Bar Row', 'Pendlay Row'],
      'Pull-ups': ['Lat Pulldown', 'Chin-ups', 'Assisted Pull-ups'],
    };

    // Get exercises from current program
    final programExercises = <String>{};
    for (final day in activeProgram.program.days) {
      if (!day.isRestDay) {
        for (final exercise in day.exercises) {
          programExercises.add(exercise.exerciseName);
        }
      }
    }

    // Suggest swaps for common exercises
    for (final exercise in programExercises) {
      if (exerciseSwaps.containsKey(exercise)) {
        final alternatives = exerciseSwaps[exercise]!;
        suggestions.add(WorkoutSuggestion(
          type: 'exercise_swap',
          title: 'Try a variation of $exercise',
          description: 'Consider swapping $exercise for ${alternatives.first}',
          reasoning: 'Variations target muscles differently and prevent adaptation',
          data: {
            'current_exercise': exercise,
            'alternatives': alternatives,
          },
        ));
      }
    }

    return suggestions.take(2).toList(); // Limit to 2 suggestions
  }

  /// Recommend progression strategies based on experience level
  List<WorkoutSuggestion> _recommendProgression(
    List<Workout> recentWorkouts,
    UserProfile profile,
  ) {
    final suggestions = <WorkoutSuggestion>[];
    
    final fitnessLevel = profile.fitnessLevel ?? 'beginner';

    if (fitnessLevel == 'beginner') {
      suggestions.add(WorkoutSuggestion(
        type: 'progression',
        title: 'Linear Progression',
        description: 'Add 5 lbs to upper body and 10 lbs to lower body each week',
        reasoning: 'Beginners can progress linearly with consistent weight increases',
        data: {
          'strategy': 'linear',
          'upper_body_increase': 5,
          'lower_body_increase': 10,
        },
      ));
    } else if (fitnessLevel == 'intermediate') {
      suggestions.add(WorkoutSuggestion(
        type: 'progression',
        title: 'Double Progression',
        description: 'Increase reps until you hit the top of your range, then add weight',
        reasoning: 'Intermediate lifters benefit from rep progression before adding weight',
        data: {
          'strategy': 'double_progression',
          'rep_range': '8-12',
          'weight_increase': 5,
        },
      ));
    } else {
      suggestions.add(WorkoutSuggestion(
        type: 'progression',
        title: 'Periodization',
        description: 'Cycle between high volume (12-15 reps) and high intensity (4-6 reps)',
        reasoning: 'Advanced lifters need varied stimulus to continue progressing',
        data: {
          'strategy': 'periodization',
          'phases': ['hypertrophy', 'strength', 'power'],
          'cycle_length': 4, // weeks
        },
      ));
    }

    return suggestions;
  }

  /// Generate a new program based on user goals and experience
  WorkoutSuggestion _generateNewProgram(UserProfile profile) {
    final goals = profile.goals ?? ['strength'];
    final fitnessLevel = profile.fitnessLevel ?? 'beginner';
    final equipment = profile.equipment ?? ['barbell', 'dumbbell'];

    String programName;
    String splitType;
    int daysPerWeek;

    // Determine program based on goals and level
    if (goals.contains('strength')) {
      programName = 'Strength Builder';
      splitType = 'upper-lower';
      daysPerWeek = 4;
    } else if (goals.contains('hypertrophy')) {
      programName = 'Muscle Builder';
      splitType = 'ppl';
      daysPerWeek = 6;
    } else if (goals.contains('endurance')) {
      programName = 'Endurance Program';
      splitType = 'full-body';
      daysPerWeek = 3;
    } else {
      programName = 'General Fitness';
      splitType = 'full-body';
      daysPerWeek = 3;
    }

    return WorkoutSuggestion(
      type: 'new_program',
      title: 'Generate $programName',
      description: 'A $splitType program designed for your goals: ${goals.join(", ")}',
      reasoning: 'Based on your $fitnessLevel level and available equipment',
      data: {
        'program_name': programName,
        'split_type': splitType,
        'days_per_week': daysPerWeek,
        'goals': goals,
        'fitness_level': fitnessLevel,
        'equipment': equipment,
      },
    );
  }
}
