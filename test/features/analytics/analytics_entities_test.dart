import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/analytics/domain/entities/consistency_metrics.dart';
import 'package:progression_tracker/features/analytics/domain/entities/weight_tracking.dart';

void main() {
  group('Analytics Domain Entities', () {
    test('ConsistencyMetrics computes rating tiers, consistency, and day names', () {
      final start = DateTime(2026, 1, 5);
      final end = DateTime(2026, 2, 2);
      final week = WeeklyConsistency(
        weekStart: start,
        workoutsCompleted: 4,
        workoutsPlanned: 4,
        dailyStatus: const [true, false, true, false, true, true, false],
        totalVolume: 12000,
        adherenceRate: 1.0,
      );

      final excellent = ConsistencyMetrics(
        userId: 'u1',
        totalWorkouts: 16,
        totalWeeks: 4,
        averageWorkoutsPerWeek: 4.0,
        currentStreak: 3,
        longestStreak: 5,
        adherenceRate: 0.92,
        weeklyData: [week],
        mostActiveDay: 0,
        leastActiveDay: 6,
        averageDuration: 55.0,
        startDate: start,
        endDate: end,
      );

      expect(excellent.rating, ConsistencyRating.excellent);
      expect(excellent.isConsistent, isTrue);
      expect(excellent.mostActiveDayName, 'Monday');
      expect(excellent.leastActiveDayName, 'Sunday');

      expect(excellent.copyWith(adherenceRate: 0.8).rating, ConsistencyRating.good);
      expect(excellent.copyWith(adherenceRate: 0.6).rating, ConsistencyRating.fair);
      final low = excellent.copyWith(adherenceRate: 0.3);
      expect(low.rating, ConsistencyRating.needsImprovement);
      expect(low.isConsistent, isFalse);

      final decoded = ConsistencyMetrics.fromJson(excellent.toJson());
      expect(decoded.totalWorkouts, 16);
      expect(WeeklyConsistency.fromJson(week.toJson()).workoutsCompleted, 4);
    });

    test('WeightTracking evaluates goal alignment, percentage, trend, and JSON', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 29);
      final m = WeightMeasurement(date: end, weight: 73.0, note: 'Morning');

      final losing = WeightTracking(
        userId: 'u1',
        measurements: [m],
        currentWeight: 73.0,
        startingWeight: 75.0,
        goalWeight: 70.0,
        totalChange: -2.0,
        averageWeeklyChange: -0.5,
        startDate: start,
        endDate: end,
      );
      expect(losing.isOnTrack, isTrue);
      expect(losing.progressPercentage, closeTo(40.0, 0.1));
      expect(losing.trend, WeightTrend.decreasing);

      final gaining = losing.copyWith(
        startingWeight: 70.0,
        currentWeight: 72.0,
        goalWeight: 75.0,
        averageWeeklyChange: 0.5,
      );
      expect(gaining.isOnTrack, isTrue);
      expect(gaining.trend, WeightTrend.increasing);

      final flat = gaining.copyWith(averageWeeklyChange: 0.05);
      expect(flat.trend, WeightTrend.stable);

      expect(WeightTracking.fromJson(losing.toJson()).currentWeight, 73.0);
      expect(WeightMeasurement.fromJson(m.toJson()).weight, 73.0);
    });
  });
}
