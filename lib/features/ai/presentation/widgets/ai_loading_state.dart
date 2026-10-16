import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Reusable loading skeleton for AI coaching widgets.
///
/// Features:
/// - Smooth pulse/shimmer animation adhering to theme tokens.
/// - Respects system reduced-motion preference ([disableAnimations]).
/// - Accessible with proper [Semantics].
class AiLoadingState extends StatefulWidget {
  const AiLoadingState({
    super.key,
    this.compact = false,
  });

  /// Whether to render a compact single-line skeleton (for banners).
  final bool compact;

  @override
  State<AiLoadingState> createState() => _AiLoadingStateState();
}

class _AiLoadingStateState extends State<AiLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return Semantics(
      label: 'Loading AI insights',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final opacity = disableAnimations ? 0.6 : _animation.value;
          final color = baseColor.withValues(alpha: opacity);

          if (widget.compact) {
            return Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header skeleton
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              // Content lines skeleton
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
