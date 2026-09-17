import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Centralized style guide for consistent UI across the app.
///
/// All screens should use these predefined styles instead of hardcoding values.
class StyleGuide {
  // ── Button Styles ───────────────────────────────────────────────────────────

  /// Primary button style (elevated, full-width).
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      );

  /// Secondary button style (outlined).
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      );

  /// Tertiary button style (text only).
  static ButtonStyle get tertiaryButtonStyle => TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
      );

  // ── Text Styles ─────────────────────────────────────────────────────────────

  /// Large heading style (24pt, bold).
  static TextStyle get headingLarge => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  /// Medium heading style (20pt, bold).
  static TextStyle get headingMedium => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      );

  /// Small heading style (16pt, bold).
  static TextStyle get headingSmall => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      );

  /// Body text style (14pt, regular).
  static TextStyle get bodyText => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      );

  /// Body text small style (12pt, regular).
  static TextStyle get bodyTextSmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      );

  /// Caption style (11pt, regular, secondary color).
  static TextStyle get caption => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      );

  // ── Spacing Presets ─────────────────────────────────────────────────────────

  /// Standard padding for screens.
  static const EdgeInsets screenPadding = EdgeInsets.all(AppTheme.spacingMedium);

  /// Standard padding for cards.
  static const EdgeInsets cardPadding = EdgeInsets.all(AppTheme.spacingMedium);

  /// Standard padding for list items.
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: AppTheme.spacingMedium,
    vertical: AppTheme.spacingSmall,
  );

  /// Standard gap between sections.
  static const SizedBox sectionGap = SizedBox(height: AppTheme.spacingLarge);

  /// Standard gap between items.
  static const SizedBox itemGap = SizedBox(height: AppTheme.spacingMedium);

  /// Standard gap between small items.
  static const SizedBox smallGap = SizedBox(height: AppTheme.spacingSmall);

  // ── Border Radius Presets ───────────────────────────────────────────────────

  /// Small border radius (8pt).
  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(AppTheme.borderRadiusSmall);

  /// Medium border radius (16pt).
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(AppTheme.borderRadiusMedium);

  /// Large border radius (24pt).
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(AppTheme.borderRadiusLarge);

  // ── Shadow Presets ──────────────────────────────────────────────────────────

  /// Subtle shadow for cards.
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Medium shadow for elevated elements.
  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Strong shadow for modals.
  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Input Field Decoration ──────────────────────────────────────────────────

  /// Standard input field decoration.
  static InputDecoration standardInputDecoration({
    required String hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
      );

  // ── Divider Presets ─────────────────────────────────────────────────────────

  /// Standard divider.
  static const Divider standardDivider = Divider(
    height: AppTheme.spacingMedium,
    thickness: 1,
  );

  /// Subtle divider.
  static Divider get subtleDivider => Divider(
        height: AppTheme.spacingSmall,
        thickness: 0.5,
        color: AppTheme.textSecondary.withValues(alpha: 0.2),
      );
}
