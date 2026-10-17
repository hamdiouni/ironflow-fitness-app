import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';

Widget _wrap(Widget child, {ThemeData? theme, double textScale = 1.0}) {
  return MaterialApp(
    theme: theme ?? AppTheme.darkTheme,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  group('AppCard Component Tests', () {
    testWidgets('renders child content and applies tap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('renders glowing border when isGlowing is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCard(
            isGlowing: true,
            child: Text('Glowing Card'),
          ),
        ),
      );

      expect(find.text('Glowing Card'), findsOneWidget);
    });
  });

  group('AppButton Component Tests', () {
    testWidgets('renders all variants and satisfies 48dp minimum touch target', (tester) async {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpWidget(
          _wrap(
            AppButton(
              label: 'Button ${variant.name}',
              variant: variant,
              onPressed: () {},
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));
        expect(size.height, greaterThanOrEqualTo(48.0),
            reason: 'Variant ${variant.name} must have at least 48dp touch height');
        expect(find.text('Button ${variant.name}'), findsOneWidget);
      }
    });

    testWidgets('handles tap callback when enabled', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Tap Me',
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('does not trigger callback when disabled', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        _wrap(
          const AppButton(
            label: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'));
      expect(pressed, isFalse);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Saving',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppStatTile Component Tests', () {
    testWidgets('renders metric, unit, title, and delta badge', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppStatTile(
            title: 'Volume',
            value: '12,500',
            unit: 'kg',
            delta: '+5%',
            isPositiveDelta: true,
            icon: const Icon(Icons.fitness_center),
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('12,500'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('+5%'), findsOneWidget);

      await tester.tap(find.text('12,500'));
      expect(tapped, isTrue);
    });
  });

  group('AppProgress Indicators Tests', () {
    testWidgets('AppProgressBar clamps progress safely', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 200,
            child: AppProgressBar(progress: 1.5),
          ),
        ),
      );

      expect(find.byType(AppProgressBar), findsOneWidget);
    });

    testWidgets('AppProgressRing renders centerWidget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppProgressRing(
            progress: 0.75,
            centerWidget: Text('75%'),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });
  });

  group('AppChip Component Tests', () {
    testWidgets('renders selected and unselected states and satisfies 48dp target', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppChip(
            label: 'Hypertrophy',
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppChip));
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(find.text('Hypertrophy'), findsOneWidget);

      await tester.tap(find.text('Hypertrophy'));
      expect(tapped, isTrue);
    });
  });

  group('AppTextField Component Tests', () {
    testWidgets('accepts text input and displays label and helper text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          AppTextField(
            label: 'Workout Name',
            hintText: 'Enter name',
            helperText: 'e.g. Leg Day',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Workout Name'), findsOneWidget);
      expect(find.text('e.g. Leg Day'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Upper Power');
      expect(controller.text, equals('Upper Power'));
    });

    testWidgets('displays errorText when validation fails', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            label: 'Weight',
            errorText: 'Weight cannot be zero',
          ),
        ),
      );

      expect(find.text('Weight cannot be zero'), findsOneWidget);
    });
  });

  group('AppListTile Component Tests', () {
    testWidgets('renders title, subtitle, leading, and trailing', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppListTile(
            title: 'Deadlift',
            subtitle: '5 reps @ 180kg',
            leading: const Icon(Icons.star),
            trailing: const Text('PR'),
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('5 reps @ 180kg'), findsOneWidget);
      expect(find.text('PR'), findsOneWidget);

      await tester.tap(find.text('Deadlift'));
      expect(tapped, isTrue);
    });
  });

  group('AppStateView Component Tests', () {
    testWidgets('renders empty state view', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppStateView.empty(
            title: 'No Workouts Logged',
            message: 'Your training log is empty.',
          ),
        ),
      );

      expect(find.text('No Workouts Logged'), findsOneWidget);
      expect(find.text('Your training log is empty.'), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        _wrap(
          AppStateView.error(
            message: 'Network connection failed',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network connection failed'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });

    testWidgets('renders offline state view', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppStateView.offline(),
        ),
      );

      expect(find.text('You are Offline'), findsOneWidget);
    });
  });

  group('AppSectionHeader Component Tests', () {
    testWidgets('renders title, subtitle, and action button', (tester) async {
      bool actionPressed = false;
      await tester.pumpWidget(
        _wrap(
          AppSectionHeader(
            title: 'Weekly Targets',
            subtitle: 'Track your schedule',
            actionLabel: 'See All',
            onAction: () => actionPressed = true,
          ),
        ),
      );

      expect(find.text('Weekly Targets'), findsOneWidget);
      expect(find.text('Track your schedule'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);

      await tester.tap(find.text('See All'));
      expect(actionPressed, isTrue);
    });
  });

  group('Layout & 1.5x Text Scaling Resilience Tests', () {
    testWidgets('StatTile does not overflow at 1.5x text scale on a small surface', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 140,
            child: AppStatTile(
              title: 'Total Volume',
              value: '124,500',
              unit: 'kg',
              delta: '+12.4%',
            ),
          ),
          textScale: 1.5,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('AppButton does not overflow at 1.5x text scale', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Start Hypertrophy Workout Session Now',
            onPressed: () {},
          ),
          textScale: 1.5,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
