import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/quick_feedback_bottom_sheet.dart';

void main() {
  final sampleFeedback = Insight(
    id: 'test_feedback_1',
    context: InsightContext.workout,
    title: 'New PR Achieved! 🏆',
    message: 'You smashed your previous deadlift record by 5kg! Outstanding work today.',
    icon: 'emoji_events',
    priority: InsightPriority.high,
    generatedAt: DateTime(2026, 1, 1),
  );

  Widget buildWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickFeedbackBottomSheet(
              feedback: sampleFeedback,
            ),
          ),
        ),
      ),
    );
  }

  group('QuickFeedbackBottomSheet Screen Size & Overflow Tests', () {
    testWidgets('renders without overflow on compact screen (320x480)', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('New PR Achieved! 🏆'), findsOneWidget);
      expect(find.byType(QuickFeedbackBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on standard mobile screen (390x844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('New PR Achieved! 🏆'), findsOneWidget);
      expect(find.byType(QuickFeedbackBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on large tablet screen (800x1280)', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('New PR Achieved! 🏆'), findsOneWidget);
      expect(find.byType(QuickFeedbackBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
