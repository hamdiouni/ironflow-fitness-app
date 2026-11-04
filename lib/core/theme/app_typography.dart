import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Stripe Design System typography styles for IronFlow.
///
/// Adapted from DESIGN.md:
/// - Thin display tier: weight 300 with negative tracking (-1.4px to -0.2px).
/// - Tabular figures: OpenType `tnum` for all numeric counters, weights, reps, and timers.
/// - Body tier: Clean editorial density with Inter, deep navy ink in light mode, pure white in dark.
class AppTypography {
  AppTypography._();

  static const String displayFontFamily = 'Inter';
  static const String bodyFontFamily = 'Inter';
  static const String fontFamilyHeadings = displayFontFamily;
  static const String fontFamilyBody = bodyFontFamily;

  /// Generates a complete Material 3 TextTheme adapted to [isDark].
  static TextTheme createTextTheme({required bool isDark}) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return TextTheme(
      // ── Stripe Displays (Thin 300 weight with editorial negative tracking) ─
      displayLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.96,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.64,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.26,
        color: textPrimary,
      ),

      // ── Stripe Headlines (Heading tiers 22px / 20px / 18px) ───────────────
      headlineLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.22,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textPrimary,
      ),

      // ── Stripe Titles (Card Headers & Section Banners) ────────────────────
      titleLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),

      // ── Stripe Body Copy (body-lg, body-md, caption) ──────────────────────
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.4,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.4,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.39,
        height: 1.4,
        color: textMuted,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),

      // ── Stripe Labels, Pills & Eyebrows (button-md, micro-cap) ─────────────
      labelLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: textMuted,
      ),
    );
  }

  /// Stripe Tabular Numeric style for telemetry metrics, weights, reps, and timers.
  static TextStyle tabularMetric({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double letterSpacing = -0.42,
  }) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: const [
        FontFeature.tabularFigures(),
      ],
    );
  }
}
