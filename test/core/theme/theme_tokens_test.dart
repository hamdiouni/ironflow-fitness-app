import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';

void main() {
  group('AppThemeTokens ThemeExtension Tests', () {
    test('AppTheme.darkTheme exposes AppThemeTokens.dark', () {
      final darkTheme = AppTheme.darkTheme;
      final tokens = darkTheme.extension<AppThemeTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.isDark, isTrue);
      expect(tokens.kineticAccent, equals(AppColors.kineticAccentDark));
      expect(tokens.canvas, equals(AppColors.canvasDark));
      expect(tokens.card, equals(AppColors.cardDark));
    });

    test('AppTheme.lightTheme exposes AppThemeTokens.light', () {
      final lightTheme = AppTheme.lightTheme;
      final tokens = lightTheme.extension<AppThemeTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.isDark, isFalse);
      expect(tokens.kineticAccent, equals(AppColors.kineticAccentLight));
      expect(tokens.canvas, equals(AppColors.canvasLight));
      expect(tokens.card, equals(AppColors.cardLight));
    });

    test('AppThemeTokens lerp interpolates correctly', () {
      final dark = AppThemeTokens.dark;
      final light = AppThemeTokens.light;

      final midDark = dark.lerp(light, 0.4);
      expect(midDark.isDark, isTrue);
      expect(midDark.canvas, isNot(equals(dark.canvas)));

      final midLight = dark.lerp(light, 0.6);
      expect(midLight.isDark, isFalse);
      expect(midLight.canvas, isNot(equals(light.canvas)));
    });

    test('AppThemeTokens copyWith updates specified tokens', () {
      final dark = AppThemeTokens.dark;
      final custom = dark.copyWith(kineticAccent: const Color(0xFF123456));

      expect(custom.kineticAccent, equals(const Color(0xFF123456)));
      expect(custom.canvas, equals(dark.canvas));
    });

    testWidgets('context.tokens resolves active theme tokens correctly', (tester) async {
      late AppThemeTokens resolvedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              resolvedTokens = context.tokens;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedTokens.isDark, isTrue);
      expect(resolvedTokens.kineticAccent, equals(AppColors.kineticAccentDark));
    });
  });
}
