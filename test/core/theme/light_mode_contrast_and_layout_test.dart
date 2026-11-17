import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_recovery_status.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_view.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

double _relativeLuminance(Color c) {
  double linearize(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linearize(c.r) +
      0.7152 * linearize(c.g) +
      0.0722 * linearize(c.b);
}

double _contrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

class _FixedUnitsNotifier extends UnitsNotifier {
  @override
  UnitsSystem build() => UnitsSystem.metric;
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  group('Iron Scoreboard Light & Dark Contrast + Responsive 360px/900px/1.5x', () {
    test('accent and semantic tokens meet WCAG AA (>= 4.5:1) in dark and light', () {
      for (final tokens in [AppThemeTokens.dark, AppThemeTokens.light]) {
        expect(
          _contrastRatio(tokens.onAccent, tokens.kineticAccent),
          greaterThanOrEqualTo(4.5),
          reason: '${tokens.isDark ? "Dark" : "Light"} onAccent vs kineticAccent',
        );
        expect(
          _contrastRatio(tokens.textPrimary, tokens.canvas),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(tokens.textPrimary, tokens.panel),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(tokens.textSecondary, tokens.panel),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(tokens.textMuted, tokens.panel),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    testWidgets('Primary AppButton uses high-contrast onAccent foreground in light mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppButton(
                label: 'LOG TO TODAY',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('LOG TO TODAY'));
      expect(textWidget.style?.color, AppThemeTokens.light.onAccent);
      expect(
        _contrastRatio(
          textWidget.style!.color!,
          AppThemeTokens.light.kineticAccent,
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('BodyMapView handles 360px at 1.5x text scale and 1280px 2-pane in light mode without overflow',
        (tester) async {
      for (final size in const [Size(360, 800), Size(1280, 800)]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              unitsProvider.overrideWith(_FixedUnitsNotifier.new),
              muscleRecoveryProvider.overrideWithValue(
                AsyncValue.data({
                  for (final region in MuscleRegion.values)
                    region: MuscleRecoveryData.fresh(region),
                }),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: const TextScaler.linear(1.5),
                  ),
                  child: const BodyMapView(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Unexpected overflow/exception at $size with 1.5x text scale',
        );
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}
