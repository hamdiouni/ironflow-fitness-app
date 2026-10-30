import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi interactive list tile.
///
/// Features clean structural separation, leading icon container,
/// trailing telemetry metric or chevron, and 48dp minimum touch target.
class AppListTile extends StatelessWidget {
  /// Creates an [AppListTile].
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacings.lg,
      vertical: AppSpacings.md,
    ),
    this.showBorder = false,
  });

  /// Primary title text.
  final String title;

  /// Optional subtitle or detail text.
  final String? subtitle;

  /// Leading widget (e.g. icon or badge).
  final Widget? leading;

  /// Trailing widget (e.g. value, badge, or chevron).
  final Widget? trailing;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Custom background color. Defaults to [tokens.card].
  final Color? backgroundColor;

  /// Custom corner radius. Defaults to [AppSpacings.radiusMd].
  final double? borderRadius;

  /// Internal padding.
  final EdgeInsetsGeometry contentPadding;

  /// Whether to render a structural 1px border.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? tokens.radiusMd;
    final bg = backgroundColor ?? tokens.card;

    return Container(
      constraints: const BoxConstraints(minHeight: AppSpacings.minTouchTarget),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder ? Border.all(color: tokens.borderSubtle, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacings.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacings.xxs),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 13,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacings.md),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: AppSpacings.md),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: tokens.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
