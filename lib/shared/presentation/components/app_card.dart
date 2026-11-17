import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Iron Scoreboard card container.
///
/// Uses crisp 1px structural borders (`tokens.borderSubtle`) and `8 px` radii,
/// switching to highlighted accent borders when [isGlowing] or [isSelected].
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

  /// Corner radius. Defaults to [tokens.radiusLg] (8dp).
  final double? borderRadius;

  /// Custom background color override. If null, uses [tokens.card].
  final Color? backgroundColor;

  /// Custom border color override. If null, uses [tokens.borderSubtle].
  final Color? borderColor;

  /// Border line width. Defaults to 1.0.
  final double borderWidth;

  /// Whether the card has an active highlight border.
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

    final activeBorderColor = (isGlowing || isSelected)
        ? tokens.kineticAccent
        : (borderColor ?? tokens.borderSubtle);

    final boxDecoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: activeBorderColor,
        width: (isGlowing || isSelected) ? 1.5 : borderWidth,
      ),
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
