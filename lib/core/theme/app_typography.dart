import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography tokens for Option B: Iron Scoreboard (`02-kinetic-block`).
///
/// - Headings & numeric metrics: `SpaceGrotesk` with tabular figures (`tnum`).
/// - Body & controls: `Inter` for crisp small-size readability.
class AppTypography {
  AppTypography._();

  static const String displayFontFamily = 'SpaceGrotesk';
  static const String bodyFontFamily = 'Inter';
  static const String fontFamilyHeadings = displayFontFamily;
  static const String fontFamilyBody = bodyFontFamily;

  /// Generates a Material 3 [TextTheme] adapted to [isDark].
  static TextTheme createTextTheme({required bool isDark}) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      headlineLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textMuted,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: textMuted,
      ),
    );
  }

  /// Tabular numeric style for weights, reps, timers, and scoreboard callouts.
  static TextStyle tabularMetric({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.35,
  }) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
