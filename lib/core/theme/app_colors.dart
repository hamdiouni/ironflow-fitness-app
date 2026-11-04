import 'package:flutter/material.dart';

/// Direction 4: Soft & Layered design token color system for IronFlow.
///
/// Features warm midnight indigo surfaces paired with tactile periwinkle and mint accents,
/// warm linen daylight mode, and WCAG AA/AAA contrast ratios.
class AppColors {
  AppColors._();

  // ── Brand & Kinetic Accents ────────────────────────────────────────────────
  /// Primary kinetic energy accent (Soft Periwinkle in dark, Deep Indigo in light)
  static const Color kineticAccentDark = Color(0xFFA5B4FC);
  static const Color kineticAccentLight = Color(0xFF4338CA);

  /// On-Accent text color (Deep Indigo on periwinkle in dark, Pure White in light)
  static const Color onAccentDark = Color(0xFF1E1B4B);
  static const Color onAccentLight = Color(0xFFFFFFFF);

  /// Secondary coaching accent (Soft Mint in dark, Deep Emerald in light)
  static const Color cyanAccentDark = Color(0xFF6EE7B7);
  static const Color cyanAccentLight = Color(0xFF047857);

  /// Tertiary soft lavender accent
  static const Color violetAccentDark = Color(0xFFC4B5FD);
  static const Color violetAccentLight = Color(0xFF6366F1);

  // ── Semantic Colors (WCAG AA Compliant) ────────────────────────────────────
  static const Color successDark = Color(0xFF6EE7B7);
  static const Color successLight = Color(0xFF047857);

  static const Color warningDark = Color(0xFFFCD34D);
  static const Color warningLight = Color(0xFF92400E);

  static const Color errorDark = Color(0xFFFDA4AF);
  static const Color errorLight = Color(0xFFBE123C);

  static const Color infoDark = Color(0xFF93C5FD);
  static const Color infoLight = Color(0xFF1D4ED8);

  // ── Macro Nutrients ────────────────────────────────────────────────────────
  static const Color protein = Color(0xFFFDA4AF);
  static const Color carbs = Color(0xFF6EE7B7);
  static const Color fats = Color(0xFFFCD34D);

  // ── Dark Surfaces (Midnight Indigo Soft Sheets) ───────────────────────────
  /// Midnight Indigo base canvas
  static const Color canvasDark = Color(0xFF12131A);

  /// Level 1 structural panels / soft sheets
  static const Color panelDark = Color(0xFF1C1E28);

  /// Level 2 elevated interactive cards / sheets
  static const Color cardDark = Color(0xFF1C1E28);

  /// Level 3 focused elements, pill surfaces, chips
  static const Color elevatedDark = Color(0xFF272A38);

  /// Structural hairline dividers / soft sheet borders
  static const Color borderSubtleDark = Color(0xFF30344A);

  /// Ambient active periwinkle glow
  static const Color borderGlowDark = Color(0x33A5B4FC);

  // ── Light Surfaces (Warm Linen & Layered White) ────────────────────────────
  /// Warm linen base canvas
  static const Color canvasLight = Color(0xFFF3F1EC);

  /// Level 1 clean white surface
  static const Color panelLight = Color(0xFFFFFFFF);

  /// Level 2 subtle card surface
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Level 3 elevated components, soft lavender chips
  static const Color elevatedLight = Color(0xFFEDEAF6);

  /// Hairline borders for light mode
  static const Color borderSubtleLight = Color(0xFFE0DCEB);

  /// Active glowing border for light mode
  static const Color borderGlowLight = Color(0x264338CA);

  // ── Typography & Text Colors ───────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF4F4F8);
  static const Color textSecondaryDark = Color(0xFFADB1C6);
  static const Color textMutedDark = Color(0xFF686C80);

  static const Color textPrimaryLight = Color(0xFF1F2030);
  static const Color textSecondaryLight = Color(0xFF555C6E);
  static const Color textMutedLight = Color(0xFF8B8E9E);
}
