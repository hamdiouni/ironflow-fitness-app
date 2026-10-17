import 'package:flutter/material.dart';

/// Monolithic Sci-Fi color system for IronFlow.
///
/// Features high-contrast dark titanium surfaces with a singular, high-intensity
/// Electric Hyper-Lime kinetic accent, complemented by architectural daylight mode.
class AppColors {
  AppColors._();

  // ── Brand & Kinetic Accents ────────────────────────────────────────────────
  /// Primary kinetic energy accent (Electric Hyper-Lime in dark, Deep Emerald in light)
  static const Color kineticAccentDark = Color(0xFF00FF87);
  static const Color kineticAccentLight = Color(0xFF0A7C42);

  /// Secondary telemetry accent (Cyan pulse)
  static const Color cyanAccentDark = Color(0xFF00D2FF);
  static const Color cyanAccentLight = Color(0xFF007599);

  /// Tertiary telemetry accent (Royal Electric Violet)
  static const Color violetAccentDark = Color(0xFF9D4EDD);
  static const Color violetAccentLight = Color(0xFF6B21A8);

  // ── Semantic Colors (WCAG AA Compliant) ────────────────────────────────────
  static const Color successDark = Color(0xFF00FF87);
  static const Color successLight = Color(0xFF0A7C42);

  static const Color warningDark = Color(0xFFFFB800);
  static const Color warningLight = Color(0xFFD97706);

  static const Color errorDark = Color(0xFFFF3B56);
  static const Color errorLight = Color(0xFFDC2626);

  static const Color infoDark = Color(0xFF00D2FF);
  static const Color infoLight = Color(0xFF0284C7);

  // ── Macro Nutrients ────────────────────────────────────────────────────────
  static const Color protein = Color(0xFFFF4B6E);
  static const Color carbs = Color(0xFF00D2FF);
  static const Color fats = Color(0xFFFFB800);

  // ── Dark Surfaces (Stealth Carbon & Titanium) ──────────────────────────────
  /// Deep obsidian base canvas - avoids OLED smear while remaining true-dark
  static const Color canvasDark = Color(0xFF0B0C0E);

  /// Level 1 structural panels / containers
  static const Color panelDark = Color(0xFF13151A);

  /// Level 2 elevated interactive cards
  static const Color cardDark = Color(0xFF1A1D24);

  /// Level 3 focused elements, inputs, modal dialogs
  static const Color elevatedDark = Color(0xFF222630);

  /// Structural 1px hairline borders
  static const Color borderSubtleDark = Color(0xFF262A35);

  /// Active glowing border
  static const Color borderGlowDark = Color(0x6600FF87);

  // ── Light Surfaces (Architectural Titanium) ────────────────────────────────
  /// Cool architectural canvas
  static const Color canvasLight = Color(0xFFF4F5F8);

  /// Level 1 clean white surface
  static const Color panelLight = Color(0xFFFFFFFF);

  /// Level 2 subtle card surface
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Level 3 elevated components and input fields
  static const Color elevatedLight = Color(0xFFECEEF2);

  /// Hairline borders for light mode
  static const Color borderSubtleLight = Color(0xFFD8DCE4);

  /// Active glowing border for light mode
  static const Color borderGlowLight = Color(0x6600A855);

  // ── Typography & Text Colors ───────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E95A5);
  static const Color textMutedDark = Color(0xFF525866);

  static const Color textPrimaryLight = Color(0xFF0E1015);
  static const Color textSecondaryLight = Color(0xFF555C6E);
  static const Color textMutedLight = Color(0xFF8C93A4);
}
