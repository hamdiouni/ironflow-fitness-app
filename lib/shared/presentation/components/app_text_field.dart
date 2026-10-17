import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Monolithic Sci-Fi text input field.
///
/// Features high-contrast dark titanium surface, focus indicator glow,
/// prefix/suffix icons, and clean error state.
class AppTextField extends StatelessWidget {
  /// Creates an [AppTextField].
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Initial string value if controller is omitted.
  final String? initialValue;

  /// Top floating label text.
  final String? label;

  /// Placeholder hint text.
  final String? hintText;

  /// Subtitle helper text.
  final String? helperText;

  /// Validation error message.
  final String? errorText;

  /// Leading icon.
  final Widget? prefixIcon;

  /// Trailing icon or action.
  final Widget? suffixIcon;

  /// Keyboard type (e.g. number for workout sets).
  final TextInputType? keyboardType;

  /// Whether text is masked for passwords.
  final bool obscureText;

  /// Whether input is interactive.
  final bool enabled;

  /// Whether input is read-only.
  final bool readOnly;

  /// Whether to auto-focus on appearance.
  final bool autofocus;

  /// Maximum visible lines.
  final int maxLines;

  /// Value change callback.
  final ValueChanged<String>? onChanged;

  /// Form submission callback.
  final ValueChanged<String>? onSubmitted;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasError ? tokens.error : tokens.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacings.xs),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 15,
            color: tokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: tokens.elevated,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacings.lg,
              vertical: AppSpacings.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
              borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
              borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
              borderSide: BorderSide(
                color: hasError ? tokens.error : tokens.kineticAccent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
              borderSide: BorderSide(color: tokens.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
              borderSide: BorderSide(color: tokens.error, width: 1.5),
            ),
          ),
        ),
        if (helperText != null && !hasError) ...[
          const SizedBox(height: AppSpacings.xxs),
          Text(
            helperText!,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 11,
              color: tokens.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
