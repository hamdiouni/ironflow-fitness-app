import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi card component.
///
/// Features precision 1px structural borders, matte surface elevations,
/// and an optional kinetic glow border for active telemetry elements.
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

  /// Corner radius. Defaults to [AppSpacings.radiusMd] (14dp).
  final double? borderRadius;

  /// Custom background color override. If null, uses [tokens.card].
  final Color? backgroundColor;

  /// Custom border color override. If null, uses [tokens.borderSubtle].
  final Color? borderColor;

  /// Border line width. Defaults to 1.0.
  final double borderWidth;

  /// Whether the card has an active kinetic neon glow border.
  final bool isGlowing;

  /// Optional tap callback. If provided, renders an ink response.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? tokens.radiusMd;
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
                color: tokens.kineticAccent.withValues(alpha: tokens.isDark ? 0.25 : 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ]
          : tokens.isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
    );

    Widget content = Container(
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

    return content;
  }
}
