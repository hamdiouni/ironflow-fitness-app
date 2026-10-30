import 'package:flutter/material.dart';

/// Standard layout, geometry, and motion tokens for the Slate Teal design system.
class AppSpacings {
  AppSpacings._();

  // ── Spacing Scale (4dp / 8dp base rhythm) ──────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // ── Radii Scale (3 Core Levels: Small 8, Medium 12, Large 14 + Pill) ───────
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;   // Chips, small tags, sub-pills
  static const double radiusMd = 12.0;  // Buttons, text inputs, action controls
  static const double radiusLg = 14.0;  // Section cards, sheets, dialog surfaces
  static const double radiusXl = 20.0;
  static const double radiusPill = 999.0;

  // ── Touch Target Standards (Accessibility) ─────────────────────────────────
  /// Absolute minimum touch target size according to WCAG AA / Material (48dp).
  static const double minTouchTarget = 48.0;

  // ── Motion Tokens ──────────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationMedium = Duration(milliseconds: 180);
  static const Duration durationSlow = Duration(milliseconds: 260);
  static const Duration durationShimmer = Duration(milliseconds: 1400);

  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveBounce = Curves.easeOutBack;
  static const Curve curveStandard = Curves.easeInOutCubic;
}
