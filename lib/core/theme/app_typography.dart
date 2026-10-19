import 'package:flutter/material.dart';

/// Monolithic Sci-Fi typography styles.
///
/// Combines [SpaceGrotesk] for geometric technical displays, headers, and tabular
/// telemetry metrics, with [Inter] for high-readability body copy and input labels.
class AppTypography {
  AppTypography._();

  static const String displayFontFamily = 'SpaceGrotesk';
  static const String bodyFontFamily = 'Inter';
  static const String fontFamilyHeadings = displayFontFamily;
  static const String fontFamilyBody = bodyFontFamily;

  /// Generates a complete Material 3 TextTheme adapted to [isDark].
  static TextTheme createTextTheme({required bool isDark}) {
    final textPrimary = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0E1015);
    final textSecondary = isDark ? const Color(0xFF8E95A5) : const Color(0xFF555C6E);
    final textMuted = isDark ? const Color(0xFF525866) : const Color(0xFF8C93A4);

    return TextTheme(
      // ── Displays (High-Impact Hero Text) ───────────────────────────────────
      displayLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: textPrimary,
      ),

      // ── Headlines (Screen Titles & Major Modules) ─────────────────────────
      headlineLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: textPrimary,
      ),

      // ── Titles (Card Headers & Section Banners) ───────────────────────────
      titleLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),

      // ── Body Copy (Standard UI, Descriptions) ─────────────────────────────
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.45,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.35,
        color: textMuted,
      ),

      // ── Labels & Badges ────────────────────────────────────────────────────
      labelLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: textMuted,
      ),
    );
  }

  /// Numeric tabular style for metric counters, workout sets, and timers.
  static TextStyle tabularMetric({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.5,
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
