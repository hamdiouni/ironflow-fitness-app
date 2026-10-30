import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Semantic types for [AppSnackbar].
enum AppSnackbarType {
  success,
  warning,
  error,
  info,
}

/// Unified, high-contrast Slate Teal snackbar service.
///
/// Fixes low-contrast colored backgrounds by using a solid [tokens.panel] surface
/// with semantic icon accents and 100% WCAG AA compliant text.
class AppSnackbar {
  AppSnackbar._();

  /// Displays a floating snackbar with semantic icon, title, and optional undo/action button.
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final tokens = context.tokens;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Color accentColor;
    IconData iconData;

    switch (type) {
      case AppSnackbarType.success:
        accentColor = tokens.success;
        iconData = Icons.check_circle_rounded;
        break;
      case AppSnackbarType.warning:
        accentColor = tokens.warning;
        iconData = Icons.warning_amber_rounded;
        break;
      case AppSnackbarType.error:
        accentColor = tokens.error;
        iconData = Icons.error_outline_rounded;
        break;
      case AppSnackbarType.info:
        accentColor = tokens.kineticAccent;
        iconData = Icons.info_outline_rounded;
        break;
    }

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacings.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.lg,
          vertical: AppSpacings.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        backgroundColor: tokens.panel,
        elevation: 6,
        content: Row(
          children: [
            Icon(iconData, color: accentColor, size: 20),
            const SizedBox(width: AppSpacings.md),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: tokens.textPrimary,
                ),
              ),
            ),
          ],
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: accentColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Convenience helper for success snackbars.
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      show(
        context,
        message: message,
        type: AppSnackbarType.success,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Convenience helper for error snackbars.
  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      show(
        context,
        message: message,
        type: AppSnackbarType.error,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Convenience helper for warning snackbars.
  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      show(
        context,
        message: message,
        type: AppSnackbarType.warning,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Convenience helper for info snackbars.
  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      show(
        context,
        message: message,
        type: AppSnackbarType.info,
        actionLabel: actionLabel,
        onAction: onAction,
      );
}

