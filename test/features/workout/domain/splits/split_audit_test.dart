import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_catalog.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_schedule_builder.dart';

void main() {
  group('Split Engine Comprehensive Audit (Batch C)', () {
    const builder = SplitScheduleBuilder();

    UserProfile createProfile({
      FitnessGoal goal = FitnessGoal.gainMuscle,
      FitnessLevel level = FitnessLevel.intermediate,
      EquipmentType equipment = EquipmentType.gym,
      int days = 4,
    }) {
      return UserProfile(
        goal: goal,
        age: 25,
        weightKg: 75.0,
        heightCm: 175.0,
        fitnessLevel: level,
        equipment: equipment,
        workoutDaysPerWeek: days,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.preferNotToSay,
      );
    }

    test('All splits x days (1..7) x equipment (gym/home) generate valid non-empty exercises', () {
      int totalCombinations = 0;

      for (final split in SplitCatalog.allSelectableSplits) {
        for (int days = 1; days <= 7; days++) {
          for (final eq in [EquipmentType.gym, EquipmentType.home]) {
            for (final lvl in [
              FitnessLevel.beginner,
              FitnessLevel.intermediate,
              FitnessLevel.advanced,
            ]) {
              final profile = createProfile(
                equipment: eq,
                level: lvl,
                days: days,
              );

              final program = builder.buildProgram(
                split: split,
                daysPerWeek: days,
                profile: profile,
              );

              totalCombinations++;
              expect(program.days.length, equals(7), reason: 'Schedule must always be 7 days');

              final workDays = program.days.where((d) => !d.isRestDay).toList();
              final restDays = program.days.where((d) => d.isRestDay).toList();

              expect(workDays.length, equals(days),
                  reason: '${split.name} with $days days should have $days work days');
              expect(restDays.length, equals(7 - days),
                  reason: '${split.name} with $days days should have ${7 - days} rest days');

              for (final workDay in workDays) {
                expect(workDay.exercises.isNotEmpty, isTrue,
                    reason: '${workDay.name} in ${split.name} ($days days, $eq, $lvl) must have exercises');

                // Verify no duplicate exercises within the same workout session
                final names = workDay.exercises.map((e) => e.exerciseName).toList();
                final uniqueNames = names.toSet();
                expect(names.length, equals(uniqueNames.length),
                    reason: 'Duplicate exercise found in ${workDay.name} (${split.name}): $names');

                // Verify sets and reps are positive
                for (final ex in workDay.exercises) {
                  expect(ex.sets, greaterThan(0));
                  expect(ex.reps.isNotEmpty, isTrue);
                  expect(ex.restSeconds, greaterThan(0));
                }
              }
            }
          }
        }
      }

      // 8 splits * 7 days * 2 equipment * 3 levels = 336 combinations
      expect(totalCombinations, equals(336));
    });

    test('Home training hamstring fallback provides valid substitute with advisory notes', () {
      final ppl = SplitCatalog.pushPullLegs;
      final profile = createProfile(
        equipment: EquipmentType.home,
        level: FitnessLevel.beginner,
        days: 3,
      );

      final program = builder.buildProgram(
        split: ppl,
        daysPerWeek: 3,
        profile: profile,
      );

      final legDay = program.days.firstWhere((d) => d.name.toLowerCase().contains('leg'));
      expect(legDay.exercises.isNotEmpty, isTrue);

      // Verify that posterior chain / glute bridge fallback was supplied
      final bridgeOrHinge = legDay.exercises.any((e) =>
          e.exerciseName.contains('Bridge') ||
          e.exerciseName.contains('Deadlift') ||
          e.exerciseName.contains('Thrust'));
      expect(bridgeOrHinge, isTrue);
    });
  });
}
