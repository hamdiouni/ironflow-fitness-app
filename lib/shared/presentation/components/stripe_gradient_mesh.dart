import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Clean Iron Scoreboard header container built strictly from theme tokens.
class StripeMeshBackdrop extends StatelessWidget {
  const StripeMeshBackdrop({
    super.key,
    this.height = 180.0,
    this.borderRadius,
    this.child,
    this.opacity = 1.0,
  });

  final double height;
  final BorderRadius? borderRadius;
  final Widget? child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget surface = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: borderRadius,
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: child,
    );

    if (opacity < 1.0) {
      surface = Opacity(opacity: opacity, child: surface);
    }
    return surface;
  }
}
