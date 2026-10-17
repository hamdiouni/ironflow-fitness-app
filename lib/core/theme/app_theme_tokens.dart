import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacings.dart';

/// Extension tokens exposing the Monolithic Sci-Fi design system through Flutter's [ThemeExtension].
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.isDark,
    required this.canvas,
    required this.panel,
    required this.card,
    required this.elevated,
    required this.borderSubtle,
    required this.borderGlow,
    required this.kineticAccent,
    required this.cyanAccent,
    required this.violetAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.cardDecoration,
    required this.glowDecoration,
  });

  final bool isDark;

  // Surfaces
  final Color canvas;
  final Color panel;
  final Color card;
  final Color elevated;
  final Color borderSubtle;
  final Color borderGlow;

  // Accents
  final Color kineticAccent;
  final Color cyanAccent;
  final Color violetAccent;

  // Typography
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Semantics
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Macro Nutrients
  final Color protein;
  final Color carbs;
  final Color fats;

  // Decorations
  final BoxDecoration cardDecoration;
  final BoxDecoration glowDecoration;

  // Spacing & Radii references
  double get radiusXs => AppSpacings.radiusXs;
  double get radiusSm => AppSpacings.radiusSm;
  double get radiusMd => AppSpacings.radiusMd;
  double get radiusLg => AppSpacings.radiusLg;
  double get radiusPill => AppSpacings.radiusPill;

  // Convenient alias
  Color get textTertiary => textMuted;

  /// Monolithic Sci-Fi Dark Tokens.
  static final AppThemeTokens dark = AppThemeTokens(
    isDark: true,
    canvas: AppColors.canvasDark,
    panel: AppColors.panelDark,
    card: AppColors.cardDark,
    elevated: AppColors.elevatedDark,
    borderSubtle: AppColors.borderSubtleDark,
    borderGlow: AppColors.borderGlowDark,
    kineticAccent: AppColors.kineticAccentDark,
    cyanAccent: AppColors.cyanAccentDark,
    violetAccent: AppColors.violetAccentDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textMuted: AppColors.textMutedDark,
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    error: AppColors.errorDark,
    info: AppColors.infoDark,
    protein: AppColors.protein,
    carbs: AppColors.carbs,
    fats: AppColors.fats,
    cardDecoration: BoxDecoration(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
      border: Border.all(color: AppColors.borderSubtleDark, width: 1),
    ),
    glowDecoration: BoxDecoration(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
      border: Border.all(color: AppColors.kineticAccentDark, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3300FF87),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
  );

  /// Architectural Titanium Light Tokens.
  static final AppThemeTokens light = AppThemeTokens(
    isDark: false,
    canvas: AppColors.canvasLight,
    panel: AppColors.panelLight,
    card: AppColors.cardLight,
    elevated: AppColors.elevatedLight,
    borderSubtle: AppColors.borderSubtleLight,
    borderGlow: AppColors.borderGlowLight,
    kineticAccent: AppColors.kineticAccentLight,
    cyanAccent: AppColors.cyanAccentLight,
    violetAccent: AppColors.violetAccentLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textMuted: AppColors.textMutedLight,
    success: AppColors.successLight,
    warning: AppColors.warningLight,
    error: AppColors.errorLight,
    info: AppColors.infoLight,
    protein: AppColors.protein,
    carbs: AppColors.carbs,
    fats: AppColors.fats,
    cardDecoration: BoxDecoration(
      color: AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
      border: Border.all(color: AppColors.borderSubtleLight, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    glowDecoration: BoxDecoration(
      color: AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppSpacings.radiusMd),
      border: Border.all(color: AppColors.kineticAccentLight, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2600A855),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    ),
  );

  @override
  AppThemeTokens copyWith({
    bool? isDark,
    Color? canvas,
    Color? panel,
    Color? card,
    Color? elevated,
    Color? borderSubtle,
    Color? borderGlow,
    Color? kineticAccent,
    Color? cyanAccent,
    Color? violetAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? protein,
    Color? carbs,
    Color? fats,
    BoxDecoration? cardDecoration,
    BoxDecoration? glowDecoration,
  }) {
    return AppThemeTokens(
      isDark: isDark ?? this.isDark,
      canvas: canvas ?? this.canvas,
      panel: panel ?? this.panel,
      card: card ?? this.card,
      elevated: elevated ?? this.elevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderGlow: borderGlow ?? this.borderGlow,
      kineticAccent: kineticAccent ?? this.kineticAccent,
      cyanAccent: cyanAccent ?? this.cyanAccent,
      violetAccent: violetAccent ?? this.violetAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      cardDecoration: cardDecoration ?? this.cardDecoration,
      glowDecoration: glowDecoration ?? this.glowDecoration,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      card: Color.lerp(card, other.card, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderGlow: Color.lerp(borderGlow, other.borderGlow, t)!,
      kineticAccent: Color.lerp(kineticAccent, other.kineticAccent, t)!,
      cyanAccent: Color.lerp(cyanAccent, other.cyanAccent, t)!,
      violetAccent: Color.lerp(violetAccent, other.violetAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      protein: Color.lerp(protein, other.protein, t)!,
      carbs: Color.lerp(carbs, other.carbs, t)!,
      fats: Color.lerp(fats, other.fats, t)!,
      cardDecoration: BoxDecoration.lerp(cardDecoration, other.cardDecoration, t)!,
      glowDecoration: BoxDecoration.lerp(glowDecoration, other.glowDecoration, t)!,
    );
  }

  /// Convenience static helper to retrieve tokens from [BuildContext].
  static AppThemeTokens of(BuildContext context) => context.tokens;
}

/// Extension on [BuildContext] for ergonomic access to design tokens.
extension AppThemeContextExtension on BuildContext {
  /// Quick access to the [AppThemeTokens] of the current theme.
  AppThemeTokens get tokens {
    final themeTokens = Theme.of(this).extension<AppThemeTokens>();
    if (themeTokens != null) return themeTokens;
    return Theme.of(this).brightness == Brightness.dark
        ? AppThemeTokens.dark
        : AppThemeTokens.light;
  }
}

