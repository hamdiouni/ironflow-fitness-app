import 'package:flutter/material.dart';

/// Layout, geometry, and motion tokens for Option B: Iron Scoreboard.
class AppSpacings {
  AppSpacings._();

  // ── Spacing Scale ──────────────────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;

  // ── Iron Scoreboard Radii Scale (8px cards, 6px buttons) ───────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusPill = 9999.0;

  // ── Touch Target Standards (Accessibility) ─────────────────────────────────
  static const double minTouchTarget = 48.0;

  // ── Motion Tokens ──────────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 140);
  static const Duration durationMedium = Duration(milliseconds: 220);
  static const Duration durationSlow = Duration(milliseconds: 320);
  static const Duration durationShimmer = Duration(milliseconds: 1400);

  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveStandard = Curves.easeInOutCubic;
}
