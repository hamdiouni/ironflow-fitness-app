import 'dart:ui';
import 'package:flutter/material.dart';

/// IronFlow application theme — supports dark and light modes.
class AppTheme {
  // ── Brand colors (same in both modes) ──────────────────────────────────────
  static const Color primaryColor = Color(0xFF00E676);   // Neon green
  static const Color accentColor  = Color(0xFF00B0FF);   // Neon blue
  static const Color warningColor = Color(0xFFFF9500);
  static const Color errorColor   = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF00E676);

  // Macro colors
  static const Color proteinColor = Color(0xFFFF5252);
  static const Color carbsColor   = Color(0xFF448AFF);
  static const Color fatsColor    = Color(0xFFFFD740);

  // ── Dark mode palette ───────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface    = Color(0xFF1A1A1A);
  static const Color darkCard       = Color(0xFF1E1E1E);
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled  = Color(0xFF555555);

  // ── Light mode palette ──────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightTextPrimary   = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextDisabled  = Color(0xFFBBBBBB);

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
    final bg      = isDark ? darkBackground    : lightBackground;
    final surface = isDark ? darkSurface       : lightSurface;
    final onSurf  = isDark ? darkTextPrimary   : lightTextPrimary;
    final onSurf2 = isDark ? darkTextSecondary : lightTextSecondary;
    final disabled = isDark ? darkTextDisabled : lightTextDisabled;

    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bg,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        color: surface.withValues(alpha: 0.8),
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: onSurf,
        titleTextStyle: TextStyle(
          color: onSurf,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF111111) : lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: onSurf2,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: onSurf2,
        indicatorColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: onSurf2),
        hintStyle: TextStyle(color: disabled),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: onSurf),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurf),
        displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurf),
        headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurf),
        titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurf),
        bodyLarge:     TextStyle(fontSize: 16, color: onSurf),
        bodyMedium:    TextStyle(fontSize: 14, color: onSurf2),
        bodySmall:     TextStyle(fontSize: 12, color: onSurf2),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.black,
        secondary: accentColor,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: onSurf,
        error: errorColor,
        onError: Colors.white,
      ),
      dividerColor: isDark ? Colors.white12 : Colors.black12,
      iconTheme: IconThemeData(color: onSurf2),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        labelStyle: TextStyle(color: onSurf),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
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

