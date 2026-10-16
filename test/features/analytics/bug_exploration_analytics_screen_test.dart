import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

/// Validates that AnalyticsScreen calculates and displays weekly consistency
/// dynamically based on userProfile.workoutDaysPerWeek.
void main() {
  Widget buildScreen({
    required List<Workout> workouts,
    required UserProfile? profile,
  }) {
    return ProviderScope(
      overrides: [
        workoutHistoryProvider.overrideWith((ref) => Future.value(workouts)),
        userProfileProvider.overrideWith((ref) => Future.value(profile)),
      ],
      child: const MaterialApp(
        home: AnalyticsScreen(),
      ),
    );
  }

  group('Analytics Screen Dynamic Divisor Widget Tests', () {
    testWidgets('displays 67% consistency for 2 workouts when workoutDaysPerWeek=3', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 3);

      await tester.pumpWidget(buildScreen(workouts: workouts, profile: profile));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Consistency'), findsOneWidget);
      // 2 / 3 * 100 = 67% (should NOT be 40% which was 2/5)
      expect(find.text('67%'), findsOneWidget);
      expect(find.text('40%'), findsNothing);
    });

    testWidgets('displays 67% consistency for 4 workouts when workoutDaysPerWeek=6', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 3, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 6);

      await tester.pumpWidget(buildScreen(workouts: workouts, profile: profile));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Consistency'), findsOneWidget);
      // 4 / 6 * 100 = 67% (should NOT be 80% which was 4/5)
      expect(find.text('67%'), findsOneWidget);
      expect(find.text('80%'), findsNothing);
    });

    testWidgets('displays 60% consistency for 3 workouts when workoutDaysPerWeek=5', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 3, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 5);

      await tester.pumpWidget(buildScreen(workouts: workouts, profile: profile));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Consistency'), findsOneWidget);
      // 3 / 5 * 100 = 60%
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('displays 100% consistency for 6 workouts when workoutDaysPerWeek=6', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 3, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 4, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 5, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 6);

      await tester.pumpWidget(buildScreen(workouts: workouts, profile: profile));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Consistency'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}

UserProfile _createProfile({int workoutDaysPerWeek = 5}) {
  return UserProfile(
    goal: FitnessGoal.maintain,
    age: 25,
    weightKg: 70,
    heightCm: 175,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: workoutDaysPerWeek,
    budget: BudgetLevel.medium,
  );
}

Workout _createWorkout(DateTime date) {
  return Workout(
    id: date.toIso8601String(),
    date: date,
    exercises: const [],
    duration: const Duration(minutes: 45),
    totalVolume: 1000,
  );
}
