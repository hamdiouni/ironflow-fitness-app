import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/body/domain/entities/weight_data_point.dart';
import 'package:progression_tracker/shared/widgets/weight_trend_graph.dart';

void main() {
  group('WeightTrendGraph Logic Tests', () {
    test('calculateMovingAverageSpots returns empty for empty input', () {
      final spots = WeightTrendGraph.calculateMovingAverageSpots(
        allPoints: [],
        sampledPoints: [],
      );
      expect(spots, isEmpty);
    });

    test('calculateMovingAverageSpots calculates 7-day trailing average correctly', () {
      final now = DateTime(2026, 5, 10);
      final points = [
        WeightDataPoint(date: now.subtract(const Duration(days: 3)), weight: 80.0),
        WeightDataPoint(date: now.subtract(const Duration(days: 2)), weight: 81.0),
        WeightDataPoint(date: now.subtract(const Duration(days: 1)), weight: 82.0),
        WeightDataPoint(date: now, weight: 83.0),
      ];

      final spots = WeightTrendGraph.calculateMovingAverageSpots(
        allPoints: points,
        sampledPoints: points,
        daysWindow: 7,
      );

      expect(spots.length, equals(4));
      // First point: only 80.0 -> 80.0
      expect(spots[0].y, equals(80.0));
      // Second point: 80.0, 81.0 -> 80.5
      expect(spots[1].y, equals(80.5));
      // Third point: 80.0, 81.0, 82.0 -> 81.0
      expect(spots[2].y, equals(81.0));
      // Fourth point: 80.0, 81.0, 82.0, 83.0 -> 81.5
      expect(spots[3].y, equals(81.5));
    });

    test('generateTrendSummary handles empty points', () {
      final summary = WeightTrendGraph.generateTrendSummary(points: []);
      expect(summary, contains('No weight data logged yet'));
    });

    test('generateTrendSummary handles single point with and without goal', () {
      final p1 = WeightDataPoint(date: DateTime(2026, 5, 1), weight: 80.0);
      final withoutGoal = WeightTrendGraph.generateTrendSummary(points: [p1]);
      expect(withoutGoal, contains('Current: 80.0 kg'));
      expect(withoutGoal, contains('Log another weigh-in'));

      final withGoal = WeightTrendGraph.generateTrendSummary(
        points: [p1],
        targetWeight: 75.0,
      );
      expect(withGoal, contains('Current: 80.0 kg'));
      expect(withGoal, contains('5.0 kg to 75.0 kg goal'));
    });

    test('generateTrendSummary reports downward trend and goal distance', () {
      final now = DateTime(2026, 5, 10);
      final points = [
        WeightDataPoint(date: now.subtract(const Duration(days: 7)), weight: 80.5),
        WeightDataPoint(date: now, weight: 79.8),
      ];

      final summary = WeightTrendGraph.generateTrendSummary(
        points: points,
        targetWeight: 75.0,
      );

      expect(summary, contains('Down 0.7 kg this week'));
      expect(summary, contains('4.8 kg to 75.0 kg goal'));
    });

    test('generateTrendSummary reports upward trend and goal distance', () {
      final now = DateTime(2026, 5, 10);
      final points = [
        WeightDataPoint(date: now.subtract(const Duration(days: 7)), weight: 75.0),
        WeightDataPoint(date: now, weight: 75.8),
      ];

      final summary = WeightTrendGraph.generateTrendSummary(
        points: points,
        targetWeight: 80.0,
      );

      expect(summary, contains('Up 0.8 kg this week'));
      expect(summary, contains('4.2 kg to 80.0 kg goal'));
    });

    test('generateTrendSummary reports stable trend when delta is minimal', () {
      final now = DateTime(2026, 5, 10);
      final points = [
        WeightDataPoint(date: now.subtract(const Duration(days: 7)), weight: 75.0),
        WeightDataPoint(date: now, weight: 75.05),
      ];

      final summary = WeightTrendGraph.generateTrendSummary(
        points: points,
        targetWeight: 75.0,
      );

      expect(summary, contains('Stable (this week)'));
      expect(summary, contains('Goal reached! 🎉'));
    });
  });

  group('WeightTrendGraph Widget Tests', () {
    testWidgets('Renders empty state when dataPoints is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeightTrendGraph(dataPoints: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No weight data yet'), findsOneWidget);
    });

    testWidgets('Renders legend, chart, and trend summary card when dataPoints provided', (tester) async {
      final now = DateTime(2026, 5, 10);
      final points = [
        WeightDataPoint(date: now.subtract(const Duration(days: 7)), weight: 82.0),
        WeightDataPoint(date: now.subtract(const Duration(days: 3)), weight: 81.5),
        WeightDataPoint(date: now, weight: 81.0),
      ];

      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WeightTrendGraph(
                dataPoints: points,
                targetWeight: 78.0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Legend items
      expect(find.text('7-Day Trend'), findsOneWidget);
      expect(find.text('Daily Entry'), findsOneWidget);
      expect(find.text('Goal (78.0 kg)'), findsOneWidget);

      // Trend summary card
      expect(find.byKey(const ValueKey('weight_trend_summary_card')), findsOneWidget);
      expect(find.textContaining('Down 1.0 kg this week'), findsOneWidget);
      expect(find.textContaining('3.0 kg to 78.0 kg goal'), findsOneWidget);
    });
  });
}
