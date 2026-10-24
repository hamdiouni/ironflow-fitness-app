import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../entities/workout_program.dart';
import '../config/workout_volume_config.dart';
import '../entities/day_template.dart';
import '../entities/hybrid_split.dart';
import '../entities/muscle_frequency_report.dart';
import '../entities/split.dart';
import 'deterministic_exercise_selector.dart';

/// Builder responsible for converting a [Split] and a user profile into a fully structured,
/// deterministic [WorkoutProgram].
class SplitScheduleBuilder {
  const SplitScheduleBuilder({
    this.exerciseSelector = const DeterministicExerciseSelector(),
  });

  final DeterministicExerciseSelector exerciseSelector;

  /// Builds a complete 7-day schedule with exactly [daysPerWeek] active workouts.
  WorkoutProgram buildProgram({
    required Split split,
    required int daysPerWeek,
    required UserProfile profile,
    int weekIndex = 0,
    String? customProgramName,
  }) {
    assert(daysPerWeek >= 1 && daysPerWeek <= 7, 'Days per week must be between 1 and 7');

    // 1. Determine cycle day templates based on split type and week index
    final List<DayTemplate> sourceTemplates;
    if (split is HybridSplit && split.mode == HybridMode.alternateWeeks) {
      sourceTemplates = split.getCycleDaysForWeek(weekIndex);
    } else {
      sourceTemplates = split.cycleDays;
    }

    // 2. Determine which of the 7 calendar slots are active training vs rest days
    final activeDayIndices = _getActiveDayIndices(daysPerWeek);

    final programDays = <ProgramDay>[];
    final usedInProgram = <String>{};
    final activeTemplatesUsed = <DayTemplate>[];

    int templatePointer = (split is HybridSplit && split.mode == HybridMode.alternateWeeks)
        ? ((weekIndex ~/ 2) * daysPerWeek) % (sourceTemplates.isEmpty ? 1 : sourceTemplates.length)
        : (weekIndex * daysPerWeek) % (sourceTemplates.isEmpty ? 1 : sourceTemplates.length);

    for (int dayNum = 1; dayNum <= 7; dayNum++) {
      final isTrainingDay = activeDayIndices.contains(dayNum);

      if (!isTrainingDay) {
        programDays.add(
          ProgramDay(
            dayNumber: dayNum,
            name: 'Rest & Recovery',
            focus: 'Neural & Muscular Regeneration',
            exercises: const [],
            isRestDay: true,
          ),
        );
        continue;
      }

      final template = sourceTemplates[templatePointer % sourceTemplates.length];
      activeTemplatesUsed.add(template);
      templatePointer++;

      final exercises = <ProgramExercise>[];
      final usedToday = <String>{};

      for (final slot in template.slots) {
        final selected = exerciseSelector.selectExerciseForSlot(
          slot: slot,
          equipment: profile.equipment,
          level: profile.fitnessLevel,
          goal: profile.goal,
          usedInDay: usedToday,
          usedInProgram: usedInProgram,
        );

        if (selected != null) {
          usedToday.add(selected.exerciseName);
          usedInProgram.add(selected.exerciseName);

          final sets = WorkoutVolumeConfig.getSets(
            level: profile.fitnessLevel,
            isCompound: slot.isCompound,
          );
          final reps = WorkoutVolumeConfig.getReps(
            level: profile.fitnessLevel,
            isCompound: slot.isCompound,
          );
          final restSec = WorkoutVolumeConfig.getRestSeconds(
            level: profile.fitnessLevel,
            isCompound: slot.isCompound,
          );

          exercises.add(
            ProgramExercise(
              exerciseName: selected.exerciseName,
              exerciseDefinitionId: selected.exerciseDefinitionId,
              sets: sets,
              reps: reps,
              restSeconds: restSec,
              notes: selected.notes,
            ),
          );
        }
      }

      programDays.add(
        ProgramDay(
          dayNumber: dayNum,
          name: template.name,
          focus: template.focus,
          exercises: exercises,
          isRestDay: false,
        ),
      );
    }

    final durationWeeks = switch (profile.fitnessLevel) {
      FitnessLevel.beginner => 8,
      FitnessLevel.intermediate => 10,
      FitnessLevel.advanced => 12,
    };

    return WorkoutProgram(
      id: '${split.id}_${daysPerWeek}day_${profile.equipment.name}',
      name: customProgramName ?? '${split.name} ($daysPerWeek Days)',
      description: split.description,
      days: programDays,
      durationWeeks: durationWeeks,
      difficulty: profile.fitnessLevel.displayName,
      splitId: split.id,
      hybridSplitId: split is HybridSplit ? split.id : null,
      hybridMode: split is HybridSplit ? split.mode.name : null,
      cycleLength: sourceTemplates.length,
    );
  }

  /// Computes muscle frequency report from a split and days per week.
  MuscleFrequencyReport computeFrequencyReport({
    required Split split,
    required int daysPerWeek,
    int weekIndex = 0,
  }) {
    final List<DayTemplate> sourceTemplates;
    if (split is HybridSplit && split.mode == HybridMode.alternateWeeks) {
      sourceTemplates = split.getCycleDaysForWeek(weekIndex);
    } else {
      sourceTemplates = split.cycleDays;
    }

    final activeTemplates = <DayTemplate>[];
    for (int i = 0; i < daysPerWeek; i++) {
      activeTemplates.add(sourceTemplates[i % sourceTemplates.length]);
    }

    return MuscleFrequencyReport.compute(
      activeDays: activeTemplates,
      daysPerWeek: daysPerWeek,
    );
  }

  /// Sensible default rest day distribution across 7 days.
  /// Aims to space workouts evenly to avoid consecutive fatigue when possible.
  static Set<int> _getActiveDayIndices(int daysPerWeek) {
    return switch (daysPerWeek) {
      1 => {1},
      2 => {1, 4},
      3 => {1, 3, 5},
      4 => {1, 2, 4, 5},
      5 => {1, 2, 4, 5, 6},
      6 => {1, 2, 3, 5, 6, 7},
      7 => {1, 2, 3, 4, 5, 6, 7},
      _ => {1, 3, 5},
    };
  }
}
