import 'package:flutter/material.dart';

/// Layout, geometry, and motion tokens adapted from the Stripe Design System (DESIGN.md).
class AppSpacings {
  AppSpacings._();

  // ── Stripe Spacing Scale (8dp base unit with 2/4/12 sub-tokens) ────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;

  // ── Stripe Radii Scale (rounded.xs to rounded.pill from DESIGN.md) ──────────
  /// 4px — Hairline tags, table chrome (rounded.xs)
  static const double radiusXs = 4.0;
  /// 6px — Form inputs (rounded.sm)
  static const double radiusSm = 6.0;
  /// 8px — Compact cards, alerts (rounded.md)
  static const double radiusMd = 8.0;
  /// 12px — Feature cards, pricing tiers (rounded.lg)
  static const double radiusLg = 12.0;
  /// 16px — Dashboard product mockup containers, bottom sheets (rounded.xl)
  static const double radiusXl = 16.0;
  /// 9999px — Decisive pill buttons, soft tags (rounded.pill)
  static const double radiusPill = 9999.0;

  // ── Touch Target Standards (Accessibility) ─────────────────────────────────
  /// Absolute minimum touch target size according to WCAG AA / Material (48dp).
  static const double minTouchTarget = 48.0;

  // ── Motion Tokens ──────────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 380);
  static const Duration durationShimmer = Duration(milliseconds: 1400);

  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveBounce = Curves.easeOutBack;
  static const Curve curveStandard = Curves.easeInOutCubic;
}
