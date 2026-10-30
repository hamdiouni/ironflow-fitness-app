import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Slate Teal frame-light card component.
///
/// Features clean, flat surface fills (one level per section) with zero nested borders.
/// Borders and ambient glows are reserved exclusively for selected, focused, or active states.
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
    this.hasBorder = false,
    this.isSelected = false,
    this.isGlowing = false,
    this.onTap,
  });

  /// Factory for an elevated surface card (Level 3 surface).
  factory AppCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacings.lg),
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      backgroundColor: null,
      hasBorder: false,
      child: child,
    );
  }

  /// Factory for a selected state card.
  factory AppCard.selected({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacings.lg),
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      isSelected: true,
      hasBorder: true,
      child: child,
    );
  }

  /// The widget content inside the card.
  final Widget child;

  /// Internal padding for the card. Defaults to 16dp.
  final EdgeInsetsGeometry padding;

  /// External margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Corner radius. Defaults to [tokens.cardRadius] (14dp).
  final double? borderRadius;

  /// Custom background color override. If null, uses [tokens.card].
  final Color? backgroundColor;

  /// Custom border color override. If null and [hasBorder] is true, uses [tokens.borderSubtle].
  final Color? borderColor;

  /// Border line width. Defaults to 1.0.
  final double borderWidth;

  /// Whether the card has a border outline. Defaults to false for frame-light styling.
  final bool hasBorder;

  /// Whether the card is currently selected. Renders active accent border.
  final bool isSelected;

  /// Whether the card has an active kinetic neon glow border.
  final bool isGlowing;

  /// Optional tap callback. If provided, renders an ink response.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? tokens.cardRadius;
    final bg = backgroundColor ?? tokens.card;

    Border? border;
    if (isGlowing || isSelected) {
      border = Border.all(color: tokens.kineticAccent, width: 1.5);
    } else if (borderColor != null) {
      border = Border.all(color: borderColor!, width: borderWidth);
    } else if (hasBorder) {
      border = Border.all(color: tokens.borderSubtle, width: borderWidth);
    }

    final boxDecoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: isGlowing
          ? [
              BoxShadow(
                color: tokens.kineticAccent.withValues(alpha: tokens.isDark ? 0.25 : 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ]
          : (!tokens.isDark && bg == Colors.white)
              ? const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
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
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
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
