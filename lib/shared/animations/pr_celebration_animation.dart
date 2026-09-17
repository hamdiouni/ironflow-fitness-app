import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A pure UI widget that displays a celebration animation when a PR is achieved.
///
/// Uses Lottie for the animation asset. If the asset is not yet available,
/// falls back to a simple icon-based celebration widget.
///
/// Requirements: 2.4, 10.6
class PRCelebrationAnimation extends StatelessWidget {
  const PRCelebrationAnimation({super.key});

  static const String _assetPath = 'assets/animations/celebration.json';

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      _assetPath,
      width: 200,
      height: 200,
      repeat: false,
      errorBuilder: (context, error, stackTrace) {
        return const _FallbackCelebration();
      },
    );
  }
}

/// Fallback widget displayed when the Lottie asset is not available.
class _FallbackCelebration extends StatelessWidget {
  const _FallbackCelebration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 80,
            color: Colors.amber.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'New PR! 🎉',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.amber.shade400,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
