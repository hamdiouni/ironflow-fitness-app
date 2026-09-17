import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A pure UI animation widget that displays a checkmark confirmation
/// when a set is completed. Scales in over 200ms, then fades out after
/// a 300ms delay. Triggers [onComplete] when the animation finishes.
///
/// Requirements: 1.4, 10.2, 10.3, 10.6
class SetCompletionAnimation extends StatelessWidget {
  final VoidCallback onComplete;

  const SetCompletionAnimation({
    required this.onComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(0.2),
      ),
      child: const Icon(Icons.check, color: Colors.green, size: 32),
    )
        .animate(onComplete: (_) => onComplete())
        .scale(duration: 200.ms, curve: Curves.easeOut)
        .fadeOut(delay: 300.ms, duration: 200.ms);
  }
}
