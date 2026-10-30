import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import 'app_button.dart';

/// Slate Teal modal confirmation / alert dialog.
///
/// Ensures compact desktop web width (max 440dp), consistent action buttons
/// (Confirm on right, Cancel on left), and high-contrast accessible surfaces.
class AppDialog extends StatelessWidget {
  /// Creates an [AppDialog].
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  /// Dialog header title.
  final String title;

  /// Main message content.
  final Widget content;

  /// Optional header badge icon.
  final Widget? icon;

  /// Label for confirm action button.
  final String confirmLabel;

  /// Label for cancel action button.
  final String cancelLabel;

  /// Callback when confirm is pressed.
  final VoidCallback? onConfirm;

  /// Callback when cancel is pressed.
  final VoidCallback? onCancel;

  /// Whether confirm button is styled destructively.
  final bool isDestructive;

  /// Static helper to display the dialog.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required Widget content,
    Widget? icon,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        icon: icon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Dialog(
          backgroundColor: tokens.panel,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.cardRadius),
            side: BorderSide(color: tokens.borderSubtle, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacings.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null) ...[
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isDestructive ? tokens.error : tokens.kineticAccent)
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IconTheme(
                          data: IconThemeData(
                            color: isDestructive ? tokens.error : tokens.kineticAccent,
                            size: 24,
                          ),
                          child: icon!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacings.md),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacings.md),
                DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14,
                    color: tokens.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  child: content,
                ),
                const SizedBox(height: AppSpacings.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: cancelLabel,
                        variant: AppButtonVariant.secondary,
                        onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppSpacings.md),
                    Expanded(
                      child: AppButton(
                        label: confirmLabel,
                        variant: isDestructive
                            ? AppButtonVariant.destructive
                            : AppButtonVariant.primary,
                        onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
