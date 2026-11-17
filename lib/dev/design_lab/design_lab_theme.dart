import 'package:flutter/material.dart';

/// Identifies the 3 gym-first Design Directions evaluated in Wave 4.1.
enum LabDirection {
  slateTeal(
    id: '01-slate-teal',
    shortLabel: 'Slate Teal',
    title: '1. Slate Teal Minimal',
    tagline: 'Calm dark slate with high-visibility electric teal and zero noise.',
  ),
  kineticBlock(
    id: '02-kinetic-block',
    shortLabel: 'Kinetic Block',
    title: '2. Iron Scoreboard',
    tagline: 'Matte charcoal, crisp 8 px blocks, signal amber & oversized set numbers.',
  ),
  softLayered(
    id: '03-soft-layered',
    shortLabel: 'Warm Studio',
    title: '3. Warm Studio Coach',
    tagline: 'Cleaned Soft & Layered evolution with accessible indigo, mint & warm linen.',
  );

  const LabDirection({
    required this.id,
    required this.shortLabel,
    required this.title,
    required this.tagline,
  });

  final String id;
  final String shortLabel;
  final String title;
  final String tagline;
}

/// Complete design token set for a single Design Lab direction + brightness mode.
/// All pairs are chosen for WCAG AA+ readability (>= 4.5:1 text, >= 3:1 large/UI).
@immutable
class LabTokens {
  const LabTokens({
    required this.direction,
    required this.isDark,
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.secondaryAccent,
    required this.onSecondaryAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.cardRadius,
    required this.buttonRadius,
    required this.pagePadding,
    required this.sectionGap,
    required this.buttonHeight,
    required this.useCardBorders,
    required this.useSoftShadow,
    required this.numericFontFamily,
    required this.bodyFontFamily,
  });

  final LabDirection direction;
  final bool isDark;
  final Color canvas;
  final Color surface;
  final Color raised;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color secondaryAccent;
  final Color onSecondaryAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color protein;
  final Color carbs;
  final Color fats;
  final double cardRadius;
  final double buttonRadius;
  final double pagePadding;
  final double sectionGap;
  final double buttonHeight;
  final bool useCardBorders;
  final bool useSoftShadow;
  final String numericFontFamily;
  final String bodyFontFamily;

  List<BoxShadow>? get cardShadow => useSoftShadow
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
      : null;

  TextStyle headingStyle(double size, {Color? color}) => TextStyle(
        fontFamily: numericFontFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color ?? textPrimary,
      );

  TextStyle numberStyle(double size, {Color? color}) => TextStyle(
        fontFamily: numericFontFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color ?? textPrimary,
      );

  TextStyle bodyStyle(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color ?? textPrimary,
      );

  TextStyle labelStyle(double size, {Color? color}) => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: color ?? textSecondary,
      );

  static LabTokens forConfig(LabDirection direction, {required bool isDark}) {
    return switch ((direction, isDark)) {
      (LabDirection.slateTeal, true) => _slateTealDark,
      (LabDirection.slateTeal, false) => _slateTealLight,
      (LabDirection.kineticBlock, true) => _kineticBlockDark,
      (LabDirection.kineticBlock, false) => _kineticBlockLight,
      (LabDirection.softLayered, true) => _softLayeredDark,
      (LabDirection.softLayered, false) => _softLayeredLight,
    };
  }

  static ThemeData buildMaterialTheme(LabTokens t) {
    return ThemeData(
      useMaterial3: true,
      brightness: t.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: t.canvas,
      fontFamily: t.bodyFontFamily,
      colorScheme: ColorScheme(
        brightness: t.isDark ? Brightness.dark : Brightness.light,
        primary: t.accent,
        onPrimary: t.onAccent,
        secondary: t.secondaryAccent,
        onSecondary: t.onSecondaryAccent,
        error: t.error,
        onError: t.isDark ? const Color(0xFF0A0B0E) : Colors.white,
        surface: t.surface,
        onSurface: t.textPrimary,
      ),
      dividerColor: t.border,
      appBarTheme: AppBarTheme(
        backgroundColor: t.canvas,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  // ── Direction 1: Slate Teal Minimal ────────────────────────────────────────
  static const _slateTealDark = LabTokens(
    direction: LabDirection.slateTeal,
    isDark: true,
    canvas: Color(0xFF0B1218),
    surface: Color(0xFF131D26),
    raised: Color(0xFF1C2A36),
    border: Color(0xFF283948),
    accent: Color(0xFF2DD4BF),
    onAccent: Color(0xFF042F2E),
    secondaryAccent: Color(0xFF60A5FA),
    onSecondaryAccent: Color(0xFF08203E),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFA7B7C9),
    textMuted: Color(0xFF8395A7),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    protein: Color(0xFFFB7185),
    carbs: Color(0xFF38BDF8),
    fats: Color(0xFFFBBF24),
    cardRadius: 14,
    buttonRadius: 12,
    pagePadding: 16,
    sectionGap: 14,
    buttonHeight: 48,
    useCardBorders: false,
    useSoftShadow: false,
    numericFontFamily: 'SpaceGrotesk',
    bodyFontFamily: 'Inter',
  );

  static const _slateTealLight = LabTokens(
    direction: LabDirection.slateTeal,
    isDark: false,
    canvas: Color(0xFFF4F7F9),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFE9EFF4),
    border: Color(0xFFD0DCE5),
    accent: Color(0xFF0F766E),
    onAccent: Color(0xFFFFFFFF),
    secondaryAccent: Color(0xFF1D4ED8),
    onSecondaryAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF526377),
    success: Color(0xFF15803D),
    warning: Color(0xFFB45309),
    error: Color(0xFFB91C1C),
    protein: Color(0xFFBE185D),
    carbs: Color(0xFF0369A1),
    fats: Color(0xFFB45309),
    cardRadius: 14,
    buttonRadius: 12,
    pagePadding: 16,
    sectionGap: 14,
    buttonHeight: 48,
    useCardBorders: true,
    useSoftShadow: false,
    numericFontFamily: 'SpaceGrotesk',
    bodyFontFamily: 'Inter',
  );

  // ── Direction 2: Kinetic Block (Iron Scoreboard & Amber) ───────────────────
  static const _kineticBlockDark = LabTokens(
    direction: LabDirection.kineticBlock,
    isDark: true,
    canvas: Color(0xFF0A0B0E),
    surface: Color(0xFF14171D),
    raised: Color(0xFF1E232C),
    border: Color(0xFF2D3340),
    accent: Color(0xFFF59E0B),
    onAccent: Color(0xFF111216),
    secondaryAccent: Color(0xFF60A5FA),
    onSecondaryAccent: Color(0xFF09192F),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFB3BCC9),
    textMuted: Color(0xFF8A94A3),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    protein: Color(0xFFF472B6),
    carbs: Color(0xFF60A5FA),
    fats: Color(0xFFFBBF24),
    cardRadius: 8,
    buttonRadius: 6,
    pagePadding: 12,
    sectionGap: 10,
    buttonHeight: 50,
    useCardBorders: true,
    useSoftShadow: false,
    numericFontFamily: 'SpaceGrotesk',
    bodyFontFamily: 'Inter',
  );

  static const _kineticBlockLight = LabTokens(
    direction: LabDirection.kineticBlock,
    isDark: false,
    canvas: Color(0xFFF3F4F6),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFE5E7EB),
    border: Color(0xFFC5CBD3),
    accent: Color(0xFFC2410C),
    onAccent: Color(0xFFFFFFFF),
    secondaryAccent: Color(0xFF1D4ED8),
    onSecondaryAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF374151),
    textMuted: Color(0xFF4B5563),
    success: Color(0xFF15803D),
    warning: Color(0xFFB45309),
    error: Color(0xFFB91C1C),
    protein: Color(0xFFBE185D),
    carbs: Color(0xFF1D4ED8),
    fats: Color(0xFFB45309),
    cardRadius: 8,
    buttonRadius: 6,
    pagePadding: 12,
    sectionGap: 10,
    buttonHeight: 50,
    useCardBorders: true,
    useSoftShadow: false,
    numericFontFamily: 'SpaceGrotesk',
    bodyFontFamily: 'Inter',
  );

  // ── Direction 3: Warm Studio Coach (Cleaned Soft & Layered) ────────────────
  static const _softLayeredDark = LabTokens(
    direction: LabDirection.softLayered,
    isDark: true,
    canvas: Color(0xFF12131A),
    surface: Color(0xFF1C1E28),
    raised: Color(0xFF262936),
    border: Color(0xFF323647),
    accent: Color(0xFF818CF8),
    onAccent: Color(0xFF0D1126),
    secondaryAccent: Color(0xFF34D399),
    onSecondaryAccent: Color(0xFF042F1E),
    textPrimary: Color(0xFFF4F6FB),
    textSecondary: Color(0xFFAAB2C5),
    textMuted: Color(0xFF848DA3),
    success: Color(0xFF34D399),
    warning: Color(0xFFFB923C),
    error: Color(0xFFFB7185),
    protein: Color(0xFFFB7185),
    carbs: Color(0xFF34D399),
    fats: Color(0xFFFBBF24),
    cardRadius: 20,
    buttonRadius: 999,
    pagePadding: 18,
    sectionGap: 16,
    buttonHeight: 50,
    useCardBorders: false,
    useSoftShadow: true,
    numericFontFamily: 'SpaceGrotesk',
    bodyFontFamily: 'Inter',
  );

  static const _softLayeredLight = LabTokens(
    direction: LabDirection.softLayered,
    isDark: false,
    canvas: Color(0xFFF8F6F2),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEFECE6),
    border: Color(0xFFDBD6CD),
    accent: Color(0xFF4F46E5),
    onAccent: Color(0xFFFFFFFF),
    secondaryAccent: Color(0xFF047857),
    onSecondaryAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF181C24),
    textSecondary: Color(0xFF3F4654),
    textMuted: Color(0xFF565E6E),
    success: Color(0xFF047857),
    warning: Color(0xFFC2410C),
    error: Color(0xFFBE123C),
    protein: Color(0xFFBE123C),
    carbs: Color(0xFF047857),
    fats: Color(0xFFB45309),
    cardRadius: 20,
    buttonRadius: 999,
    pagePadding: 18,
    sectionGap: 16,
    buttonHeight: 50,
    useCardBorders: true,
    useSoftShadow: true,
    numericFontFamily: 'SpaceGrotesk',
    bodyFontFamily: 'Inter',
  );
}
