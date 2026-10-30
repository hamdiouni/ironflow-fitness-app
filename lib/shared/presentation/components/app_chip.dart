import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi filter / selection chip.
///
/// Ensures 48dp minimum touch target, active kinetic border/glow, and high contrast.
class AppChip extends StatelessWidget {
  /// Creates an [AppChip].
  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.accentColor,
    this.height = 36.0,
  });

  /// Text displayed inside the chip.
  final String label;

  /// Whether this chip is currently selected.
  final bool isSelected;

  /// Callback when tapped.
  final VoidCallback onTap;

  /// Optional leading icon.
  final Widget? icon;

  /// Custom accent color override. Defaults to [tokens.kineticAccent].
  final Color? accentColor;

  /// Visual chip container height. Defaults to 36dp (padded to 48dp touch target).
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = accentColor ?? tokens.kineticAccent;

    final bg = isSelected ? accent.withValues(alpha: 0.15) : tokens.elevated;
    final fg = isSelected ? (tokens.isDark ? accent : accent) : tokens.textSecondary;
    final border = isSelected
        ? Border.all(color: accent, width: 1.5)
        : Border.all(color: tokens.borderSubtle, width: 1);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacings.minTouchTarget),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacings.xs),
          child: AnimatedContainer(
            duration: AppSpacings.durationFast,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacings.md),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(tokens.chipRadius),
              border: border,
              boxShadow: (isSelected && tokens.isDark)
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: fg, size: 14),
                    child: icon!,
                  ),
                  const SizedBox(width: AppSpacings.xs),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
