import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/workout/presentation/providers/rest_timer_provider.dart';

/// A circular animated countdown widget that consumes [restTimerProvider].
///
/// Displays a [CircularProgressIndicator] whose progress reflects the
/// remaining fraction of the rest period. The indicator colour transitions
/// from green (progress > 50 %) to orange (progress ≤ 50 %) to give the
/// user an at-a-glance urgency cue. The remaining seconds are shown as
/// centred text inside the ring.
///
/// When the timer is idle or completed the widget renders nothing
/// (returns [SizedBox.shrink]).
///
/// Requirements: 3.2, 10.2
class RestTimerCircular extends ConsumerWidget {
  /// Diameter of the circular indicator.
  final double size;

  const RestTimerCircular({this.size = 120, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);

    if (timerState.isRunning && !timerState.isComplete) {
      final progress =
          timerState.totalSeconds > 0 ? timerState.remainingSeconds / timerState.totalSeconds : 0.0;
      final color = progress > 0.5 ? Colors.green : Colors.orange;

      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${timerState.remainingSeconds}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
