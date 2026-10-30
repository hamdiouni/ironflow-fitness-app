import 'package:flutter/material.dart';

/// Slate Teal Refined color system for IronFlow (Direction 1).
///
/// Features calm, high-contrast dark slate surfaces with a focused teal kinetic accent
/// and WCAG AA verified daylight mode.
class AppColors {
  AppColors._();

  // ── Brand & Kinetic Accents ────────────────────────────────────────────────
  /// Primary kinetic energy accent (Teal in dark, Deep Teal in light)
  static const Color kineticAccentDark = Color(0xFF2DD4BF);
  static const Color kineticAccentLight = Color(0xFF0F766E);

  /// On-accent text/icon color for high contrast (Dark Ink on Teal in dark, Pure White on Deep Teal in light)
  static const Color onAccentDark = Color(0xFF042F2E);
  static const Color onAccentLight = Color(0xFFFFFFFF);

  /// Secondary telemetry accent (Sky Blue pulse)
  static const Color cyanAccentDark = Color(0xFF38BDF8);
  static const Color cyanAccentLight = Color(0xFF0284C7);

  /// Tertiary telemetry accent (Soft Violet)
  static const Color violetAccentDark = Color(0xFFA78BFA);
  static const Color violetAccentLight = Color(0xFF7C3AED);

  // ── Semantic Colors (WCAG AA Compliant) ────────────────────────────────────
  static const Color successDark = Color(0xFF4ADE80);
  static const Color successLight = Color(0xFF15803D);

  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFB45309);

  static const Color errorDark = Color(0xFFF87171);
  static const Color errorLight = Color(0xFFB91C1C);

  static const Color infoDark = Color(0xFF60A5FA);
  static const Color infoLight = Color(0xFF1D4ED8);

  // ── Macro Nutrients ────────────────────────────────────────────────────────
  static const Color protein = Color(0xFFFB7185);
  static const Color carbs = Color(0xFF38BDF8);
  static const Color fats = Color(0xFFFBBF24);

  // ── Dark Surfaces (Calm Slate) ─────────────────────────────────────────────
  /// Deep slate base canvas - prevents OLED smear while remaining true dark
  static const Color canvasDark = Color(0xFF0B1218);

  /// Level 1 structural panels / containers
  static const Color panelDark = Color(0xFF131D26);

  /// Level 2 section surface
  static const Color cardDark = Color(0xFF131D26);

  /// Level 3 elevated interactive elements, chips, inputs, modal dialogs
  static const Color elevatedDark = Color(0xFF1C2A36);

  /// Structural 1px hairline borders
  static const Color borderSubtleDark = Color(0xFF243443);

  /// Active glowing border
  static const Color borderGlowDark = Color(0x4D2DD4BF);

  // ── Light Surfaces (Architectural Slate Daylight) ──────────────────────────
  /// Cool architectural canvas
  static const Color canvasLight = Color(0xFFF4F7F9);

  /// Level 1 clean white surface
  static const Color panelLight = Color(0xFFFFFFFF);

  /// Level 2 card surface
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Level 3 elevated components and input fields
  static const Color elevatedLight = Color(0xFFE9EFF3);

  /// Hairline borders for light mode
  static const Color borderSubtleLight = Color(0xFFD5DEE5);

  /// Active glowing border for light mode
  static const Color borderGlowLight = Color(0x330F766E);

  // ── Typography & Text Colors (WCAG AA Verified) ────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF9DAEC2);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF64748B);
}
