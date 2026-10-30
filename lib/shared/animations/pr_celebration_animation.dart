import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';

/// A monolithic Sci-Fi celebration badge displayed when one or more Personal Records (PRs)
/// are achieved during a workout.
///
/// Features:
/// - Restrained holographic kinetic glow (cyan & neon green ambient lighting)
/// - Pure Flutter rendering (no missing Lottie asset dependencies)
/// - Telemetry-inspired sci-fi layout and typography
/// - Accessibility-first: respects [MediaQuery.maybeDisableAnimationsOf] to disable motion
///   for users who prefer reduced motion
class PRCelebrationAnimation extends StatefulWidget {
  final int prCount;

  const PRCelebrationAnimation({
    super.key,
    this.prCount = 1,
  });

  @override
  State<PRCelebrationAnimation> createState() => _PRCelebrationAnimationState();
}

class _PRCelebrationAnimationState extends State<PRCelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.25, end: 0.55), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.55, end: 0.25), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      _controller.value = 1.0;
    } else if (!_controller.isAnimating && _controller.value == 0.0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final prText = widget.prCount > 1
        ? '${widget.prCount} PERSONAL RECORDS'
        : 'PERSONAL RECORD';

    final badgeContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowOpacity = disableAnimations ? 0.35 : _glowAnimation.value;
        return Container(
          key: const ValueKey('pr_celebration_badge'),
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.12),
                AppTheme.accentColor.withValues(alpha: 0.06),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: glowOpacity * 0.5),
                blurRadius: 20,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: glowOpacity * 0.3),
                blurRadius: 32,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: glowOpacity * 0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'TELEMETRY // MILESTONE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PERFORMANCE THRESHOLD EXCEEDED',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (disableAnimations) {
      return badgeContent;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: badgeContent,
      ),
    );
  }
}
