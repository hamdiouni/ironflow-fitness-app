import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi section header with title, optional subtitle, and action button.
class AppSectionHeader extends StatelessWidget {
  /// Creates an [AppSectionHeader].
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionWidget,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacings.lg,
      vertical: AppSpacings.md,
    ),
  });

  /// The section header title.
  final String title;

  /// Optional descriptive subtitle.
  final String? subtitle;

  /// Text for trailing action button (e.g. "See All", "Edit").
  final String? actionLabel;

  /// Callback when action is tapped.
  final VoidCallback? onAction;

  /// Custom trailing widget (overrides [actionLabel]).
  final Widget? actionWidget;

  /// Padding around the header.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: tokens.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacings.xxs),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionWidget != null)
            actionWidget!
          else if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppSpacings.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacings.sm,
                  vertical: AppSpacings.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.kineticAccent,
                      ),
                    ),
                    const SizedBox(width: AppSpacings.xxs),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: tokens.kineticAccent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
