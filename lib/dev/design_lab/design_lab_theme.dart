import 'package:flutter/material.dart';

enum DesignDirection {
  slateTeal('Direction 1: Slate Teal Refined', '01-slate-teal', 'Calm architectural slate with precise kinetic teal accents and brisk motion.'),
  nordicMinimal('Direction 2: Nordic Minimal', '02-nordic-calm', 'Serene, breathing space with muted tones, pill geometry, and gentle transitions.'),
  kineticAthletic('Direction 3: Kinetic Athletic', '03-kinetic-block', 'High-energy sports telemetry with dense bento grids and technical chamfers.'),
  softLayered('Direction 4: Soft Layered', '04-soft-layered', 'Tactile surfaces with ambient depth, generous curves, and progressive cards.');

  final String title;
  final String slug;
  final String summary;
  const DesignDirection(this.title, this.slug, this.summary);
}

class DesignTokens {
  final DesignDirection direction;
  final bool isDark;

  // Colors
  final Color canvas;
  final Color panel;
  final Color elevated;
  final Color borderSubtle;
  final Color accent;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;

  // Shape & Radii
  final double chipRadius;
  final double buttonRadius;
  final double cardRadius;
  final double sheetRadius;

  // Motion
  final Duration durationQuick;
  final Duration durationNormal;
  final Duration durationSlow;
  final Curve curveQuick;
  final Curve curveNormal;
  final Curve curveSlow;

  // Fonts
  final String displayFont;
  final String bodyFont;

  const DesignTokens({
    required this.direction,
    required this.isDark,
    required this.canvas,
    required this.panel,
    required this.elevated,
    required this.borderSubtle,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.chipRadius,
    required this.buttonRadius,
    required this.cardRadius,
    required this.sheetRadius,
    required this.durationQuick,
    required this.durationNormal,
    required this.durationSlow,
    required this.curveQuick,
    required this.curveNormal,
    required this.curveSlow,
    required this.displayFont,
    required this.bodyFont,
  });

  factory DesignTokens.fromDirection(DesignDirection direction, {required bool isDark}) {
    switch (direction) {
      case DesignDirection.slateTeal:
        return DesignTokens(
          direction: direction,
          isDark: isDark,
          canvas: isDark ? const Color(0xFF0B1218) : const Color(0xFFF4F7F9),
          panel: isDark ? const Color(0xFF131D26) : const Color(0xFFFFFFFF),
          elevated: isDark ? const Color(0xFF1C2A36) : const Color(0xFFE9EFF3),
          borderSubtle: isDark ? const Color(0xFF243443) : const Color(0xFFD5DEE5),
          accent: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
          onAccent: isDark ? const Color(0xFF042F2E) : const Color(0xFFFFFFFF),
          textPrimary: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          textSecondary: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          textMuted: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
          success: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          warning: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          error: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          chipRadius: 8.0,
          buttonRadius: 12.0,
          cardRadius: 14.0,
          sheetRadius: 20.0,
          durationQuick: const Duration(milliseconds: 140),
          durationNormal: const Duration(milliseconds: 240),
          durationSlow: const Duration(milliseconds: 360),
          curveQuick: Curves.easeOutCubic,
          curveNormal: Curves.easeOutCubic,
          curveSlow: Curves.easeInOutCubic,
          displayFont: 'SpaceGrotesk',
          bodyFont: 'Inter',
        );

      case DesignDirection.nordicMinimal:
        return DesignTokens(
          direction: direction,
          isDark: isDark,
          canvas: isDark ? const Color(0xFF101316) : const Color(0xFFFAF9F6),
          panel: isDark ? const Color(0xFF191D22) : const Color(0xFFFFFFFF),
          elevated: isDark ? const Color(0xFF232830) : const Color(0xFFF2EFE9),
          borderSubtle: isDark ? const Color(0xFF2D333D) : const Color(0xFFE5E0D8),
          accent: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0D9488),
          onAccent: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
          textPrimary: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1C1917),
          textSecondary: isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C),
          textMuted: isDark ? const Color(0xFF78716C) : const Color(0xFFA8A29E),
          success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          warning: isDark ? const Color(0xFFFDE047) : const Color(0xFFCA8A04),
          error: isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
          chipRadius: 999.0, // Full Pill
          buttonRadius: 999.0, // Full Pill
          cardRadius: 16.0,
          sheetRadius: 28.0,
          durationQuick: const Duration(milliseconds: 180),
          durationNormal: const Duration(milliseconds: 300),
          durationSlow: const Duration(milliseconds: 440),
          curveQuick: Curves.easeOutSine,
          curveNormal: Curves.easeInOutSine,
          curveSlow: Curves.easeInOutSine,
          displayFont: 'Inter',
          bodyFont: 'Inter',
        );

      case DesignDirection.kineticAthletic:
        return DesignTokens(
          direction: direction,
          isDark: isDark,
          canvas: isDark ? const Color(0xFF080A0D) : const Color(0xFFF1F5F9),
          panel: isDark ? const Color(0xFF11141A) : const Color(0xFFFFFFFF),
          elevated: isDark ? const Color(0xFF1A1F29) : const Color(0xFFE2E8F0),
          borderSubtle: isDark ? const Color(0xFF283040) : const Color(0xFFCBD5E1),
          accent: isDark ? const Color(0xFFF59E0B) : const Color(0xFF2563EB),
          onAccent: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          textPrimary: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF090D16),
          textSecondary: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          textMuted: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          success: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
          warning: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
          error: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
          chipRadius: 4.0, // Technical Chamfer
          buttonRadius: 6.0,
          cardRadius: 8.0,
          sheetRadius: 12.0,
          durationQuick: const Duration(milliseconds: 100),
          durationNormal: const Duration(milliseconds: 180),
          durationSlow: const Duration(milliseconds: 280),
          curveQuick: Curves.easeOutQuad,
          curveNormal: Curves.easeOutQuad,
          curveSlow: Curves.easeInOutQuad,
          displayFont: 'SpaceGrotesk',
          bodyFont: 'SpaceGrotesk',
        );

      case DesignDirection.softLayered:
        return DesignTokens(
          direction: direction,
          isDark: isDark,
          canvas: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8F6F2),
          panel: isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF),
          elevated: isDark ? const Color(0xFF21262D) : const Color(0xFFEFECE6),
          borderSubtle: isDark ? const Color(0xFF30363D) : const Color(0xFFE0DDD5),
          accent: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
          onAccent: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          textPrimary: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1F2937),
          textSecondary: isDark ? const Color(0xFF8B949E) : const Color(0xFF4B5563),
          textMuted: isDark ? const Color(0xFF6E7681) : const Color(0xFF9CA3AF),
          success: isDark ? const Color(0xFF3FB950) : const Color(0xFF16A34A),
          warning: isDark ? const Color(0xFFD29922) : const Color(0xFFB45309),
          error: isDark ? const Color(0xFFF85149) : const Color(0xFFDC2626),
          chipRadius: 12.0, // Generous Pebble
          buttonRadius: 16.0,
          cardRadius: 20.0,
          sheetRadius: 28.0,
          durationQuick: const Duration(milliseconds: 160),
          durationNormal: const Duration(milliseconds: 260),
          durationSlow: const Duration(milliseconds: 380),
          curveQuick: Curves.easeOutBack,
          curveNormal: Curves.easeOutBack,
          curveSlow: Curves.easeInOutCubic,
          displayFont: 'SpaceGrotesk',
          bodyFont: 'Inter',
        );
    }
  }

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: canvas,
      fontFamily: bodyFont,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accent,
        onPrimary: onAccent,
        secondary: elevated,
        onSecondary: textPrimary,
        error: error,
        onError: Colors.white,
        surface: panel,
        onSurface: textPrimary,
      ),
    );
  }
}

