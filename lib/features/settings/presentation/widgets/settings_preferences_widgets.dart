import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/build_stamp.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import 'settings_section_tiles.dart';

/// Opens the modal picker dialog for switching the application language.
void showSettingsLanguagePicker(
  BuildContext context,
  WidgetRef ref,
  AppThemeTokens tokens,
  Locale currentLocale,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      title: Text(
        'LANGUAGE',
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: tokens.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageNotifier.supportedLocales.map((locale) {
              final isSelected =
                  locale.languageCode == currentLocale.languageCode;
              final name =
                  LanguageNotifier.languageNames[locale.languageCode] ??
                      locale.languageCode.toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(languageProvider.notifier).setLanguage(locale);
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.card : tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: isSelected
                            ? tokens.kineticAccent
                            : tokens.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          locale.languageCode.toUpperCase(),
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tokens.textMuted,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: tokens.kineticAccent,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'CLOSE',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w700,
              color: tokens.kineticAccent,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Compact selectable unit toggle pill (`KG` / `LBS`) used in Settings.
class SettingsUnitPill extends StatelessWidget {
  const SettingsUnitPill({
    super.key,
    required this.pillKey,
    required this.label,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  final Key pillKey;
  final String label;
  final bool selected;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        key: pillKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? tokens.kineticAccent : tokens.card,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(
              color: selected ? tokens.kineticAccent : tokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? tokens.onAccent : tokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// About Application metadata card showing version, commit and build date.
class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({
    super.key,
    required this.tokens,
    required this.onLongPressInspector,
  });

  final AppThemeTokens tokens;
  final VoidCallback onLongPressInspector;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: (l10n?.aboutApp ?? 'ABOUT APPLICATION').toUpperCase(),
      tokens: tokens,
      children: [
        GestureDetector(
          onLongPress: onLongPressInspector,
          child: Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingItem(
                  label: 'APPLICATION',
                  value: 'PROGRESSION TRACKER',
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 20),
                SettingItem(
                  label: 'BUILD VERSION',
                  value: BuildStamp.version,
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 20),
                SettingItem(
                  label: 'COMMIT',
                  value: '${BuildStamp.commit} (${BuildStamp.branch})',
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 20),
                SettingItem(
                  label: 'BUILD DATE',
                  value: BuildStamp.buildDate,
                  tokens: tokens,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
