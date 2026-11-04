import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Direction 4 Soft Layered card component.
///
/// Follows frame-light surface architecture: single surface level per section,
/// with borders reserved exclusively for selected, focused, or active states.
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
    this.isSelected = false,
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

  /// Custom border color override. If null, borders are omitted unless selected or glowing.
  final Color? borderColor;

  /// Border line width. Defaults to 1.0.
  final double borderWidth;

  /// Whether the card has an active kinetic glow border.
  final bool isGlowing;

  /// Whether the card is in a selected state (applies active border).
  final bool isSelected;

  /// Optional tap callback. If provided, renders an ink response.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? tokens.radiusLg;
    final bg = backgroundColor ?? tokens.card;

    // Frame-light rule: borders only for selected, glowing, or explicit override
    final hasBorder = isGlowing || isSelected || borderColor != null;
    final activeBorderColor = isGlowing || isSelected
        ? tokens.kineticAccent
        : borderColor;

    final boxDecoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder && activeBorderColor != null
          ? Border.all(
              color: activeBorderColor,
              width: (isGlowing || isSelected) ? 1.5 : borderWidth,
            )
          : null,
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
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
    );

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: boxDecoration,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
