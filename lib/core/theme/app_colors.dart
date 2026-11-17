import 'package:flutter/material.dart';

/// Color tokens for Option B: Iron Scoreboard (`02-kinetic-block`).
///
/// Built for gym-floor legibility across both Dark (matte rack charcoal with
/// Signal Amber and Cobalt Steel) and Light (crisp neutral canvas with Burnt
/// Amber and Cobalt). All primary, text, and alert pairs pass WCAG AA (>= 4.5:1).
class AppColors {
  AppColors._();

  // ── Dark Surfaces ──────────────────────────────────────────────────────────
  static const Color canvasDark = Color(0xFF0A0B0E);
  static const Color panelDark = Color(0xFF14171D);
  static const Color cardDark = Color(0xFF14171D);
  static const Color elevatedDark = Color(0xFF1E232C);
  static const Color borderSubtleDark = Color(0xFF2D3340);
  static const Color borderGlowDark = Color(0x66F59E0B);

  // ── Light Surfaces ─────────────────────────────────────────────────────────
  static const Color canvasLight = Color(0xFFF3F4F6);
  static const Color panelLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color elevatedLight = Color(0xFFE5E7EB);
  static const Color borderSubtleLight = Color(0xFFC5CBD3);
  static const Color borderGlowLight = Color(0x4DC2410C);

  // ── Accents (Iron Scoreboard) ──────────────────────────────────────────────
  static const Color kineticAccentDark = Color(0xFFF59E0B);
  static const Color kineticAccentLight = Color(0xFFC2410C);

  static const Color onAccentDark = Color(0xFF111216);
  static const Color onAccentLight = Color(0xFFFFFFFF);

  /// Secondary coaching & timer accent (Cobalt Steel).
  static const Color cyanAccentDark = Color(0xFF60A5FA);
  static const Color cyanAccentLight = Color(0xFF1D4ED8);

  /// Tertiary highlight accent.
  static const Color violetAccentDark = Color(0xFFFB923C);
  static const Color violetAccentLight = Color(0xFF92400E);

  // ── Typography ─────────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFB3BCC9);
  static const Color textMutedDark = Color(0xFF8A94A3);

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF374151);
  static const Color textMutedLight = Color(0xFF4B5563);

  // ── Semantic Alerts ────────────────────────────────────────────────────────
  static const Color successDark = Color(0xFF4ADE80);
  static const Color successLight = Color(0xFF15803D);

  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFB45309);

  static const Color errorDark = Color(0xFFF87171);
  static const Color errorLight = Color(0xFFB91C1C);

  static const Color infoDark = Color(0xFF60A5FA);
  static const Color infoLight = Color(0xFF1D4ED8);

  // ── Macro Nutrients (Dark + Light AA-verified) ─────────────────────────────
  static const Color protein = Color(0xFFF472B6);
  static const Color carbs = Color(0xFF60A5FA);
  static const Color fats = Color(0xFFFBBF24);

  static const Color proteinLight = Color(0xFFBE185D);
  static const Color carbsLight = Color(0xFF1D4ED8);
  static const Color fatsLight = Color(0xFFB45309);
}
