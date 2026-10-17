import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import 'app_button.dart';

/// Monolithic Sci-Fi empty, error, and offline state views.
class AppStateView extends StatelessWidget {
  /// Creates an [AppStateView].
  const AppStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  /// Factory for an empty state.
  factory AppStateView.empty({
    required String title,
    required String message,
    Widget? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppStateView(
      title: title,
      message: message,
      icon: icon ?? const Icon(Icons.inbox_outlined, size: 48),
      actionLabel: actionLabel,
      onAction: onAction,
      isError: false,
    );
  }

  /// Factory for an error state with retry.
  factory AppStateView.error({
    required String message,
    String title = 'Something went wrong',
    VoidCallback? onRetry,
  }) {
    return AppStateView(
      title: title,
      message: message,
      icon: const Icon(Icons.error_outline, size: 48),
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
      isError: true,
    );
  }

  /// Factory for an offline state.
  factory AppStateView.offline({
    String title = 'You are Offline',
    String message = 'Saved offline data is displayed. Changes will sync once connected.',
    VoidCallback? onRetry,
  }) {
    return AppStateView(
      title: title,
      message: message,
      icon: const Icon(Icons.wifi_off_rounded, size: 48),
      actionLabel: onRetry != null ? 'Reconnect' : null,
      onAction: onRetry,
      isError: false,
    );
  }

  /// Primary headline.
  final String title;

  /// Explanatory message.
  final String message;

  /// Main icon.
  final Widget? icon;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action callback.
  final VoidCallback? onAction;

  /// Whether this view represents a failure/error.
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = isError ? tokens.error : tokens.kineticAccent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacings.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(color: color, size: 36),
                    child: icon!,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacings.lg),
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
            const SizedBox(height: AppSpacings.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 14,
                color: tokens.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacings.xl),
              AppButton(
                label: actionLabel!,
                variant: isError ? AppButtonVariant.secondary : AppButtonVariant.primary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
