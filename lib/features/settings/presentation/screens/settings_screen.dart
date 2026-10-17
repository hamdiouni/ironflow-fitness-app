import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import 'export_settings_screen.dart';
import 'privacy_settings_screen.dart';

/// Monolithic Sci-Fi Settings screen for app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SETTINGS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'SYSTEM PREFERENCES',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Theme section
          _SettingsSection(
            title: 'INTERFACE APPEARANCE',
            tokens: tokens,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONOLITHIC DARK THEME',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isDark
                              ? 'Active — High-contrast titanium'
                              : 'Light mode active',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      activeColor: tokens.kineticAccent,
                      onChanged: (value) {
                        ref
                            .read(themeProvider.notifier)
                            .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Data Management section
          _SettingsSection(
            title: 'DATA MANAGEMENT',
            tokens: tokens,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      title: 'Export Telemetry Data',
                      subtitle: 'Backup or extract CSV/JSON datasets',
                      icon: Icons.download_rounded,
                      tokens: tokens,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ExportSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Privacy & Permissions',
                      subtitle: 'Manage telemetry logs and account controls',
                      icon: Icons.privacy_tip_outlined,
                      tokens: tokens,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacySettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // About section
          _SettingsSection(
            title: 'CORE APPLICATION SYSTEM',
            tokens: tokens,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingItem(
                      label: 'APPLICATION',
                      value: 'IRONFLOW',
                      tokens: tokens,
                    ),
                    Divider(color: tokens.borderSubtle, height: 20),
                    _SettingItem(
                      label: 'ENGINE ARCHITECTURE',
                      value: 'MONOLITHIC SCI-FI',
                      tokens: tokens,
                    ),
                    Divider(color: tokens.borderSubtle, height: 20),
                    _SettingItem(
                      label: 'BUILD VERSION',
                      value: '1.0.0+1',
                      tokens: tokens,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final AppThemeTokens tokens;

  const _SettingsSection({
    required this.title,
    required this.children,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: tokens.textMuted,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Icon(
                icon,
                color: tokens.kineticAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: tokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeTokens tokens;

  const _SettingItem({
    required this.label,
    required this.value,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: tokens.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
  }
}
