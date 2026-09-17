import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/rest_timer_provider.dart';

/// Rest timer widget with circular progress indicator
/// Shows countdown timer between sets with quick actions
class RestTimerWidget extends ConsumerWidget {
  final VoidCallback? onComplete;

  const RestTimerWidget({
    super.key,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    final theme = Theme.of(context);

    if (!timerState.isRunning && !timerState.isPaused) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
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
                  Icon(
                    Icons.timer,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rest Timer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  ref.read(restTimerProvider.notifier).stop();
                },
                tooltip: 'Close timer',
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // Circular timer
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress circle
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _CircularTimerPainter(
                    progress: timerState.progress,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                
                // Time display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerState.formattedTime,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timerState.isPaused ? 'Paused' : 'Rest',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Add 30s button
              _ActionButton(
                icon: Icons.add,
                label: '+30s',
                onPressed: () {
                  ref.read(restTimerProvider.notifier).addTime(30);
                },
                color: theme.colorScheme.tertiary,
              ),

              // Play/Pause button
              _ActionButton(
                icon: timerState.isPaused ? Icons.play_arrow : Icons.pause,
                label: timerState.isPaused ? 'Resume' : 'Pause',
                onPressed: () {
                  if (timerState.isPaused) {
                    ref.read(restTimerProvider.notifier).resume();
                  } else {
                    ref.read(restTimerProvider.notifier).pause();
                  }
                },
                color: theme.colorScheme.primary,
                isPrimary: true,
              ),

              // Skip button
              _ActionButton(
                icon: Icons.skip_next,
                label: 'Skip',
                onPressed: () {
                  ref.read(restTimerProvider.notifier).skip();
                  onComplete?.call();
                },
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action button for rest timer
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            color: isPrimary ? Colors.white : color,
            iconSize: isPrimary ? 28 : 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            fontWeight: FontWeight.w500,
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
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2; // Start at top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Rest timer dialog for selecting duration
class RestTimerDialog extends ConsumerWidget {
  const RestTimerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.timer, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text('Rest Timer'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How long do you want to rest?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: RestDurations.all.map((duration) {
              return _DurationChip(
                duration: duration,
                label: RestDurations.label(duration),
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Duration selection chip
class _DurationChip extends StatelessWidget {
  final int duration;
  final String label;
  final VoidCallback onTap;

  const _DurationChip({
    required this.duration,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
