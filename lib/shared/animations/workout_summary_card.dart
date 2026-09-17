import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_theme.dart';

/// A pure UI widget that displays an animated workout summary card.
///
/// Shows total sets, volume, duration, and PR count with glassmorphism
/// styling. Animates in with a combined fadeIn and scale effect (300ms).
///
/// Requirements: 4.4, 10.2, 10.6
class WorkoutSummaryCard extends StatelessWidget {
  final int totalSets;
  final double totalVolume;
  final Duration duration;
  final int prCount;

  const WorkoutSummaryCard({
    required this.totalSets,
    required this.totalVolume,
    required this.duration,
    required this.prCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTheme.glassBlurSigma,
          sigmaY: AppTheme.glassBlurSigma,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            color: surface.withValues(alpha: 0.8),
            border: Border.all(
              color: onSurface.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Workout Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              _SummaryRow(
                icon: Icons.fitness_center,
                label: 'Total Sets',
                value: '$totalSets',
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              _SummaryRow(
                icon: Icons.monitor_weight_outlined,
                label: 'Total Volume',
                value: '${totalVolume.toStringAsFixed(0)} kg',
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              _SummaryRow(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: _formatDuration(duration),
              ),
              if (prCount > 0) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                _SummaryRow(
                  icon: Icons.emoji_events_outlined,
                  label: 'Personal Records',
                  value: '$prCount 🎉',
                  valueColor: AppTheme.primaryColor,
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Icon(icon, color: secondary, size: 20),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: secondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? onSurface,
          ),
        ),
      ],
    );
  }
}
