import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme_tokens.dart';
import '../theme/app_typography.dart';

export '../theme/app_colors.dart';
export '../theme/app_spacings.dart';
export '../theme/app_theme_tokens.dart';
export '../theme/app_typography.dart';

/// IronFlow application theme — Monolithic Sci-Fi styling with dark and light modes.
class AppTheme {
  // ── Brand colors (same in both modes) ──────────────────────────────────────
  static const Color primaryColor = Color(0xFF00FF87);   // Monolithic Neon green
  static const Color accentColor  = Color(0xFF00D2FF);   // Cyan pulse
  static const Color warningColor = Color(0xFFFFB800);
  static const Color errorColor   = Color(0xFFFF3B56);
  static const Color successColor = Color(0xFF00FF87);

  // Macro colors
  static const Color proteinColor = Color(0xFFFF4B6E);
  static const Color carbsColor   = Color(0xFF00D2FF);
  static const Color fatsColor    = Color(0xFFFFB800);

  // ── Dark mode palette ───────────────────────────────────────────────────────
  static const Color darkBackground = AppColors.canvasDark;
  static const Color darkSurface    = AppColors.panelDark;
  static const Color darkCard       = AppColors.cardDark;
  static const Color darkTextPrimary   = AppColors.textPrimaryDark;
  static const Color darkTextSecondary = AppColors.textSecondaryDark;
  static const Color darkTextDisabled  = AppColors.textMutedDark;

  // ── Light mode palette ──────────────────────────────────────────────────────
  static const Color lightBackground = AppColors.canvasLight;
  static const Color lightSurface    = AppColors.panelLight;
  static const Color lightCard       = AppColors.cardLight;
  static const Color lightTextPrimary   = AppColors.textPrimaryLight;
  static const Color lightTextSecondary = AppColors.textSecondaryLight;
  static const Color lightTextDisabled  = AppColors.textMutedLight;

  // ── Static aliases kept for backward compat with existing widgets ───────────
  // These resolve to dark-mode values (existing code uses them directly).
  static const Color backgroundColor = darkBackground;
  static const Color surfaceColor    = darkSurface;
  static const Color textPrimary     = darkTextPrimary;
  static const Color textSecondary   = darkTextSecondary;
  static const Color textDisabled    = darkTextDisabled;

  // ── Spacing ─────────────────────────────────────────────────────────────────
  static const double spacingXSmall  = 4.0;
  static const double spacingSmall   = 8.0;
  static const double spacingMedium  = 16.0;
  static const double spacingLarge   = 24.0;
  static const double spacingXLarge  = 32.0;

  // ── Border radius ───────────────────────────────────────────────────────────
  static const double borderRadiusSmall  = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge  = 24.0;

  // ── Glassmorphism ───────────────────────────────────────────────────────────
  static const double glassBlurSigma = 10.0;

  // ── Dark theme ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // ── Light theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final tokens = isDark ? AppThemeTokens.dark : AppThemeTokens.light;
    final bg = tokens.canvas;
    final surface = tokens.panel;
    final onSurf = tokens.textPrimary;
    final onSurf2 = tokens.textSecondary;
    final disabled = tokens.textMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: tokens.kineticAccent,
      scaffoldBackgroundColor: bg,
      extensions: [tokens],
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        color: tokens.card,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: onSurf,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          color: onSurf,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.panel,
        selectedItemColor: tokens.kineticAccent,
        unselectedItemColor: tokens.textTertiary,
        selectedLabelStyle: const TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: tokens.kineticAccent,
        unselectedLabelColor: onSurf2,
        indicatorColor: tokens.kineticAccent,
        labelStyle: const TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.kineticAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.kineticAccent,
          side: BorderSide(color: tokens.kineticAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.elevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
        ),
        labelStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          color: onSurf2,
        ),
        hintStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          color: disabled,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),
      textTheme: AppTypography.createTextTheme(isDark: isDark),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: tokens.kineticAccent,
        onPrimary: Colors.black,
        secondary: tokens.cyanAccent,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: onSurf,
        error: tokens.error,
        onError: Colors.white,
      ),
      dividerColor: tokens.borderSubtle,
      iconTheme: IconThemeData(color: onSurf2),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.elevated,
        labelStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          color: onSurf,
        ),
        side: BorderSide(color: tokens.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.card,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurf,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.panel,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  /// Glassmorphic card — adapts to current theme brightness.
  static Widget glassmorphicCard({
    required Widget child,
    double borderRadius = borderRadiusMedium,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bg = backgroundColor ??
          (isDark ? darkSurface : lightSurface);
      final border = borderColor ??
          (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08));

      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: glassBlurSigma, sigmaY: glassBlurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: bg.withValues(alpha: isDark ? 0.6 : 0.85),
                border: Border.all(color: border, width: 1),
              ),
              child: child,
            ),
          ),
        ),
      );
    });
  }

  AppTheme._();
}

// ── Backward-compat static decoration helpers (used by tests) ────────────────
extension AppThemeDecorations on AppTheme {
  static BoxDecoration glassmorphicCardDecoration({
    double borderRadius = AppTheme.borderRadiusMedium,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: (backgroundColor ?? AppTheme.surfaceColor).withValues(alpha: 0.6),
      border: Border.all(
        color: (borderColor ?? Colors.white).withValues(alpha: 0.08),
        width: 1,
      ),
    );
  }

  static BoxDecoration glassmorphicGradientDecoration({
    double borderRadius = AppTheme.borderRadiusLarge,
    required List<Color> gradientColors,
    Color? borderColor,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: gradientColors.map((c) => c.withValues(alpha: 0.7)).toList(),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: (borderColor ?? Colors.white).withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }
}

