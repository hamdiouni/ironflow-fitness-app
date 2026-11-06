import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/build_stamp.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../widgets/settings_dialogs.dart';
import '../widgets/settings_section_tiles.dart';
import 'export_settings_screen.dart';
import 'privacy_settings_screen.dart';

/// Monolithic Sci-Fi Settings screen organizing all preferences into 7 core sections:
/// 1. Account (Profile & Biometrics, Edit Profile, Terminate Session)
/// 2. Training (Tactile Telemetry, Monolithic Dark Theme, Exercise Catalog, Workout History)
/// 3. Data Management (Export Telemetry, Restore System Data)
/// 4. Notifications (Reminder Settings)
/// 5. Privacy & Compliance (Telemetry Controls, Terms of Service, Privacy Policy)
/// 6. Developer Protocols (kDebugMode only: AI Diagnostic, Design System Gallery)
/// 7. Core Application System (App Version, Monolithic Sci-Fi Architecture)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);
    final aiConsent = ref.watch(aiPersonalizationConsentProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final displayName = user?.displayName?.trim();
    final email = user?.email.trim();
    final profileName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (email != null && email.isNotEmpty)
            ? email.split('@').first.toUpperCase()
            : 'ATHLETE';
    final goalDesc =
        profileAsync.valueOrNull?.goal.displayName.toUpperCase() ??
            'ACTIVE PLAN';

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
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
              'SYSTEM CONFIGURATION',
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
          // ── SECTION 1: ACCOUNT ──────────────────────────────────────────
          SettingsSection(
            title: 'ACCOUNT',
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
                    SettingsTile(
                      title: profileName.toUpperCase(),
                      subtitle:
                          '$goalDesc · View your body stats & workout plan',
                      icon: Icons.person_outline_rounded,
                      tokens: tokens,
                      onTap: () => context.push(AppRoutes.profile),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Edit Body Stats & Goals',
                      subtitle: 'Update targets, training days, and equipment',
                      icon: Icons.edit_note_rounded,
                      tokens: tokens,
                      onTap: () => context.go(AppRoutes.onboarding),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Log Out',
                      subtitle: 'Sign out of your account on this device',
                      icon: Icons.logout_rounded,
                      tokens: tokens,
                      iconColor: tokens.error,
                      titleColor: tokens.error,
                      onTap: () =>
                          showSettingsLogoutDialog(context, ref, tokens),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── SECTION 2: TRAINING PREFERENCES ─────────────────────────────
          SettingsSection(
            title: 'TRAINING & INTERFACE',
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
                    // Haptic feedback switch
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tokens.card,
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusSm),
                              border: Border.all(
                                color: tokens.borderSubtle,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.vibration_rounded,
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
                                  'VIBRATION & HAPTICS',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hapticsEnabled
                                      ? 'Tactile pulses on sets, timers & tabs'
                                      : 'Disabled',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 11,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: hapticsEnabled,
                            activeThumbColor: tokens.kineticAccent,
                            onChanged: (val) {
                              ref
                                  .read(hapticsEnabledProvider.notifier)
                                  .toggle(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    // Dark/Light theme switch
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tokens.card,
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusSm),
                              border: Border.all(
                                color: tokens.borderSubtle,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
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
                                  'STRIPE DARK DASHBOARD',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark
                                      ? 'Deep navy brand shell (#1C1E54)'
                                      : 'Light mode canvas',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 11,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeThumbColor: tokens.kineticAccent,
                            onChanged: (val) {
                              ref
                                  .read(themeProvider.notifier)
                                  .setTheme(
                                    val ? ThemeMode.dark : ThemeMode.light,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Exercise Catalog',
                      subtitle:
                          'Browse 50+ movement techniques, tips & targeted muscles',
                      icon: Icons.fitness_center_rounded,
                      tokens: tokens,
                      onTap: () => context.go(AppRoutes.workoutCatalog),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Workout History',
                      subtitle:
                          'Historical session logs, volume curves & completed routines',
                      icon: Icons.history_rounded,
                      tokens: tokens,
                      onTap: () => context.go(AppRoutes.workoutHistory),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── SECTION 3: DATA MANAGEMENT & BACKUP ─────────────────────────
          SettingsSection(
            title: 'DATA MANAGEMENT & BACKUP',
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
                    SettingsTile(
                      title: 'Export Workout & Nutrition Data',
                      subtitle:
                          'Generate CSV / JSON archives for workouts, nutrition & backup',
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
                    SettingsTile(
                      title: 'Restore System Data',
                      subtitle:
                          'Pre-validate backup archives with safe preview before restore',
                      icon: Icons.restore_rounded,
                      tokens: tokens,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ExportSettingsScreen(),
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

          // ── SECTION 4: NOTIFICATIONS & REMINDERS ─────────────────────────
          SettingsSection(
            title: 'NOTIFICATIONS & PROTOCOLS',
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
                    SettingsTile(
                      title: 'Scheduled Reminders',
                      subtitle:
                          'Configure daily training time, meal notifications & rest alerts',
                      icon: Icons.notifications_active_outlined,
                      tokens: tokens,
                      onTap: () => context.go(AppRoutes.reminderSettings),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── SECTION 5: PRIVACY & COMPLIANCE ─────────────────────────────
          SettingsSection(
            title: 'PRIVACY & LEGAL',
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
                    // AI Personalization Telemetry switch
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tokens.card,
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusSm),
                              border: Border.all(
                                color: tokens.borderSubtle,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.psychology_outlined,
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
                                  'AI WORKOUT & DIET SHARING',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  aiConsent
                                      ? 'Active · Workout & nutrition logs shared with AI coach'
                                      : 'Disabled · AI coach only answers general questions',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 11,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: aiConsent,
                            activeThumbColor: tokens.kineticAccent,
                            onChanged: (val) {
                              AppHaptics.shared.selectionChanged();
                              ref
                                  .read(aiPersonalizationConsentProvider.notifier)
                                  .setConsent(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Privacy & Data Controls',
                      subtitle:
                          'Manage anonymous metrics, crash reports & danger zone',
                      icon: Icons.privacy_tip_outlined,
                      tokens: tokens,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const PrivacySettingsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Terms of Service',
                      subtitle: 'Review operating agreement & health disclaimer',
                      icon: Icons.description_outlined,
                      tokens: tokens,
                      onTap: () => showSettingsDocumentDialog(
                        context,
                        title: 'TERMS OF SERVICE',
                        tokens: tokens,
                        content: kIronFlowTermsOfService,
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    SettingsTile(
                      title: 'Privacy Policy',
                      subtitle:
                          'Information handling, offline data storage & rights',
                      icon: Icons.shield_outlined,
                      tokens: tokens,
                      onTap: () => showSettingsDocumentDialog(
                        context,
                        title: 'PRIVACY POLICY',
                        tokens: tokens,
                        content: kIronFlowPrivacyPolicy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── SECTION 6: DEVELOPER PROTOCOLS (kDebugMode only) ─────────────
          if (kDebugMode) ...[
            SettingsSection(
              title: 'DEVELOPER PROTOCOLS [DEBUG ONLY]',
              tokens: tokens,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: tokens.panel,
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    border: Border.all(
                      color: tokens.kineticAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        title: 'Reset Onboarding Protocol',
                        subtitle:
                            'Clear onboarding flag and re-run goal selection stepper',
                        icon: Icons.restart_alt_rounded,
                        tokens: tokens,
                        iconColor: tokens.warning,
                        titleColor: tokens.warning,
                        onTap: () =>
                            resetSettingsOnboarding(context, ref, tokens),
                      ),
                      Divider(color: tokens.borderSubtle, height: 1),
                      SettingsTile(
                        title: 'Inspect App State Telemetry',
                        subtitle:
                            'Inspect live Auth, Onboarding & Gemini API configuration',
                        icon: Icons.monitor_heart_outlined,
                        tokens: tokens,
                        onTap: () =>
                            showSettingsStateInspector(context, ref, tokens),
                      ),
                      Divider(color: tokens.borderSubtle, height: 1),
                      SettingsTile(
                        title: 'AI Diagnostic Test',
                        subtitle: 'Test Gemini inference and mock responses',
                        icon: Icons.bug_report_outlined,
                        tokens: tokens,
                        onTap: () => context.push(AppRoutes.aiTest),
                      ),
                      Divider(color: tokens.borderSubtle, height: 1),
                      SettingsTile(
                        title: 'Design System Gallery',
                        subtitle:
                            'Inspect titanium design system tokens and widgets',
                        icon: Icons.palette_outlined,
                        tokens: tokens,
                        onTap: () => context.push(AppRoutes.designGallery),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ── SECTION 7: CORE APPLICATION SYSTEM (ABOUT) ──────────────────
          SettingsSection(
            title: 'CORE APPLICATION SYSTEM',
            tokens: tokens,
            children: [
              GestureDetector(
                onLongPress: () =>
                    showSettingsStateInspector(context, ref, tokens),
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
                        value: 'IRONFLOW',
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
          ),
        ],
      ),
    );
  }
}
