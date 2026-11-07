import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/domain/services/muscle_recovery_calculator.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';

void main() {
  const calculator = MuscleRecoveryCalculator();
  final benchmarkDate = DateTime(2026, 11, 7, 12, 0);

  group('Wave 5.6 Yearly Heavy Data Performance Benchmarks', () {
    late List<Workout> yearlyWorkouts;

    setUpAll(() {
      // Generate 365 days of realistic workout history (~200 workouts, ~3,000+ sets)
      yearlyWorkouts = [];
      final exerciseTemplates = [
        ('chest_001', 'Barbell Bench Press', ExerciseType.strength),
        ('legs_001', 'Barbell Squat', ExerciseType.strength),
        ('back_001', 'Barbell Deadlift', ExerciseType.strength),
        ('back_002', 'Pull Up', ExerciseType.strength),
        ('shoulders_001', 'Overhead Press', ExerciseType.strength),
        ('arms_001', 'Barbell Bicep Curl', ExerciseType.strength),
      ];

      for (var dayOffset = 365; dayOffset >= 0; dayOffset--) {
        // Workout every 1-2 days (approx 4-5 days/week)
        if (dayOffset % 7 == 0 || dayOffset % 7 == 3) {
          continue; // Rest days
        }

        final workoutDate = benchmarkDate.subtract(Duration(days: dayOffset, hours: 2));
        final exercises = <Exercise>[];

        for (var e = 0; e < 4; e++) {
          final t = exerciseTemplates[(dayOffset + e) % exerciseTemplates.length];
          final sets = <SetEntry>[];

          // 1 Warmup set + 3 Normal sets
          sets.add(SetEntry.create(
            reps: 10,
            weight: 50.0,
            type: SetType.warmup,
          ));

          for (var s = 1; s <= 3; s++) {
            sets.add(SetEntry.create(
              reps: 8,
              weight: 85.0 + (s * 2.5),
              type: SetType.normal,
            ));
          }

          exercises.add(Exercise(
            id: '${t.$1}-$dayOffset',
            name: t.$2,
            type: t.$3,
            exerciseDefinitionId: t.$1,
            sets: sets,
          ));
        }

        yearlyWorkouts.add(Workout(
          id: 'yearly-w-$dayOffset',
          date: workoutDate,
          duration: const Duration(minutes: 55),
          totalVolume: 4250.0,
          exercises: exercises,
        ));
      }
    });

    test('1. Dataset Verification: confirms 1-year volume scale (~200 workouts, ~3,000 sets)', () {
      expect(yearlyWorkouts.length, inInclusiveRange(200, 270));
      final totalSets = yearlyWorkouts.fold<int>(
        0,
        (sum, w) => sum + w.exercises.fold<int>(0, (sSum, e) => sSum + e.sets.length),
      );
      expect(totalSets, greaterThanOrEqualTo(3000));
    });

    test('2. Muscle Recovery Calculation Benchmark on 1-Year History (<50ms budget)', () {
      // Warm up JIT
      calculator.calculate(
        workouts: yearlyWorkouts.take(10).toList(),
        referenceNow: benchmarkDate,
      );

      final stopwatch = Stopwatch()..start();
      final recoveryMap = calculator.calculate(
        workouts: yearlyWorkouts,
        referenceNow: benchmarkDate,
      );
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      // Budget: calculation across 1-year volume must be under 50ms for 60fps UI responsiveness
      expect(elapsedMs, lessThan(50),
          reason: 'Yearly recovery calculation took ${elapsedMs}ms (budget: <50ms)');
      expect(recoveryMap.keys.length, equals(MuscleRegion.values.length));
    });

    test('3. Summary Rebuild & 7D/30D Filter Benchmark (<20ms budget)', () {
      final stopwatch = Stopwatch()..start();
      
      final cutoff7d = benchmarkDate.subtract(const Duration(days: 7));
      final cutoff30d = benchmarkDate.subtract(const Duration(days: 30));

      final last7Days = yearlyWorkouts.where((w) => w.date.isAfter(cutoff7d)).toList();
      final last30Days = yearlyWorkouts.where((w) => w.date.isAfter(cutoff30d)).toList();

      final vol7d = last7Days.fold<double>(0.0, (s, w) => s + w.totalVolume);
      final vol30d = last30Days.fold<double>(0.0, (s, w) => s + w.totalVolume);

      stopwatch.stop();
      final elapsedUs = stopwatch.elapsedMicroseconds;

      expect(vol7d, greaterThan(0));
      expect(vol30d, greaterThan(vol7d));
      // Rebuild summary filter takes < 20,000 microseconds (20ms)
      expect(elapsedUs, lessThan(20000),
          reason: 'Summary rebuild filter took ${elapsedUs}us (budget: <20ms)');
    });
  });
}
