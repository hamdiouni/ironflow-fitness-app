import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi linear progress bar with optional kinetic gradient.
class AppProgressBar extends StatelessWidget {
  /// Creates an [AppProgressBar].
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.showGlow = false,
  });

  /// Progress fraction from 0.0 to 1.0.
  final double progress;

  /// Bar thickness. Defaults to 8.0.
  final double height;

  /// Inactive track background color. Defaults to [tokens.elevated].
  final Color? backgroundColor;

  /// Active track progress color. Defaults to [tokens.kineticAccent].
  final Color? progressColor;

  /// Corner radius. Defaults to [AppSpacings.radiusPill].
  final double? borderRadius;

  /// Whether to render a neon glow around the active segment.
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final clamped = progress.clamp(0.0, 1.0);
    final activeColor = progressColor ?? tokens.kineticAccent;
    final trackColor = backgroundColor ?? tokens.elevated;
    final radius = BorderRadius.circular(borderRadius ?? AppSpacings.radiusPill);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: radius,
        border: Border.all(color: tokens.borderSubtle, width: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillWidth = constraints.maxWidth * clamped;
          return Stack(
            children: [
              AnimatedContainer(
                duration: AppSpacings.durationMedium,
                curve: AppSpacings.curveStandard,
                width: fillWidth,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: radius,
                  boxShadow: (showGlow && tokens.isDark)
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Monolithic Sci-Fi circular progress ring with centered telemetry label.
class AppProgressRing extends StatelessWidget {
  /// Creates an [AppProgressRing].
  const AppProgressRing({
    super.key,
    required this.progress,
    this.size = 64.0,
    this.strokeWidth = 6.0,
    this.progressColor,
    this.backgroundColor,
    this.centerWidget,
  });

  /// Progress fraction from 0.0 to 1.0.
  final double progress;

  /// Diameter of the ring. Defaults to 64.0.
  final double size;

  /// Stroke width of the ring. Defaults to 6.0.
  final double strokeWidth;

  /// Active track color. Defaults to [tokens.kineticAccent].
  final Color? progressColor;

  /// Background track color. Defaults to [tokens.elevated].
  final Color? backgroundColor;

  /// Widget placed in the center of the ring.
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final clamped = progress.clamp(0.0, 1.0);
    final active = progressColor ?? tokens.kineticAccent;
    final track = backgroundColor ?? tokens.elevated;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: clamped,
              strokeWidth: strokeWidth,
              activeColor: active,
              trackColor: track,
              borderColor: tokens.borderSubtle,
            ),
          ),
          ?centerWidget,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
    required this.borderColor,
  });

  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
