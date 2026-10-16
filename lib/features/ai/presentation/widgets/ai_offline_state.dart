import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Reusable offline state widget for AI coaching views.
///
/// Displayed when network connectivity is lost. Explains that fresh insights
/// require an internet connection, while cached data remains preserved.
class AiOfflineState extends StatelessWidget {
  const AiOfflineState({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.tertiary;

    return Semantics(
      label:
          'Offline: Connect to the internet to get fresh AI coaching recommendations.',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingMedium,
          horizontal: AppTheme.spacingSmall,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: warningColor.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: warningColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    "You're currently offline",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Connect to the internet to refresh AI coaching recommendations. Your previously cached insights remain available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Check Connection'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
