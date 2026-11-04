import 'package:flutter/material.dart';

/// Standard motion and animation primitives for Direction 4 (Soft & Layered).
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 380);

  // Curves
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.easeOutBack;

  /// Returns true if reduced motion is preferred by the platform/user.
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  /// Returns a duration that collapses to [Duration.zero] if reduced motion is enabled.
  static Duration responsiveDuration(BuildContext context, Duration standardDuration) {
    if (isReducedMotion(context)) return Duration.zero;
    return standardDuration;
  }

  /// Page transition builder helper for soft layered elevation.
  static Widget softPageTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    if (isReducedMotion(context)) {
      return child;
    }
    final curved = CurvedAnimation(parent: animation, curve: curveEnter);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

