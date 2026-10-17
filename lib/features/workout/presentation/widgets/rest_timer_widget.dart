import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/rest_timer_provider.dart';

/// Rest timer widget with circular progress indicator.
/// Shows countdown timer between sets with quick actions in Monolithic Sci-Fi styling.
class RestTimerWidget extends ConsumerWidget {
  final VoidCallback? onComplete;

  const RestTimerWidget({
    super.key,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    final tokens = context.tokens;

    if (!timerState.isRunning && !timerState.isPaused) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: tokens.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.kineticAccent.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: tokens.kineticAccent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'REST TIMER',
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: Icon(Icons.close, size: 20, color: tokens.textMuted),
                  onPressed: () {
                    ref.read(restTimerProvider.notifier).stop();
                  },
                  tooltip: 'Close timer',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Circular timer
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress circle
                CustomPaint(
                  size: const Size(170, 170),
                  painter: _CircularTimerPainter(
                    progress: timerState.progress,
                    color: tokens.kineticAccent,
                    backgroundColor: tokens.panel,
                  ),
                ),
                
                // Time display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerState.formattedTime,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: tokens.kineticAccent,
                        fontFamily: AppTypography.fontFamilyHeadings,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timerState.isPaused ? 'PAUSED' : 'RECOVERY',
                      style: TextStyle(
                        color: timerState.isPaused ? tokens.warning : tokens.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTypography.fontFamilyHeadings,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Add 30s button
              _ActionButton(
                icon: Icons.add,
                label: '+30S',
                tokens: tokens,
                onPressed: () {
                  ref.read(restTimerProvider.notifier).addTime(30);
                },
              ),

              // Play/Pause button
              _ActionButton(
                icon: timerState.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: timerState.isPaused ? 'RESUME' : 'PAUSE',
                tokens: tokens,
                isPrimary: true,
                onPressed: () {
                  if (timerState.isPaused) {
                    ref.read(restTimerProvider.notifier).resume();
                  } else {
                    ref.read(restTimerProvider.notifier).pause();
                  }
                },
              ),

              // Skip button
              _ActionButton(
                icon: Icons.skip_next_rounded,
                label: 'SKIP',
                tokens: tokens,
                onPressed: () {
                  ref.read(restTimerProvider.notifier).skip();
                  onComplete?.call();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action button for rest timer with WCAG 48dp touch target
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final AppThemeTokens tokens;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.tokens,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPrimary ? tokens.kineticAccent : tokens.panel,
            shape: BoxShape.circle,
            border: Border.all(
              color: isPrimary ? tokens.kineticAccent : tokens.borderSubtle,
              width: 1,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: tokens.kineticAccent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            color: isPrimary ? const Color(0xFF000000) : tokens.textPrimary,
            iconSize: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isPrimary ? tokens.kineticAccent : tokens.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamilyHeadings,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Circular timer painter
class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularTimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 5, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2; // Start at top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Rest timer dialog for selecting duration in Monolithic Sci-Fi styling
class RestTimerDialog extends ConsumerWidget {
  const RestTimerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return AlertDialog(
      backgroundColor: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      title: Row(
        children: [
          Icon(Icons.timer_outlined, color: tokens.kineticAccent),
          const SizedBox(width: 10),
          Text(
            'REST INTERVAL',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select interval duration between training sets:',
            style: TextStyle(color: tokens.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: RestDurations.all.map((duration) {
              return _DurationChip(
                duration: duration,
                label: RestDurations.label(duration),
                tokens: tokens,
                onTap: () {
                  ref.read(restTimerProvider.notifier).start(duration);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
        ),
      ],
    );
  }
}

/// Duration selection chip
class _DurationChip extends StatelessWidget {
  final int duration;
  final String label;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  const _DurationChip({
    required this.duration,
    required this.label,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: tokens.kineticAccent,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamilyHeadings,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
