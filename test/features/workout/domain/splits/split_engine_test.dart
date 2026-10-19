import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/data/models/workout_program_model.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/domain/splits/config/workout_volume_config.dart';
import 'package:progression_tracker/features/workout/domain/splits/entities/hybrid_split.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_catalog.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_schedule_builder.dart';
import 'package:progression_tracker/features/workout/domain/usecases/generate_workout_program_use_case.dart';

void main() {
  group('Data-Driven Split Engine Tests', () {
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

    test('All built-in splits exist in SplitCatalog with valid configuration', () {
      final splits = SplitCatalog.allSelectableSplits;
      expect(splits.length, greaterThanOrEqualTo(8));

      final splitIds = splits.map((s) => s.id).toSet();
      expect(splitIds.contains('full_body'), isTrue);
      expect(splitIds.contains('upper_lower'), isTrue);
      expect(splitIds.contains('push_pull_legs'), isTrue);
      expect(splitIds.contains('arnold_split'), isTrue);
      expect(splitIds.contains('mix_custom'), isTrue);
      expect(splitIds.contains('hybrid_ppl_upper_lower'), isTrue);
      expect(splitIds.contains('hybrid_arnold_upper_lower'), isTrue);
      expect(splitIds.contains('hybrid_ppl_arnold'), isTrue);
    });

    test('Every built-in split for days 1..7 produces exactly requested training days', () {
      final profile = createProfile();

      for (final split in SplitCatalog.allSelectableSplits) {
        for (int days = 1; days <= 7; days++) {
          final program = builder.buildProgram(
            split: split,
            daysPerWeek: days,
            profile: profile,
          );

          expect(program.days.length, equals(7),
              reason: 'Split ${split.name} for $days days must produce a 7-day calendar container');

          final trainingDays = program.days.where((d) => !d.isRestDay).length;
          final restDays = program.days.where((d) => d.isRestDay).length;

          expect(trainingDays, equals(days),
              reason: 'Split ${split.name} requested $days days, got $trainingDays training days');
          expect(restDays, equals(7 - days),
              reason: 'Split ${split.name} with $days training days should have ${7 - days} rest days');

          for (final day in program.days.where((d) => !d.isRestDay)) {
            expect(day.exercises, isNotEmpty,
                reason: 'Training day ${day.name} in ${split.name} should contain exercises');
          }
        }
      }
    });

    test('Cycle rolls correctly over consecutive weeks', () {
      final profile = createProfile(days: 4);
      final ppl = SplitCatalog.pushPullLegs; // Cycle length = 3 (Push, Pull, Legs)

      final week1 = builder.buildProgram(split: ppl, daysPerWeek: 4, profile: profile, weekIndex: 0);
      final week2 = builder.buildProgram(split: ppl, daysPerWeek: 4, profile: profile, weekIndex: 1);

      final w1Workouts = week1.days.where((d) => !d.isRestDay).map((d) => d.name).toList();
      final w2Workouts = week2.days.where((d) => !d.isRestDay).map((d) => d.name).toList();

      // Week 1 (4 sessions from 3-day cycle): Push, Pull, Legs, Push
      expect(w1Workouts[0], contains('Push'));
      expect(w1Workouts[1], contains('Pull'));
      expect(w1Workouts[2], contains('Legs'));
      expect(w1Workouts[3], contains('Push'));

      // Week 2 rolls starting at pointer 4: Pull, Legs, Push, Pull
      expect(w2Workouts[0], contains('Pull'));
      expect(w2Workouts[1], contains('Legs'));
      expect(w2Workouts[2], contains('Push'));
      expect(w2Workouts[3], contains('Pull'));
    });

    group('Hybrids Verification', () {
      final profile = createProfile(days: 5);

      test('PPL x Upper/Lower combined cycle produces 5-day cycle', () {
        final hybrid = SplitCatalog.pplXUpperLower(mode: HybridMode.combinedCycle);
        expect(hybrid.cycleDays.length, equals(5));
        expect(hybrid.cycleDays[0].name, contains('Push'));
        expect(hybrid.cycleDays[1].name, contains('Pull'));
        expect(hybrid.cycleDays[2].name, contains('Legs'));
        expect(hybrid.cycleDays[3].name, contains('Upper'));
        expect(hybrid.cycleDays[4].name, contains('Lower'));

        final program = builder.buildProgram(split: hybrid, daysPerWeek: 5, profile: profile);
        final trainingDays = program.days.where((d) => !d.isRestDay).toList();
        expect(trainingDays.length, equals(5));
        expect(trainingDays[0].name, contains('Push'));
        expect(trainingDays[1].name, contains('Pull'));
        expect(trainingDays[2].name, contains('Legs'));
        expect(trainingDays[3].name, contains('Upper'));
        expect(trainingDays[4].name, contains('Lower'));
      });

      test('PPL x Upper/Lower alternate weeks mode alternates split architectures', () {
        final hybrid = SplitCatalog.pplXUpperLower(mode: HybridMode.alternateWeeks);

        final weekA = builder.buildProgram(split: hybrid, daysPerWeek: 3, profile: profile, weekIndex: 0);
        final weekB = builder.buildProgram(split: hybrid, daysPerWeek: 3, profile: profile, weekIndex: 1);

        final wAWorkouts = weekA.days.where((d) => !d.isRestDay).map((d) => d.name).toList();
        final wBWorkouts = weekB.days.where((d) => !d.isRestDay).map((d) => d.name).toList();

        // Week A runs PPL
        expect(wAWorkouts[0], contains('Push'));
        expect(wAWorkouts[1], contains('Pull'));
        expect(wAWorkouts[2], contains('Legs'));

        // Week B runs Upper/Lower
        expect(wBWorkouts[0], contains('Upper'));
        expect(wBWorkouts[1], contains('Lower'));
      });

      test('Arnold x Upper/Lower combined cycle produces 5-day cycle', () {
        final hybrid = SplitCatalog.arnoldXUpperLower(mode: HybridMode.combinedCycle);
        expect(hybrid.cycleDays.length, equals(5));
        expect(hybrid.cycleDays[0].name, contains('Chest & Back'));
        expect(hybrid.cycleDays[1].name, contains('Shoulders & Arms'));
        expect(hybrid.cycleDays[2].name, contains('Legs'));
        expect(hybrid.cycleDays[3].name, contains('Upper'));
        expect(hybrid.cycleDays[4].name, contains('Lower'));
      });

      test('PPL x Arnold combined cycle produces 6-day cycle', () {
        final hybrid = SplitCatalog.pplXArnold(mode: HybridMode.combinedCycle);
        expect(hybrid.cycleDays.length, equals(6));
        expect(hybrid.cycleDays[0].name, contains('Push'));
        expect(hybrid.cycleDays[1].name, contains('Pull'));
        expect(hybrid.cycleDays[2].name, contains('Legs'));
        expect(hybrid.cycleDays[3].name, contains('Chest & Back'));
        expect(hybrid.cycleDays[4].name, contains('Shoulders & Arms'));
        expect(hybrid.cycleDays[5].name, contains('Legs'));
      });

      test('Arbitrary pair combination works in both modes', () {
        final customPairCombined = SplitCatalog.createDynamicHybrid(
          splitA: SplitCatalog.fullBody,
          splitB: SplitCatalog.arnoldSplit,
          mode: HybridMode.combinedCycle,
        );
        expect(customPairCombined.cycleDays.length, equals(6));

        final customPairAlt = SplitCatalog.createDynamicHybrid(
          splitA: SplitCatalog.fullBody,
          splitB: SplitCatalog.arnoldSplit,
          mode: HybridMode.alternateWeeks,
        );
        final weekA = customPairAlt.getCycleDaysForWeek(0);
        final weekB = customPairAlt.getCycleDaysForWeek(1);
        expect(weekA.first.name, contains('Full Body'));
        expect(weekB.first.name, contains('Chest & Back'));
      });
    });

    group('Muscle Frequency Calculation', () {
      test('Hand-calculated expectations for Full Body 3 days match report', () {
        final report = builder.computeFrequencyReport(
          split: SplitCatalog.fullBody,
          daysPerWeek: 3,
        );

        // Day A: Legs(P), Chest(P), Back(P), Shoulders(S), Abs(S)
        // Day B: Legs(P), Back(P), Shoulders(P), Chest(S), Arms(S)
        // Day C: Legs(P), Chest(P), Back(P), Shoulders(P), Abs(P)
        // In 3 active days:
        // Legs: 3 primary = 3.0
        // Chest: 2 primary + 0.5 secondary = 2.5
        // Back: 3 primary = 3.0
        expect(report.getFrequency(MuscleGroup.legs), equals(3.0));
        expect(report.getFrequency(MuscleGroup.chest), equals(2.5));
        expect(report.getFrequency(MuscleGroup.back), equals(3.0));
      });

      test('Hand-calculated expectations for Upper/Lower 4 days match report', () {
        final report = builder.computeFrequencyReport(
          split: SplitCatalog.upperLower,
          daysPerWeek: 4,
        );

        // Upper A: Chest(P), Back(P), Shoulders(P), Arms(S)
        // Lower A: Legs(P), Glutes(S), Abs(S)
        // Upper B: Chest(P), Back(P), Arms(P), Shoulders(S)
        // Lower B: Legs(P), Glutes(S), Abs(S)
        // In 4 days:
        // Chest: 2.0x, Back: 2.0x, Legs: 2.0x
        expect(report.getFrequency(MuscleGroup.chest), equals(2.0));
        expect(report.getFrequency(MuscleGroup.back), equals(2.0));
        expect(report.getFrequency(MuscleGroup.legs), equals(2.0));
      });
    });

    group('Generator Determinism & Constraint Verification', () {
      test('Same inputs always produce strictly identical programs', () {
        final profile = createProfile(days: 4);
        final program1 = builder.buildProgram(split: SplitCatalog.upperLower, daysPerWeek: 4, profile: profile);
        final program2 = builder.buildProgram(split: SplitCatalog.upperLower, daysPerWeek: 4, profile: profile);

        expect(program1.days.length, equals(program2.days.length));
        for (int i = 0; i < program1.days.length; i++) {
          final d1 = program1.days[i];
          final d2 = program2.days[i];
          expect(d1.name, equals(d2.name));
          expect(d1.isRestDay, equals(d2.isRestDay));
          expect(d1.exercises.length, equals(d2.exercises.length));
          for (int j = 0; j < d1.exercises.length; j++) {
            expect(d1.exercises[j].exerciseName, equals(d2.exercises[j].exerciseName));
            expect(d1.exercises[j].sets, equals(d2.exercises[j].sets));
            expect(d1.exercises[j].reps, equals(d2.exercises[j].reps));
            expect(d1.exercises[j].restSeconds, equals(d2.exercises[j].restSeconds));
          }
        }
      });

      test('No duplicate exercises in the same workout day', () {
        for (final split in SplitCatalog.allSelectableSplits) {
          for (final equip in [EquipmentType.gym, EquipmentType.home]) {
            final profile = createProfile(equipment: equip, days: 5);
            final program = builder.buildProgram(split: split, daysPerWeek: 5, profile: profile);

            for (final day in program.days.where((d) => !d.isRestDay)) {
              final names = day.exercises.map((e) => e.exerciseName).toList();
              final uniqueNames = names.toSet();
              expect(names.length, equals(uniqueNames.length),
                  reason: 'Duplicate exercise found in ${day.name} of ${split.name} for $equip');
            }
          }
        }
      });

      test('Home workouts only select home-compatible exercises or documented substitutes', () {
        final profile = createProfile(equipment: EquipmentType.home, days: 4);
        final program = builder.buildProgram(split: SplitCatalog.upperLower, daysPerWeek: 4, profile: profile);

        for (final day in program.days.where((d) => !d.isRestDay)) {
          for (final ex in day.exercises) {
            // Cannot use barbell or machine without note
            expect(ex.exerciseName.toLowerCase().contains('barbell'), isFalse,
                reason: 'Home exercise cannot require barbell: ${ex.exerciseName}');
          }
        }
      });

      test('VolumeConfig sets, reps, and rest values correctly applied by fitness level', () {
        final beginnerProfile = createProfile(level: FitnessLevel.beginner);
        final advancedProfile = createProfile(level: FitnessLevel.advanced);

        final begProgram = builder.buildProgram(split: SplitCatalog.fullBody, daysPerWeek: 3, profile: beginnerProfile);
        final advProgram = builder.buildProgram(split: SplitCatalog.fullBody, daysPerWeek: 3, profile: advancedProfile);

        final begCompound = begProgram.days.first.exercises.first;
        final advCompound = advProgram.days.first.exercises.first;

        expect(begCompound.sets, equals(WorkoutVolumeConfig.beginnerCompoundSets));
        expect(begCompound.reps, equals(WorkoutVolumeConfig.beginnerCompoundReps));
        expect(begCompound.restSeconds, equals(WorkoutVolumeConfig.beginnerCompoundRestSec));

        expect(advCompound.sets, equals(WorkoutVolumeConfig.advancedCompoundSets));
        expect(advCompound.reps, equals(WorkoutVolumeConfig.advancedCompoundReps));
        expect(advCompound.restSeconds, equals(WorkoutVolumeConfig.advancedCompoundRestSec));
      });

      test('Session duration estimate is deterministic and positive for non-empty days', () {
        final duration = WorkoutVolumeConfig.estimateSessionDurationMinutes(
          totalSets: 20,
          totalRestSeconds: 20 * 90,
        );
        expect(duration, equals(50)); // (20*45 + 1800 + 300) / 60 = 3000 / 60 = 50 min
      });
    });

    group('Compatibility Matrix & Weak Combination Guidance', () {
      test('Weak combinations produce non-blocking guidance note', () {
        final notePpl2Days = SplitCatalog.pushPullLegs.getScheduleGuidance(2, FitnessLevel.intermediate);
        expect(notePpl2Days, isNotNull);
        expect(notePpl2Days, contains('lower frequency'));

        final note7Days = SplitCatalog.fullBody.getScheduleGuidance(7, FitnessLevel.intermediate);
        expect(note7Days, isNotNull);
        expect(note7Days, contains('passive recovery'));

        final noteBeginner6Days = SplitCatalog.arnoldSplit.getScheduleGuidance(6, FitnessLevel.beginner);
        expect(noteBeginner6Days, isNotNull);
        expect(noteBeginner6Days, contains('Beginners typically achieve'));

        // Strong combination yields null (no warning)
        final notePpl6Days = SplitCatalog.pushPullLegs.getScheduleGuidance(6, FitnessLevel.intermediate);
        expect(notePpl6Days, isNull);
      });
    });

    group('Persistence & Backward Compatibility Fixture', () {
      test('Old program JSON without split metadata deserializes smoothly', () {
        final oldProgramJson = {
          'id': 'legacy_program_1',
          'name': 'Legacy Full Body',
          'description': 'Created before split engine',
          'days': [
            {
              'dayNumber': 1,
              'name': 'Day A',
              'focus': 'Full Body',
              'exercises': [
                {
                  'exerciseName': 'Push-Up',
                  'sets': 3,
                  'reps': '10',
                  'restSeconds': 60,
                }
              ],
              'isRestDay': false,
            }
          ],
          'durationWeeks': 8,
          'difficulty': 'Beginner',
        };

        final model = WorkoutProgramModel.fromJson(oldProgramJson);
        expect(model.id, equals('legacy_program_1'));
        expect(model.splitId, isNull);
        expect(model.hybridSplitId, isNull);
        expect(model.hybridMode, isNull);
        expect(model.cycleLength, isNull);

        final entity = model.toEntity();
        expect(entity.id, equals('legacy_program_1'));
        expect(entity.splitId, isNull);
      });

      test('New program with split metadata serializes and deserializes accurately', () {
        const program = WorkoutProgram(
          id: 'ppl_5day_gym',
          name: 'Push / Pull / Legs (5 Days)',
          description: 'Custom split',
          days: [],
          durationWeeks: 10,
          difficulty: 'Intermediate',
          splitId: 'push_pull_legs',
          hybridSplitId: 'hybrid_ppl_upper_lower',
          hybridMode: 'combinedCycle',
          cycleLength: 5,
        );

        final model = WorkoutProgramModel.fromEntity(program);
        final json = model.toJson();

        expect(json['splitId'], equals('push_pull_legs'));
        expect(json['hybridSplitId'], equals('hybrid_ppl_upper_lower'));
        expect(json['hybridMode'], equals('combinedCycle'));
        expect(json['cycleLength'], equals(5));

        final restored = WorkoutProgramModel.fromJson(json).toEntity();
        expect(restored.splitId, equals('push_pull_legs'));
        expect(restored.hybridSplitId, equals('hybrid_ppl_upper_lower'));
        expect(restored.hybridMode, equals('combinedCycle'));
        expect(restored.cycleLength, equals(5));
      });
    });

    group('GenerateWorkoutProgramUseCase Integration', () {
      const useCase = GenerateWorkoutProgramUseCase();

      test('UseCase generates recommended split matching daysPerWeek when no split specified', () {
        final profile3D = createProfile(days: 3);
        final p3 = useCase(userProfile: profile3D);
        expect(p3.days.where((d) => !d.isRestDay).length, equals(3));
        expect(p3.splitId, equals('full_body'));

        final profile4D = createProfile(days: 4);
        final p4 = useCase(userProfile: profile4D);
        expect(p4.days.where((d) => !d.isRestDay).length, equals(4));
        expect(p4.splitId, equals('upper_lower'));

        final profile5D = createProfile(days: 5);
        final p5 = useCase(userProfile: profile5D);
        expect(p5.days.where((d) => !d.isRestDay).length, equals(5));
        expect(p5.splitId, equals('hybrid_ppl_upper_lower'));

        final profile6D = createProfile(days: 6);
        final p6 = useCase(userProfile: profile6D);
        expect(p6.days.where((d) => !d.isRestDay).length, equals(6));
        expect(p6.splitId, equals('push_pull_legs'));
      });

      test('UseCase allows overriding days at generation time', () {
        final profile4D = createProfile(days: 4);
        final pOverridden = useCase(userProfile: profile4D, overrideDays: 5, splitType: 'push_pull_legs');
        expect(pOverridden.days.where((d) => !d.isRestDay).length, equals(5));
        expect(pOverridden.splitId, equals('push_pull_legs'));
      });
    });
  });
}
