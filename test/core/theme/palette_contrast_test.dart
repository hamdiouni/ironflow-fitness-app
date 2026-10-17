import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_colors.dart';

/// Calculates relative luminance according to WCAG 2.1 specs.
double _relativeLuminance(Color color) {
  double channel(double c) {
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Calculates contrast ratio between two colors (range: 1.0 to 21.0).
double _contrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Monolithic Sci-Fi Palette WCAG Contrast Tests', () {
    test('Dark Mode textPrimary meets WCAG AAA (>= 7.0) on all dark surfaces', () {
      final text = AppColors.textPrimaryDark;
      final canvasRatio = _contrastRatio(text, AppColors.canvasDark);
      final panelRatio = _contrastRatio(text, AppColors.panelDark);
      final cardRatio = _contrastRatio(text, AppColors.cardDark);

      expect(canvasRatio, greaterThanOrEqualTo(7.0),
          reason: 'textPrimary on canvasDark should pass AAA');
      expect(panelRatio, greaterThanOrEqualTo(7.0),
          reason: 'textPrimary on panelDark should pass AAA');
      expect(cardRatio, greaterThanOrEqualTo(7.0),
          reason: 'textPrimary on cardDark should pass AAA');
    });

    test('Dark Mode kineticAccent meets WCAG AA (>= 4.5) on dark card and panel', () {
      final accent = AppColors.kineticAccentDark;
      final canvasRatio = _contrastRatio(accent, AppColors.canvasDark);
      final cardRatio = _contrastRatio(accent, AppColors.cardDark);

      expect(canvasRatio, greaterThanOrEqualTo(4.5),
          reason: 'kineticAccentDark on canvasDark should pass AA');
      expect(cardRatio, greaterThanOrEqualTo(4.5),
          reason: 'kineticAccentDark on cardDark should pass AA');
    });

    test('Dark Mode textSecondary meets WCAG AA (>= 4.5) on dark card', () {
      final textSec = AppColors.textSecondaryDark;
      final cardRatio = _contrastRatio(textSec, AppColors.cardDark);

      expect(cardRatio, greaterThanOrEqualTo(4.5),
          reason: 'textSecondary on cardDark should pass AA');
    });

    test('Light Mode textPrimary meets WCAG AAA (>= 7.0) on light surfaces', () {
      final text = AppColors.textPrimaryLight;
      final canvasRatio = _contrastRatio(text, AppColors.canvasLight);
      final cardRatio = _contrastRatio(text, AppColors.cardLight);

      expect(canvasRatio, greaterThanOrEqualTo(7.0),
          reason: 'textPrimaryLight on canvasLight should pass AAA');
      expect(cardRatio, greaterThanOrEqualTo(7.0),
          reason: 'textPrimaryLight on cardLight should pass AAA');
    });

    test('Light Mode kineticAccent meets WCAG AA (>= 4.5) on light surfaces', () {
      final accent = AppColors.kineticAccentLight;
      final canvasRatio = _contrastRatio(accent, AppColors.canvasLight);
      final cardRatio = _contrastRatio(accent, AppColors.cardLight);

      expect(canvasRatio, greaterThanOrEqualTo(4.5),
          reason: 'kineticAccentLight on canvasLight should pass AA');
      expect(cardRatio, greaterThanOrEqualTo(4.5),
          reason: 'kineticAccentLight on cardLight should pass AA');
    });

    test('Light Mode textSecondary meets WCAG AA (>= 4.5) on light card', () {
      final textSec = AppColors.textSecondaryLight;
      final cardRatio = _contrastRatio(textSec, AppColors.cardLight);

      expect(cardRatio, greaterThanOrEqualTo(4.5),
          reason: 'textSecondary on cardLight should pass AA');
    });

    test('Semantic alert colors meet WCAG AA on their respective dark cards', () {
      final errorRatio = _contrastRatio(AppColors.errorDark, AppColors.cardDark);
      final warningRatio = _contrastRatio(AppColors.warningDark, AppColors.cardDark);
      final cyanRatio = _contrastRatio(AppColors.cyanAccentDark, AppColors.cardDark);

      expect(errorRatio, greaterThanOrEqualTo(4.5));
      expect(warningRatio, greaterThanOrEqualTo(4.5));
      expect(cyanRatio, greaterThanOrEqualTo(4.5));
    });
  });
}
