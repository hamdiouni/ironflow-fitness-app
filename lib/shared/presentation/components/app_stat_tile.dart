import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import 'app_card.dart';

/// Monolithic Sci-Fi telemetry stat tile.
///
/// Displays a high-contrast tabular number, unit label, icon indicator,
/// and optional delta trend badge.
class AppStatTile extends StatelessWidget {
  /// Creates an [AppStatTile].
  const AppStatTile({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.accentColor,
    this.delta,
    this.isPositiveDelta,
    this.onTap,
  });

  /// Label above or below the metric (e.g. "Total Volume", "Daily Calories").
  final String title;

  /// The main telemetry figure (e.g. "8,420", "142", "4").
  final String value;

  /// Optional unit label (e.g. "kg", "kcal", "days").
  final String? unit;

  /// Leading or badge icon.
  final Widget? icon;

  /// Accent highlight color. Defaults to [tokens.kineticAccent].
  final Color? accentColor;

  /// Optional trend delta text (e.g. "+8.4%", "PR").
  final String? delta;

  /// Whether the trend delta is positive (green) or negative (red/warning).
  final bool? isPositiveDelta;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = accentColor ?? tokens.kineticAccent;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacings.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Badge
              if (icon != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacings.radiusSm),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(color: accent, size: 16),
                      child: icon!,
                    ),
                  ),
                ),
              // Delta badge
              if (delta != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.sm,
                      vertical: AppSpacings.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositiveDelta ?? true)
                          ? tokens.success.withValues(alpha: 0.15)
                          : tokens.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacings.radiusPill),
                    ),
                    child: Text(
                      delta!,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: (isPositiveDelta ?? true) ? tokens.success : tokens.error,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacings.md),
          // Value & Unit row
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.tabularMetric(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: AppSpacings.xs),
                  Text(
                    unit!,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacings.xs),
          // Title Label
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: tokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
