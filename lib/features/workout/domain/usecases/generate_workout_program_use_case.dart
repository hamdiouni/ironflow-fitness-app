import '../../../onboarding/domain/entities/user_profile.dart';
import '../entities/workout_program.dart';

/// Generates a personalized workout program based on user profile.
/// Rule-based, no AI required.
class GenerateWorkoutProgramUseCase {
  WorkoutProgram call({
    required UserProfile userProfile,
    String? splitType,
  }) {
    print('🎯 Generating workout program:');
    print('   - Goal: ${userProfile.goal}');
    print('   - Days/week: ${userProfile.workoutDaysPerWeek}');
    print('   - Split type: ${splitType ?? "auto"}');
    print('   - Fitness level: ${userProfile.fitnessLevel}');
    
    // If splitType is specified, use it to determine the program structure
    if (splitType != null) {
      return _generateProgramBySplit(userProfile, splitType);
    }
    
    // Otherwise, use the default logic based on fitness goal
    return switch (userProfile.goal) {
      FitnessGoal.gainMuscle => _muscleGainProgram(userProfile),
      FitnessGoal.loseWeight => _fatLossProgram(userProfile),
      FitnessGoal.maintain => _maintenanceProgram(userProfile),
    };
  }
  
  /// Generate a program based on the selected split type
  /// 
  /// **Validates: Requirements 2.3, 13.5, 13.6**
  WorkoutProgram _generateProgramBySplit(UserProfile profile, String splitType) {
    return switch (splitType) {
      'full_body' => _fullBodyProgram(profile),
      'upper_lower' => _upperLowerProgram(profile),
      'push_pull_legs' => _pushPullLegsProgram(profile),
      _ => _muscleGainProgram(profile), // Default fallback
    };
  }
  
  /// Generate a full body program (3 days per week)
  WorkoutProgram _fullBodyProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    
    return WorkoutProgram(
      id: 'full_body_3day',
      name: 'Full Body Split',
      description: '3-day full body program for balanced development',
      durationWeeks: 8,
      difficulty: 'Intermediate',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Day A – Full Body',
          focus: 'Chest, Back, Legs',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Lunges', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: 'Plank', sets: 3, reps: '30-45s', restSeconds: 60),
          ],
        ),
        ProgramDay(dayNumber: 2, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 3,
          name: 'Day B – Full Body',
          focus: 'Legs, Shoulders, Arms',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Romanian Deadlift' : 'Bulgarian Split Squat', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Incline Bench Press' : 'Push-Up', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Curl' : 'Hammer Curl', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '12', restSeconds: 60),
          ],
        ),
        ProgramDay(dayNumber: 4, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 5,
          name: 'Day C – Full Body',
          focus: 'Back, Chest, Core',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Deadlift' : 'Romanian Deadlift', sets: 3, reps: '5-6', restSeconds: 120, notes: 'Focus on form'),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Fly' : 'Push-Up', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Seated Cable Row' : 'Dumbbell Row', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: 'Crunch', sets: 3, reps: '15-20', restSeconds: 45),
            ProgramExercise(exerciseName: 'Leg Raise', sets: 3, reps: '12-15', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 6, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
      ],
    );
  }
  
  /// Generate an upper/lower program (4 days per week)
  WorkoutProgram _upperLowerProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    
    return WorkoutProgram(
      id: 'upper_lower_4day',
      name: 'Upper / Lower Split',
      description: '4-day upper/lower split for balanced development',
      durationWeeks: 10,
      difficulty: 'Intermediate',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Upper A – Strength',
          focus: 'Chest, Back, Shoulders',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '8', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Pull-Up' : 'Lat Pulldown', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: 'Barbell Curl', sets: 3, reps: '10', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 2,
          name: 'Lower A – Strength',
          focus: 'Quads, Hamstrings, Glutes',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Bulgarian Split Squat', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Romanian Deadlift' : 'Lunges', sets: 3, reps: '8', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Press' : 'Lunges', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Calf Raise' : 'Calf Raise', sets: 4, reps: '15', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 3, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 4,
          name: 'Upper B – Hypertrophy',
          focus: 'Chest, Back, Arms',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Incline Bench Press' : 'Push-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Fly' : 'Dumbbell Fly', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Face Pull' : 'Reverse Fly', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Hammer Curl', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '12', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 5,
          name: 'Lower B – Hypertrophy',
          focus: 'Quads, Glutes, Calves',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Hack Squat' : 'Lunges', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Hip Thrust' : 'Glute Bridge', sets: 4, reps: '12-15', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Extension' : 'Bulgarian Split Squat', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Calf Raise', sets: 4, reps: '20', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 6, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
      ],
    );
  }
  
  /// Generate a push/pull/legs program (6 days per week)
  WorkoutProgram _pushPullLegsProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    
    return WorkoutProgram(
      id: 'ppl_6day',
      name: 'Push / Pull / Legs Split',
      description: '6-day push/pull/legs split for advanced lifters',
      durationWeeks: 12,
      difficulty: 'Advanced',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Push Day',
          focus: 'Chest, Shoulders, Triceps',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 4, reps: '6-8', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Incline Bench Press' : 'Push-Up', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Lateral Raise' : 'Lateral Raise', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '12-15', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 2,
          name: 'Pull Day',
          focus: 'Back, Biceps',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 4, reps: '6-8', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Pull-Up' : 'Lat Pulldown', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Barbell Curl' : 'Dumbbell Curl', sets: 3, reps: '10-12', restSeconds: 60),
            ProgramExercise(exerciseName: 'Face Pull', sets: 3, reps: '15', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 3,
          name: 'Legs Day',
          focus: 'Quads, Hamstrings, Glutes, Calves',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Bulgarian Split Squat', sets: 4, reps: '6-8', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Romanian Deadlift' : 'Lunges', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Press' : 'Lunges', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Calf Raise', sets: 4, reps: '15-20', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 4, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 5,
          name: 'Push Day',
          focus: 'Chest, Shoulders, Triceps',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Bench Press' : 'Push-Up', sets: 4, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Fly' : 'Dumbbell Fly', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Machine Shoulder Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Lateral Raise' : 'Lateral Raise', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Rope Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '15', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 6,
          name: 'Pull Day',
          focus: 'Back, Biceps',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Deadlift' : 'Romanian Deadlift', sets: 3, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Seated Cable Row' : 'Dumbbell Row', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Hammer Curl' : 'Hammer Curl', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Reverse Fly', sets: 3, reps: '15', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 7,
          name: 'Legs Day',
          focus: 'Quads, Glutes, Calves',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Hack Squat' : 'Lunges', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Hip Thrust' : 'Glute Bridge', sets: 4, reps: '12-15', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Extension' : 'Bulgarian Split Squat', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Calf Raise', sets: 4, reps: '20', restSeconds: 45),
          ],
        ),
      ],
    );
  }

  /// Generate a 5-day program (Upper/Lower/Push/Pull/Legs hybrid)
  WorkoutProgram _fiveDayProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    
    return WorkoutProgram(
      id: 'muscle_5day',
      name: '5-Day Split',
      description: '5-day upper/lower/push/pull/legs hybrid for muscle gain',
      durationWeeks: 10,
      difficulty: 'Intermediate',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Upper Power',
          focus: 'Chest, Back, Shoulders - Heavy',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '6-8', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Pull-Up' : 'Lat Pulldown', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: 'Barbell Curl', sets: 3, reps: '10', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 2,
          name: 'Lower Power',
          focus: 'Quads, Hamstrings, Glutes - Heavy',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Bulgarian Split Squat', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Romanian Deadlift' : 'Lunges', sets: 4, reps: '6-8', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Press' : 'Lunges', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: 'Calf Raise', sets: 4, reps: '15', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 3, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 4,
          name: 'Push Hypertrophy',
          focus: 'Chest, Shoulders, Triceps - Volume',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Incline Bench Press' : 'Push-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Fly' : 'Dumbbell Fly', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Machine Shoulder Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: 'Lateral Raise', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '12-15', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 5,
          name: 'Pull Hypertrophy',
          focus: 'Back, Biceps - Volume',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Seated Cable Row' : 'Dumbbell Row', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Face Pull' : 'Reverse Fly', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Curl' : 'Hammer Curl', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: 'Hammer Curl', sets: 3, reps: '12', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 6,
          name: 'Legs Hypertrophy',
          focus: 'Quads, Glutes, Calves - Volume',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Hack Squat' : 'Lunges', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Hip Thrust' : 'Glute Bridge', sets: 4, reps: '12-15', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Extension' : 'Bulgarian Split Squat', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Calf Raise', sets: 4, reps: '20', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
      ],
    );
  }

  WorkoutProgram _muscleGainProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    final isBeginner = profile.fitnessLevel == FitnessLevel.beginner;

    print('🏋️ Generating muscle gain program for ${profile.workoutDaysPerWeek} days/week');
    
    // 5-day program
    if (profile.workoutDaysPerWeek == 5) {
      print('✅ Generating 5-day program');
      final program = _fiveDayProgram(profile);
      print('📊 5-day program has ${program.days.length} total days');
      final trainingDays = program.days.where((d) => !d.isRestDay).length;
      print('💪 Training days: $trainingDays, Rest days: ${program.days.length - trainingDays}');
      return program;
    }

    if (isBeginner || profile.workoutDaysPerWeek <= 3) {
      return WorkoutProgram(
        id: 'muscle_beginner_3day',
        name: 'Full Body Strength',
        description: '3-day full body program for building a solid foundation',
        durationWeeks: 8,
        difficulty: 'Beginner',
        days: [
          ProgramDay(
            dayNumber: 1,
            name: 'Day A – Full Body',
            focus: 'Chest, Back, Legs',
            exercises: [
              ProgramExercise(exerciseName: isGym ? 'Squat' : 'Lunges', sets: 3, reps: '8-10', restSeconds: 90),
              ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 3, reps: '8-10', restSeconds: 90),
              ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 3, reps: '8-10', restSeconds: 90),
              ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '8-10', restSeconds: 90),
              ProgramExercise(exerciseName: 'Plank', sets: 3, reps: '30-45s', restSeconds: 60),
            ],
          ),
          ProgramDay(dayNumber: 2, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
          ProgramDay(
            dayNumber: 3,
            name: 'Day B – Full Body',
            focus: 'Legs, Shoulders, Arms',
            exercises: [
              ProgramExercise(exerciseName: isGym ? 'Romanian Deadlift' : 'Bulgarian Split Squat', sets: 3, reps: '10-12', restSeconds: 90),
              ProgramExercise(exerciseName: isGym ? 'Incline Bench Press' : 'Push-Up', sets: 3, reps: '10-12', restSeconds: 90),
              ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 3, reps: '8-10', restSeconds: 90),
              ProgramExercise(exerciseName: isGym ? 'Dumbbell Curl' : 'Hammer Curl', sets: 3, reps: '12', restSeconds: 60),
              ProgramExercise(exerciseName: isGym ? 'Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '12', restSeconds: 60),
            ],
          ),
          ProgramDay(dayNumber: 4, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
          ProgramDay(
            dayNumber: 5,
            name: 'Day C – Full Body',
            focus: 'Back, Chest, Core',
            exercises: [
              ProgramExercise(exerciseName: isGym ? 'Deadlift' : 'Romanian Deadlift', sets: 3, reps: '5-6', restSeconds: 120, notes: 'Focus on form'),
              ProgramExercise(exerciseName: isGym ? 'Dumbbell Fly' : 'Push-Up', sets: 3, reps: '12-15', restSeconds: 60),
              ProgramExercise(exerciseName: isGym ? 'Seated Cable Row' : 'Dumbbell Row', sets: 3, reps: '10-12', restSeconds: 90),
              ProgramExercise(exerciseName: 'Crunch', sets: 3, reps: '15-20', restSeconds: 45),
              ProgramExercise(exerciseName: 'Leg Raise', sets: 3, reps: '12-15', restSeconds: 45),
            ],
          ),
          ProgramDay(dayNumber: 6, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
          ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ],
      );
    }

    // 4-5 day PPL / Upper-Lower split
    return WorkoutProgram(
      id: 'muscle_intermediate_4day',
      name: 'Upper / Lower Split',
      description: '4-day upper/lower split for intermediate lifters',
      durationWeeks: 10,
      difficulty: 'Intermediate',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Upper A – Strength',
          focus: 'Chest, Back, Shoulders',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '8', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Pull-Up' : 'Lat Pulldown', sets: 3, reps: '8-10', restSeconds: 90),
            ProgramExercise(exerciseName: 'Barbell Curl', sets: 3, reps: '10', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 2,
          name: 'Lower A – Strength',
          focus: 'Quads, Hamstrings, Glutes',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Bulgarian Split Squat', sets: 4, reps: '5-6', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Romanian Deadlift' : 'Lunges', sets: 3, reps: '8', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Press' : 'Lunges', sets: 3, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Calf Raise' : 'Calf Raise', sets: 4, reps: '15', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 3, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 4,
          name: 'Upper B – Hypertrophy',
          focus: 'Chest, Back, Arms',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Incline Bench Press' : 'Push-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Dumbbell Fly' : 'Dumbbell Fly', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Face Pull' : 'Reverse Fly', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Hammer Curl', sets: 3, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Tricep Pushdown' : 'Overhead Tricep Extension', sets: 3, reps: '12', restSeconds: 60),
          ],
        ),
        ProgramDay(
          dayNumber: 5,
          name: 'Lower B – Hypertrophy',
          focus: 'Quads, Glutes, Calves',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Hack Squat' : 'Lunges', sets: 4, reps: '10-12', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Hip Thrust' : 'Glute Bridge', sets: 4, reps: '12-15', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Leg Extension' : 'Bulgarian Split Squat', sets: 3, reps: '15', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Leg Curl' : 'Romanian Deadlift', sets: 3, reps: '12-15', restSeconds: 60),
            ProgramExercise(exerciseName: 'Calf Raise', sets: 4, reps: '20', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 6, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
      ],
    );
  }

  WorkoutProgram _fatLossProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    return WorkoutProgram(
      id: 'fat_loss_circuit',
      name: 'Fat Burn Circuit',
      description: 'High-rep circuit training to maximize calorie burn',
      durationWeeks: 8,
      difficulty: profile.fitnessLevel.displayName,
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Full Body Circuit A',
          focus: 'Cardio + Strength',
          exercises: [
            ProgramExercise(exerciseName: 'Running', sets: 1, reps: '10 min', restSeconds: 0, notes: 'Warm-up'),
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Lunges', sets: 4, reps: '15', restSeconds: 45),
            ProgramExercise(exerciseName: 'Push-Up', sets: 4, reps: '15', restSeconds: 45),
            ProgramExercise(exerciseName: isGym ? 'Lat Pulldown' : 'Pull-Up', sets: 4, reps: '12', restSeconds: 45),
            ProgramExercise(exerciseName: 'Plank', sets: 3, reps: '45s', restSeconds: 30),
            ProgramExercise(exerciseName: 'Russian Twist', sets: 3, reps: '20', restSeconds: 30),
          ],
        ),
        ProgramDay(dayNumber: 2, name: 'Active Recovery', focus: 'Light Cardio', exercises: [
          ProgramExercise(exerciseName: 'Running', sets: 1, reps: '20-30 min', restSeconds: 0, notes: 'Easy pace'),
        ]),
        ProgramDay(
          dayNumber: 3,
          name: 'Full Body Circuit B',
          focus: 'Cardio + Strength',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Deadlift' : 'Romanian Deadlift', sets: 4, reps: '12', restSeconds: 60),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 4, reps: '12', restSeconds: 45),
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 4, reps: '12', restSeconds: 45),
            ProgramExercise(exerciseName: 'Leg Raise', sets: 3, reps: '15', restSeconds: 30),
            ProgramExercise(exerciseName: 'Crunch', sets: 3, reps: '20', restSeconds: 30),
          ],
        ),
        ProgramDay(dayNumber: 4, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 5,
          name: 'HIIT + Core',
          focus: 'Cardio + Abs',
          exercises: [
            ProgramExercise(exerciseName: 'Jump Rope', sets: 5, reps: '1 min on / 30s off', restSeconds: 30),
            ProgramExercise(exerciseName: 'Crunch', sets: 4, reps: '20', restSeconds: 30),
            ProgramExercise(exerciseName: 'Plank', sets: 4, reps: '45s', restSeconds: 30),
            ProgramExercise(exerciseName: 'Russian Twist', sets: 3, reps: '20', restSeconds: 30),
            ProgramExercise(exerciseName: 'Leg Raise', sets: 3, reps: '15', restSeconds: 30),
          ],
        ),
        ProgramDay(dayNumber: 6, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
      ],
    );
  }

  WorkoutProgram _maintenanceProgram(UserProfile profile) {
    final isGym = profile.equipment == EquipmentType.gym;
    return WorkoutProgram(
      id: 'maintenance_3day',
      name: 'Maintenance & Fitness',
      description: 'Balanced program to maintain strength and health',
      durationWeeks: 12,
      difficulty: 'All Levels',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Strength Day',
          focus: 'Full Body Strength',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Squat' : 'Lunges', sets: 3, reps: '10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Bench Press' : 'Push-Up', sets: 3, reps: '10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Barbell Row' : 'Dumbbell Row', sets: 3, reps: '10', restSeconds: 90),
            ProgramExercise(exerciseName: isGym ? 'Overhead Press' : 'Dumbbell Shoulder Press', sets: 3, reps: '10', restSeconds: 90),
          ],
        ),
        ProgramDay(dayNumber: 2, name: 'Cardio Day', focus: 'Cardio', exercises: [
          ProgramExercise(exerciseName: 'Running', sets: 1, reps: '30 min', restSeconds: 0),
        ]),
        ProgramDay(dayNumber: 3, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(
          dayNumber: 4,
          name: 'Strength Day',
          focus: 'Full Body Strength',
          exercises: [
            ProgramExercise(exerciseName: isGym ? 'Deadlift' : 'Romanian Deadlift', sets: 3, reps: '8', restSeconds: 120),
            ProgramExercise(exerciseName: isGym ? 'Pull-Up' : 'Lat Pulldown', sets: 3, reps: '10', restSeconds: 90),
            ProgramExercise(exerciseName: 'Plank', sets: 3, reps: '45s', restSeconds: 45),
            ProgramExercise(exerciseName: 'Crunch', sets: 3, reps: '15', restSeconds: 45),
          ],
        ),
        ProgramDay(dayNumber: 5, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(dayNumber: 6, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
        ProgramDay(dayNumber: 7, name: 'Rest Day', focus: 'Recovery', exercises: [], isRestDay: true),
      ],
    );
  }
}
