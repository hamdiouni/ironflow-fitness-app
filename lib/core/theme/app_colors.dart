import 'package:flutter/material.dart';

/// Stripe Design System color tokens for IronFlow.
///
/// Adapted from DESIGN.md:
/// - Primary: Electric Indigo (#533AFD), Deep Indigo (#4434D4), Press (#2E2B8C), Soft (#665EFD)
/// - Dashboard dark shell: Brand Dark 900 (#1C1E54)
/// - Light canvas: Crisp White (#FFFFFF) & Soft Tinted Canvas (#F6F9FC)
/// - Typography: Signature Deep Navy Ink (#0D253D - never pure black)
/// - Hairline dividers: Cards & tables (#E3E8EE), Inputs (#A8C3DE)
/// - Accents: Ruby (#EA2261), Magenta (#F96BEE), Lemon/Amber (#9B6829 / #F59E0B)
/// - Ambient Shadow: Blue-tinted (#003770)
class AppColors {
  AppColors._();

  // ── Stripe Canonical Palette Tokens (from DESIGN.md) ────────────────────────
  /// Signature Electric Indigo CTA & link emphasis
  static const Color primary = Color(0xFF533AFD);
  /// Mid-stop indigo & press-state warmer alternative
  static const Color primaryDeep = Color(0xFF4434D4);
  /// Pressed state lift of the primary CTA
  static const Color primaryPress = Color(0xFF2E2B8C);
  /// Lighter indigo used in product-UI accents & telemetry highlights
  static const Color primarySoft = Color(0xFF665EFD);
  /// Pale indigo fill used as soft tag / chip background
  static const Color primaryBgSubduedHover = Color(0xFFB9B9F9);
  /// The deep navy used on the dashboard chrome & featured tier
  static const Color brandDark900 = Color(0xFF1C1E54);

  /// Default body text color across the brand — deep navy, NEVER pure black
  static const Color ink = Color(0xFF0D253D);
  /// Secondary text on light surfaces
  static const Color inkSecondary = Color(0xFF273951);
  /// Helper text, captions, and table labels
  static const Color inkMute = Color(0xFF64748D);
  /// Near-equivalent to ink-mute used in navigation
  static const Color inkMute2 = Color(0xFF61718A);
  /// Text on indigo and dark-navy surfaces
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Default page background
  static const Color canvas = Color(0xFFFFFFFF);
  /// Cool-tinted off-white used on feature bands and base canvas
  static const Color canvasSoft = Color(0xFFF6F9FC);
  /// Warm cream feature-band fill — the brand's chromatic interlude
  static const Color canvasCream = Color(0xFFF5E9D4);

  /// 1px borders on cards and tables
  static const Color hairline = Color(0xFFE3E8EE);
  /// Slightly cooler hairline used on form inputs
  static const Color hairlineInput = Color(0xFFA8C3DE);

  /// Gradient accents and chart highlights
  static const Color ruby = Color(0xFFEA2261);
  static const Color magenta = Color(0xFFF96BEE);
  static const Color lemon = Color(0xFF9B6829);
  static const Color shadowBlue = Color(0xFF003770);

  // ── Semantic Colors (WCAG AA Compliant) ────────────────────────────────────
  static const Color successDark = Color(0xFF6EE7B7);
  static const Color successLight = Color(0xFF00D924);

  static const Color warningDark = Color(0xFFFCD34D);
  static const Color warningLight = Color(0xFF92400E);

  static const Color errorDark = Color(0xFFFDA4AF);
  static const Color errorLight = Color(0xFFEA2261);

  static const Color infoDark = Color(0xFFA5B4FC);
  static const Color infoLight = Color(0xFF533AFD);

  // ── Macro Nutrients ────────────────────────────────────────────────────────
  static const Color protein = Color(0xFFEA2261); // Stripe Ruby
  static const Color carbs = Color(0xFF6EE7B7);   // Stripe Mint / Teal
  static const Color fats = Color(0xFFFCD34D);    // Stripe Warm Lemon / Gold

  // ── Dark Surfaces (Stripe Dashboard Track: Brand Dark 900) ──────────────────
  /// Dashboard base canvas
  static const Color canvasDark = Color(0xFF141638);
  /// Brand dark 900 panel surface
  static const Color panelDark = Color(0xFF1C1E54);
  /// Elevated interactive card surface
  static const Color cardDark = Color(0xFF1C1E54);
  /// Focused elements, pill surfaces, chips
  static const Color elevatedDark = Color(0xFF252968);
  /// Hairline dividers for dark surfaces
  static const Color borderSubtleDark = Color(0xFF2E336B);
  /// Ambient active glow
  static const Color borderGlowDark = Color(0x33A5B4FC);

  // ── Light Surfaces (Stripe Canvas & Canvas-Soft) ─────────────────────────────
  /// Cool-tinted soft canvas
  static const Color canvasLight = Color(0xFFF6F9FC);
  /// Clean white panel
  static const Color panelLight = Color(0xFFFFFFFF);
  /// Crisp white card
  static const Color cardLight = Color(0xFFFFFFFF);
  /// Elevated light surface (soft lavender/blue tint)
  static const Color elevatedLight = Color(0xFFF0F4F9);
  /// Hairline card border
  static const Color borderSubtleLight = Color(0xFFE3E8EE);
  /// Active glowing border for light mode
  static const Color borderGlowLight = Color(0x26533AFD);

  // ── Kinetic Accents (Aliased to Stripe Primary) ─────────────────────────────
  /// Primary kinetic accent (Soft Lavender/Indigo in dark, Electric Indigo in light)
  static const Color kineticAccentDark = Color(0xFFA5B4FC);
  static const Color kineticAccentLight = Color(0xFF533AFD);

  /// On-Accent text color
  static const Color onAccentDark = Color(0xFF0D253D);
  static const Color onAccentLight = Color(0xFFFFFFFF);

  /// Secondary coaching accent
  static const Color cyanAccentDark = Color(0xFF6EE7B7);
  static const Color cyanAccentLight = Color(0xFF059669);

  /// Tertiary soft lavender accent
  static const Color violetAccentDark = Color(0xFFC4B5FD);
  static const Color violetAccentLight = Color(0xFF665EFD);

  // ── Typography & Text Colors ───────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFADB8D0);
  static const Color textMutedDark = Color(0xFF717D96);

  static const Color textPrimaryLight = Color(0xFF0D253D); // Stripe Ink
  static const Color textSecondaryLight = Color(0xFF273951); // Stripe Ink Secondary
  static const Color textMutedLight = Color(0xFF64748D); // Stripe Ink Mute
}
