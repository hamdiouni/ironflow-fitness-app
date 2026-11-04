import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Stripe Design System card component with crisp hairline and ambient blue shadow.
///
/// Features soft ambient shadows, gentle 20dp pebble corners, hairline boundaries,
/// and responsive touch interaction.
class AppCard extends StatelessWidget {
  /// Creates an [AppCard].
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacings.lg),
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isGlowing = false,
    this.onTap,
  });

  /// The widget content inside the card.
  final Widget child;

  /// Internal padding for the card. Defaults to 16dp.
  final EdgeInsetsGeometry padding;

  /// External margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Corner radius. Defaults to [AppSpacings.radiusLg] (20dp).
  final double? borderRadius;

  /// Custom background color override. If null, uses [tokens.card].
  final Color? backgroundColor;

  /// Custom border color override. If null, uses [tokens.borderSubtle].
  final Color? borderColor;

  /// Border line width. Defaults to 1.0.
  final double borderWidth;

  /// Whether the card has an active kinetic glow border.
  final bool isGlowing;

  /// Optional tap callback. If provided, renders an ink response.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? tokens.radiusLg;
    final bg = backgroundColor ?? tokens.card;
    final border = isGlowing
        ? tokens.kineticAccent
        : (borderColor ?? tokens.borderSubtle);

    final boxDecoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border,
        width: isGlowing ? 1.5 : borderWidth,
      ),
      boxShadow: isGlowing
          ? [
              BoxShadow(
                color: tokens.kineticAccent.withValues(alpha: tokens.isDark ? 0.28 : 0.2),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : tokens.isDark
              ? const [
                  BoxShadow(
                    color: Color(0x2E000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x14003770),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color(0x0A003770),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        decoration: boxDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: boxDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
