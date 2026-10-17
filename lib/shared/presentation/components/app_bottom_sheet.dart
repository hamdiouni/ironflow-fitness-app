import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi modal bottom sheet container and launcher.
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

  /// Static helper to display the sheet modal.
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
      builder: (context) => AppBottomSheet(
        title: title,
        action: action,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: tokens.borderSubtle, width: 1),
          left: BorderSide(color: tokens.borderSubtle, width: 1),
          right: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppSpacings.md, bottom: AppSpacings.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
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
