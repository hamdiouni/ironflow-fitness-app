import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Direction 4: Soft & Layered modal bottom sheet container and launcher.
class AppBottomSheet extends StatelessWidget {
  /// Creates an [AppBottomSheet].
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.action,
    this.padding = const EdgeInsets.all(AppSpacings.lg),
  });

  /// The main scrollable or column content of the sheet.
  final Widget child;

  /// Optional sheet header title.
  final String? title;

  /// Optional trailing header action.
  final Widget? action;

  /// Internal padding for the content.
  final EdgeInsetsGeometry padding;

  /// Static helper to display the sheet modal with responsive width containment.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? action,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AppBottomSheet(
            title: title,
            action: action,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacings.radiusXl)),
        border: Border(
          top: BorderSide(color: tokens.borderSubtle, width: 1),
          left: BorderSide(color: tokens.borderSubtle, width: 1),
          right: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: tokens.isDark ? 0.35 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Soft capsule drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacings.md, bottom: AppSpacings.sm),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: BorderRadius.circular(AppSpacings.radiusPill),
                ),
              ),
            ),
            // Header if title or action present
            if (title != null || action != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacings.lg,
                  vertical: AppSpacings.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    ?action,
                  ],
                ),
              ),
              Divider(color: tokens.borderSubtle, height: 16),
            ],
            // Main content
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
