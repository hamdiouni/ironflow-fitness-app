import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi skeleton shimmer loader.
///
/// Respects accessibility reduced-motion preferences. When animations are disabled,
/// displays a static low-contrast placeholder.
class AppShimmer extends StatefulWidget {
  /// Creates an [AppShimmer].
  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  /// Skeleton width.
  final double width;

  /// Skeleton height.
  final double height;

  /// Corner radius. Defaults to [AppSpacings.radiusSm].
  final double? borderRadius;

  /// Whether the shape is a circle (e.g. for avatar placeholders).
  final bool isCircle;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppSpacings.durationShimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final baseColor = tokens.elevated;
    final highlightColor = tokens.isDark
        ? const Color(0xFF2C3240)
        : const Color(0xFFDFE2E8);

    final shape = widget.isCircle ? BoxShape.circle : BoxShape.rectangle;
    final radius = widget.isCircle
        ? null
        : BorderRadius.circular(widget.borderRadius ?? AppSpacings.radiusSm);

    if (reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          shape: shape,
          borderRadius: radius,
          border: Border.all(color: tokens.borderSubtle, width: 0.5),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: radius,
            border: Border.all(color: tokens.borderSubtle, width: 0.5),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3.0 * _controller.value, 0.0),
              end: Alignment(-0.5 + 3.0 * _controller.value, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}
