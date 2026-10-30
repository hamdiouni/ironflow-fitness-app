import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _relativeLuminance(Color color) {
  final r = _channel(color.r);
  final g = _channel(color.g);
  final b = _channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Part 3.2: Slate Teal Token & WCAG AA Contrast Verification', () {
    test('Dark Mode tokens pass WCAG AA contrast (≥ 4.5:1 normal text)', () {
      final d = AppThemeTokens.dark;

      expect(d.kineticAccent, equals(const Color(0xFF2DD4BF)));
      expect(d.onAccent, equals(const Color(0xFF042F2E)));
      expect(d.canvas, equals(const Color(0xFF0B1218)));
      expect(d.panel, equals(const Color(0xFF131D26)));
      expect(d.card, equals(const Color(0xFF131D26)));
      expect(d.elevated, equals(const Color(0xFF1C2A36)));

      // Contrast audits
      final textOnCanvas = _contrastRatio(d.textPrimary, d.canvas);
      expect(textOnCanvas, greaterThanOrEqualTo(4.5), reason: 'textPrimary on canvas');

      final textOnSurface = _contrastRatio(d.textPrimary, d.panel);
      expect(textOnSurface, greaterThanOrEqualTo(4.5), reason: 'textPrimary on panel');

      final textOnRaised = _contrastRatio(d.textPrimary, d.elevated);
      expect(textOnRaised, greaterThanOrEqualTo(4.5), reason: 'textPrimary on elevated');

      final secTextOnCanvas = _contrastRatio(d.textSecondary, d.canvas);
      expect(secTextOnCanvas, greaterThanOrEqualTo(4.5), reason: 'textSecondary on canvas');

      final onAccentOnAccent = _contrastRatio(d.onAccent, d.kineticAccent);
      expect(onAccentOnAccent, greaterThanOrEqualTo(4.5), reason: 'onAccent on kineticAccent');

      final accentOnSurface = _contrastRatio(d.kineticAccent, d.panel);
      expect(accentOnSurface, greaterThanOrEqualTo(4.5), reason: 'accent on panel');

      final successOnSurface = _contrastRatio(d.success, d.panel);
      expect(successOnSurface, greaterThanOrEqualTo(4.5), reason: 'success on panel');

      final warningOnSurface = _contrastRatio(d.warning, d.panel);
      expect(warningOnSurface, greaterThanOrEqualTo(4.5), reason: 'warning on panel');

      final errorOnSurface = _contrastRatio(d.error, d.panel);
      expect(errorOnSurface, greaterThanOrEqualTo(4.5), reason: 'error on panel');
    });

    test('Light Mode tokens pass WCAG AA contrast (≥ 4.5:1 normal text)', () {
      final l = AppThemeTokens.light;

      expect(l.kineticAccent, equals(const Color(0xFF0F766E)));
      expect(l.onAccent, equals(const Color(0xFFFFFFFF)));
      expect(l.canvas, equals(const Color(0xFFF4F7F9)));
      expect(l.panel, equals(const Color(0xFFFFFFFF)));
      expect(l.card, equals(const Color(0xFFFFFFFF)));
      expect(l.elevated, equals(const Color(0xFFE9EFF3)));

      // Contrast audits
      final textOnCanvas = _contrastRatio(l.textPrimary, l.canvas);
      expect(textOnCanvas, greaterThanOrEqualTo(4.5), reason: 'textPrimary on canvas');

      final textOnSurface = _contrastRatio(l.textPrimary, l.panel);
      expect(textOnSurface, greaterThanOrEqualTo(4.5), reason: 'textPrimary on panel');

      final textOnRaised = _contrastRatio(l.textPrimary, l.elevated);
      expect(textOnRaised, greaterThanOrEqualTo(4.5), reason: 'textPrimary on elevated');

      final secTextOnCanvas = _contrastRatio(l.textSecondary, l.canvas);
      expect(secTextOnCanvas, greaterThanOrEqualTo(4.5), reason: 'textSecondary on canvas');

      final onAccentOnAccent = _contrastRatio(l.onAccent, l.kineticAccent);
      expect(onAccentOnAccent, greaterThanOrEqualTo(4.5), reason: 'onAccent on kineticAccent in light mode');

      final accentOnSurface = _contrastRatio(l.kineticAccent, l.panel);
      expect(accentOnSurface, greaterThanOrEqualTo(4.5), reason: 'accent on panel in light mode');

      final successOnSurface = _contrastRatio(l.success, l.panel);
      expect(successOnSurface, greaterThanOrEqualTo(4.5), reason: 'success on panel');

      final warningOnSurface = _contrastRatio(l.warning, l.panel);
      expect(warningOnSurface, greaterThanOrEqualTo(4.5), reason: 'warning on panel');

      final errorOnSurface = _contrastRatio(l.error, l.panel);
      expect(errorOnSurface, greaterThanOrEqualTo(4.5), reason: 'error on panel');
    });

    test('Radii and spacing scales follow 3-tier rules', () {
      expect(AppSpacings.radiusSm, equals(8.0));
      expect(AppSpacings.radiusMd, equals(12.0));
      expect(AppSpacings.radiusLg, equals(14.0));
      expect(AppSpacings.minTouchTarget, equals(48.0));
    });
  });

  group('Part 3.3: Component Upgrades & States Verification', () {
    Widget buildTestHarness(Widget child, {ThemeMode mode = ThemeMode.dark}) {
      return MaterialApp(
        themeMode: mode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('AppButton renders all variants with correct text and colors', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          Column(
            children: [
              AppButton(label: 'Primary', variant: AppButtonVariant.primary, onPressed: () {}),
              AppButton(label: 'Secondary', variant: AppButtonVariant.secondary, onPressed: () {}),
              AppButton(label: 'Outline', variant: AppButtonVariant.outline, onPressed: () {}),
              AppButton(label: 'Ghost', variant: AppButtonVariant.ghost, onPressed: () {}),
              AppButton(label: 'Tertiary', variant: AppButtonVariant.tertiary, onPressed: () {}),
              AppButton(label: 'Destructive', variant: AppButtonVariant.destructive, onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Ghost'), findsOneWidget);
      expect(find.text('Tertiary'), findsOneWidget);
      expect(find.text('Destructive'), findsOneWidget);
    });

    testWidgets('AppButton loading state replaces text with spinner and preserves width', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          AppButton(
            label: 'Save Workout',
            isLoading: true,
            isFullWidth: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save Workout'), findsNothing);
    });

    testWidgets('AppIconButton enforces 48x48 touch target', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          AppIconButton(
            icon: const Icon(Icons.fitness_center),
            tooltip: 'Training',
            onPressed: () {},
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppIconButton));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('AppCard renders frame-light without border by default, and with border when selected', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          Column(
            children: [
              const AppCard(child: Text('Frame-Light Card')),
              AppCard.selected(child: const Text('Selected Card')),
            ],
          ),
        ),
      );

      expect(find.text('Frame-Light Card'), findsOneWidget);
      expect(find.text('Selected Card'), findsOneWidget);
    });

    testWidgets('AppSnackbar displays floating feedback with icon and action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => AppButton(
                label: 'Show Toast',
                onPressed: () {
                  AppSnackbar.showSuccess(
                    ctx,
                    'Saved successfully!',
                    actionLabel: 'Undo',
                    onAction: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Saved successfully!'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('AppDialog constrains width on wide screens and has confirm/cancel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => AppButton(
                label: 'Open Dialog',
                onPressed: () {
                  AppDialog.show(
                    context: ctx,
                    title: 'Discard Changes?',
                    content: const Text('All unsaved edits will be lost.'),
                    confirmLabel: 'Discard',
                    cancelLabel: 'Keep Editing',
                    isDestructive: true,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Discard Changes?'), findsOneWidget);
      expect(find.text('All unsaved edits will be lost.'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Keep Editing'), findsOneWidget);
    });
  });
}

