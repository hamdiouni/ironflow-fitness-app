import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';

/// Shared adaptive surface & button primitives parameterized strictly by [LabTokens].
class LabCard extends StatelessWidget {
  const LabCard({
    super.key,
    required this.tokens,
    required this.child,
    this.padding,
    this.highlighted = false,
    this.backgroundOverride,
  });

  final LabTokens tokens;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool highlighted;
  final Color? backgroundOverride;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted
        ? tokens.accent.withValues(alpha: tokens.isDark ? 0.6 : 0.45)
        : tokens.border;
    return Container(
      padding: padding ?? EdgeInsets.all(tokens.pagePadding),
      decoration: BoxDecoration(
        color: backgroundOverride ?? tokens.surface,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: (tokens.useCardBorders || highlighted)
            ? Border.all(
                color: borderColor,
                width: highlighted ? 1.5 : 1,
              )
            : null,
        boxShadow: tokens.cardShadow,
      ),
      child: child,
    );
  }
}

class LabPrimaryButton extends StatelessWidget {
  const LabPrimaryButton({
    super.key,
    required this.tokens,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
  });

  final LabTokens tokens;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isKinetic = tokens.direction == LabDirection.kineticBlock;
    final text = isKinetic ? label.toUpperCase() : label;
    return SizedBox(
      height: compact ? 42 : tokens.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: tokens.accent,
          foregroundColor: tokens.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 16 : 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: tokens.bodyFontFamily,
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isKinetic ? 0.6 : 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LabSecondaryButton extends StatelessWidget {
  const LabSecondaryButton({
    super.key,
    required this.tokens,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final LabTokens tokens;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: tokens.raised,
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: tokens.accent),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.bodyStyle(13, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LabTag extends StatelessWidget {
  const LabTag({
    super.key,
    required this.tokens,
    required this.label,
    required this.color,
  });

  final LabTokens tokens;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: tokens.isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(
          tokens.direction == LabDirection.kineticBlock ? 4 : 999,
        ),
        border: Border.all(
          color: color.withValues(alpha: tokens.isDark ? 0.38 : 0.32),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: tokens.bodyFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class LabRingGauge extends StatelessWidget {
  const LabRingGauge({
    super.key,
    required this.tokens,
    required this.progress,
    required this.centerText,
    required this.color,
    this.size = 56,
  });

  final LabTokens tokens;
  final double progress;
  final String centerText;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          trackColor: tokens.raised,
          fillColor: color,
          strokeWidth: tokens.direction == LabDirection.kineticBlock ? 6 : 5,
        ),
        child: Center(
          child: Text(
            centerText,
            style: tokens.numberStyle(size * 0.27),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.trackColor != trackColor;
}

class LabVolumeBars extends StatelessWidget {
  const LabVolumeBars({
    super.key,
    required this.tokens,
    required this.points,
    this.height = 128,
  });

  final LabTokens tokens;
  final List<LabWeeklyPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxVal = points.fold<double>(
      1,
      (prev, e) => math.max(prev, e.volumeKg),
    );
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < points.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(points[i].volumeKg / 1000).toStringAsFixed(1)}t',
                      style: tokens.numberStyle(
                        11,
                        color: i == points.length - 1
                            ? tokens.accent
                            : tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: (points[i].volumeKg / maxVal).clamp(0.18, 1.0),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: i == points.length - 1
                                ? tokens.accent
                                : tokens.secondaryAccent.withValues(
                                    alpha: tokens.isDark ? 0.55 : 0.72,
                                  ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                tokens.direction == LabDirection.kineticBlock
                                    ? 3
                                    : 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      points[i].label,
                      style: tokens.labelStyle(11, color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LabResponsiveShell extends StatelessWidget {
  const LabResponsiveShell({
    super.key,
    required this.tokens,
    required this.selectedNavIndex,
    required this.onSelectNav,
    required this.body,
    this.isWide = false,
  });

  final LabTokens tokens;
  final int selectedNavIndex;
  final ValueChanged<int> onSelectNav;
  final Widget body;
  final bool isWide;

  static const _destinations = [
    (label: 'Today', icon: Icons.home_rounded),
    (label: 'Workout', icon: Icons.fitness_center_rounded),
    (label: 'Fuel', icon: Icons.restaurant_rounded),
    (label: 'Progress', icon: Icons.show_chart_rounded),
    (label: 'Design', icon: Icons.tune_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: [
          Container(
            width: 84,
            decoration: BoxDecoration(
              color: tokens.surface,
              border: Border(right: BorderSide(color: tokens.border)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                  ),
                  child: Icon(Icons.bolt_rounded, color: tokens.accent),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < _destinations.length; i++)
                  _RailItem(
                    tokens: tokens,
                    label: _destinations[i].label,
                    icon: _destinations[i].icon,
                    selected: selectedNavIndex == i,
                    onTap: () => onSelectNav(i),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: tokens.canvas,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: body,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: tokens.canvas,
            child: body,
          ),
        ),
        Container(
          height: 62,
          decoration: BoxDecoration(
            color: tokens.surface,
            border: Border(top: BorderSide(color: tokens.border)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _destinations.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelectNav(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selectedNavIndex == i
                                ? tokens.accent.withValues(alpha: 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            _destinations[i].icon,
                            size: 20,
                            color: selectedNavIndex == i
                                ? tokens.accent
                                : tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _destinations[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: tokens.bodyFontFamily,
                            fontSize: 10,
                            fontWeight: selectedNavIndex == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selectedNavIndex == i
                                ? tokens.accent
                                : tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.tokens,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final LabTokens tokens;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: selected ? tokens.accent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? tokens.accent : tokens.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: tokens.bodyFontFamily,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? tokens.accent : tokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
