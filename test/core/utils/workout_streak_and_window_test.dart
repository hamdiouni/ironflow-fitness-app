import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/utils/local_date_window.dart';
import 'package:progression_tracker/core/utils/workout_streak_calculator.dart';
import 'package:progression_tracker/features/retention/domain/entities/streak.dart';

void main() {
  group('WorkoutStreakCalculator', () {
    test('counts consecutive days up to today and ignores same-day duplicates', () {
      final today = DateTime(2026, 6, 15, 22, 30);
      final streak = WorkoutStreakCalculator.calculateFromDates(
        [
          DateTime(2026, 6, 15, 7, 0),
          DateTime(2026, 6, 15, 19, 45),
          DateTime(2026, 6, 14, 18, 0),
          DateTime(2026, 6, 13, 8, 15),
          DateTime(2026, 6, 11, 10, 0), // gap breaks streak
        ],
        now: today,
      );

      expect(streak.currentStreak, 3);
      expect(streak.longestStreak, 3);
    });

    test('preserves active streak when trained yesterday but not yet today', () {
      final today = DateTime(2026, 6, 15, 6, 0);
      final streak = WorkoutStreakCalculator.calculateFromDates(
        [
          DateTime(2026, 6, 14, 23, 50),
          DateTime(2026, 6, 13, 12, 0),
        ],
        now: today,
      );

      expect(streak.currentStreak, 2);
      expect(streak.longestStreak, 2);
    });

    test('breaks streak after two days missed while tracking longest streak', () {
      final today = DateTime(2026, 6, 15, 10, 0);
      final streak = WorkoutStreakCalculator.calculateFromDates(
        [
          DateTime(2026, 6, 10, 12, 0),
          DateTime(2026, 6, 9, 12, 0),
          DateTime(2026, 6, 8, 12, 0),
          DateTime(2026, 6, 7, 12, 0),
        ],
        now: today,
      );

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 4);
    });

    test('calendarDayDifference uses local calendar dates regardless of hour offset', () {
      final lateEvening = DateTime(2026, 3, 29, 23, 55);
      final earlyMorning = DateTime(2026, 3, 30, 0, 5);
      // Only 10 minutes apart in wall time, still 1 full calendar day apart.
      expect(
        WorkoutStreakCalculator.calendarDayDifference(lateEvening, earlyMorning),
        1,
      );
    });

    test('Streak entity addWorkout & isActive share canonical calendar-day rules', () {
      final day1 = DateTime(2026, 6, 10, 23, 50);
      final day2 = DateTime(2026, 6, 11, 0, 15);
      final initial = Streak.initial().addWorkout(now: day1);
      final sameDay = initial.addWorkout(now: DateTime(2026, 6, 10, 23, 59));
      final nextDay = sameDay.addWorkout(now: day2);

      expect(initial.currentStreak, 1);
      expect(sameDay.currentStreak, 1);
      expect(nextDay.currentStreak, 2);

      final stale = Streak(
        currentStreak: 2,
        longestStreak: 2,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
        streakStartDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(stale.isActive, isFalse);

      final recent = stale.addWorkout(now: DateTime.now());
      expect(recent.isActive, isTrue);
      expect(recent.currentStreak, 1);
    });
  });

  group('LocalDateWindow', () {
    test('rollingDaysWindow(7) starts at local midnight 6 days before today', () {
      final now = DateTime(2026, 6, 15, 20, 45);
      final window = LocalDateWindow.rollingDaysWindow(7, now: now);

      expect(window.start, DateTime(2026, 6, 9));
      expect(window.endExclusive, DateTime(2026, 6, 16));
      expect(
        LocalDateWindow.contains(
          DateTime(2026, 6, 9, 0, 1),
          window.start,
          window.endExclusive,
        ),
        isTrue,
      );
      expect(
        LocalDateWindow.contains(
          DateTime(2026, 6, 8, 23, 59),
          window.start,
          window.endExclusive,
        ),
        isFalse,
      );
    });

    test('currentWeekWindow starts on Monday local midnight', () {
      // Wednesday June 17, 2026 -> Monday is June 15, 2026
      final wed = DateTime(2026, 6, 17, 15, 0);
      final week = LocalDateWindow.currentWeekWindow(now: wed);

      expect(week.start, DateTime(2026, 6, 15));
      expect(week.endExclusive, DateTime(2026, 6, 22));
      expect(
        LocalDateWindow.contains(
          DateTime(2026, 6, 15, 0, 0),
          week.start,
          week.endExclusive,
        ),
        isTrue,
      );
      expect(
        LocalDateWindow.contains(
          DateTime(2026, 6, 14, 23, 59),
          week.start,
          week.endExclusive,
        ),
        isFalse,
      );
    });
  });
}
