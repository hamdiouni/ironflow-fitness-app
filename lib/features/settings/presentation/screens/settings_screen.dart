import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/data/user_profile_storage.dart';
import '../../../ai/data/datasources/gemini_ai_service.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppThemeTokens tokens) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        icon: Icon(
          Icons.logout_rounded,
          size: 40,
          color: tokens.error,
        ),
        title: Text(
          'LOG OUT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out? Your workouts and nutrition logs are saved on your device.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13,
            color: tokens.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontWeight: FontWeight.w700,
                      color: tokens.textMuted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AppButton(
                  label: 'LOGOUT',
                  onPressed: () async {
                    final rootNavigator = Navigator.of(context, rootNavigator: true);
                    final router = GoRouter.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    rootNavigator.pop();

                    bool dialogOpen = true;
                    showDialog(
                      context: context,
                      useRootNavigator: true,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: tokens.panel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(tokens.radiusMd),
                          side: BorderSide(color: tokens.borderSubtle, width: 1),
                        ),
                        content: Row(
                          children: [
                            CircularProgressIndicator(
                              color: tokens.kineticAccent,
                            ),
                            const SizedBox(width: 18),
                            Text(
                              'Terminating session...',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                color: tokens.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).then((_) {
                      dialogOpen = false;
                    });

                    void dismissLoadingDialog() {
                      if (dialogOpen) {
                        dialogOpen = false;
                        rootNavigator.pop();
                      }
                    }

                    try {
                      await ref
                          .read(authNotifierProvider.notifier)
                          .signOut()
                          .timeout(const Duration(seconds: 3));

                      dismissLoadingDialog();
                      router.go('/login');
                    } on TimeoutException {
                      dismissLoadingDialog();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Logout is taking longer than expected. Redirecting...'),
                          backgroundColor: tokens.warning,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      router.go('/login');
                    } catch (e) {
                      dismissLoadingDialog();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Logout error: ${e.toString()}'),
                          backgroundColor: tokens.error,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentDialog(
    BuildContext context, {
    required String title,
    required String content,
    required AppThemeTokens tokens,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12,
                color: tokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref, AppThemeTokens tokens) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          'RESET ONBOARDING PROTOCOL',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: Text(
          'This will clear the onboarding completion flag and redirect you to the guided goal selection stepper. Your existing workouts and account remain safe.',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13,
            color: tokens.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.kineticAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('RESET & RE-RUN'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await UserProfileStorage().resetOnboarding();
      ref.invalidate(isOnboardedProvider);
      ref.invalidate(userProfileProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Onboarding reset! Redirecting to setup...'),
            backgroundColor: tokens.kineticAccent,
          ),
        );
        context.go(AppRoutes.onboarding);
      }
    }
  }

  void _showStateInspector(BuildContext context, WidgetRef ref, AppThemeTokens tokens) {
    final authState = ref.read(authNotifierProvider);
    final isOnboarded = UserProfileStorage().isOnboardedSync();
    final isGeminiConfigured = GeminiAIService().isConfigured;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: tokens.kineticAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'APP STATE TELEMETRY',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingItem(
              label: 'AUTH STATUS',
              value: authState.isAuthenticated ? 'AUTHENTICATED' : 'ANONYMOUS',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _SettingItem(
              label: 'USER ID',
              value: (authState.user != null && authState.user!.id.isNotEmpty)
                  ? authState.user!.id.substring(0, authState.user!.id.length > 12 ? 12 : authState.user!.id.length)
                  : 'NONE',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _SettingItem(
              label: 'ONBOARDING STATUS',
              value: isOnboarded ? 'COMPLETED' : 'PENDING',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _SettingItem(
              label: 'GEMINI API KEY',
              value: isGeminiConfigured ? 'CONFIGURED' : 'NOT SET',
              tokens: tokens,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'DISMISS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.kineticAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final goalDesc = profileAsync.valueOrNull?.goal.displayName.toUpperCase() ?? 'ACTIVE PLAN';

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
          _SettingsSection(
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
                    _SettingsTile(
                      title: profileName.toUpperCase(),
                      subtitle: '$goalDesc · View your body stats & workout plan',
                      icon: Icons.person_outline_rounded,
                      tokens: tokens,
                      onTap: () => context.push(AppRoutes.profile),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Edit Body Stats & Goals',
                      subtitle: 'Update targets, training days, and equipment',
                      icon: Icons.edit_note_rounded,
                      tokens: tokens,
                      onTap: () => context.go(AppRoutes.onboarding),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Log Out',
                      subtitle: 'Sign out of your account on this device',
                      icon: Icons.logout_rounded,
                      tokens: tokens,
                      iconColor: tokens.error,
                      titleColor: tokens.error,
                      onTap: () => _showLogoutDialog(context, ref, tokens),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── SECTION 2: TRAINING PREFERENCES ─────────────────────────────
          _SettingsSection(
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
                              ref.read(hapticsEnabledProvider.notifier).toggle(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    // Dark/Light theme switch
                    Padding(
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
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
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
                                  'MONOLITHIC DARK THEME',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark ? 'High-contrast titanium canvas' : 'Light mode canvas',
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
                                  .setTheme(val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Exercise Catalog',
                      subtitle: 'Browse 50+ movement techniques, tips & targeted muscles',
                      icon: Icons.fitness_center_rounded,
                      tokens: tokens,
                      onTap: () => context.go(AppRoutes.workoutCatalog),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Workout History',
                      subtitle: 'Historical session logs, volume curves & completed routines',
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
          _SettingsSection(
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
                    _SettingsTile(
                      title: 'Export Workout & Nutrition Data',
                      subtitle: 'Generate CSV / JSON archives for workouts, nutrition & backup',
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
                      title: 'Restore System Data',
                      subtitle: 'Pre-validate backup archives with safe preview before restore',
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
          _SettingsSection(
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
                    _SettingsTile(
                      title: 'Scheduled Reminders',
                      subtitle: 'Configure daily training time, meal notifications & rest alerts',
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
          _SettingsSection(
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
                              ref.read(aiPersonalizationConsentProvider.notifier).setConsent(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Privacy & Data Controls',
                      subtitle: 'Manage anonymous metrics, crash reports & danger zone',
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
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Terms of Service',
                      subtitle: 'Review operating agreement & health disclaimer',
                      icon: Icons.description_outlined,
                      tokens: tokens,
                      onTap: () => _showDocumentDialog(
                        context,
                        title: 'TERMS OF SERVICE',
                        tokens: tokens,
                        content: '''By using IronFlow, you agree to the following terms:

1. ACCEPTANCE OF TERMS
By downloading, installing, or using IronFlow, you agree to be bound by these Terms of Service.

2. HEALTH DISCLAIMER
IronFlow is NOT a medical device and does NOT provide medical advice. Always consult with a healthcare professional before starting any fitness or nutrition program.

3. USER RESPONSIBILITIES
- You are responsible for assessing your fitness level
- Use proper form and technique during exercises
- Listen to your body and stop if you feel pain
- Ensure a safe workout environment

4. AI COACH LIMITATIONS
Our AI-powered fitness coach provides general guidance only and should not replace professional coaching or medical advice.

5. DATA AND PRIVACY
- We do NOT sell your personal data
- Your workout data is stored securely
- You can export or delete your data anytime
- We use encryption to protect your information

6. ACCEPTABLE USE
You agree to use the app for lawful purposes only and not to violate laws or compromise system security.

Last Updated: October 2026''',
                      ),
                    ),
                    Divider(color: tokens.borderSubtle, height: 1),
                    _SettingsTile(
                      title: 'Privacy Policy',
                      subtitle: 'Information handling, offline data storage & rights',
                      icon: Icons.shield_outlined,
                      tokens: tokens,
                      onTap: () => _showDocumentDialog(
                        context,
                        title: 'PRIVACY POLICY',
                        tokens: tokens,
                        content: '''IronFlow Privacy Policy

INFORMATION WE COLLECT
- Account info: Email, name
- Profile data: Age, gender, fitness goals
- Usage data: Workouts, nutrition logs, body progress

HOW WE USE YOUR DATA
- Provide and maintain the app
- Store your workout and nutrition data
- Provide AI-powered coaching
- Keep data private on your device

DATA STORAGE & SECURITY
- Local storage on your device (Hive)
- Encrypted in transit and at rest
- We NEVER sell your data to third parties

YOUR RIGHTS
- Access, view and export your data anytime
- Delete your account and records at will
- Full offline functionality without cloud requirement

Last Updated: October 2026''',
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
            _SettingsSection(
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
                      _SettingsTile(
                        title: 'Reset Onboarding Protocol',
                        subtitle: 'Clear onboarding flag and re-run goal selection stepper',
                        icon: Icons.restart_alt_rounded,
                        tokens: tokens,
                        iconColor: tokens.warning,
                        titleColor: tokens.warning,
                        onTap: () => _resetOnboarding(context, ref, tokens),
                      ),
                      Divider(color: tokens.borderSubtle, height: 1),
                      _SettingsTile(
                        title: 'Inspect App State Telemetry',
                        subtitle: 'Inspect live Auth, Onboarding & Gemini API configuration',
                        icon: Icons.monitor_heart_outlined,
                        tokens: tokens,
                        onTap: () => _showStateInspector(context, ref, tokens),
                      ),
                      Divider(color: tokens.borderSubtle, height: 1),
                      _SettingsTile(
                        title: 'AI Diagnostic Test',
                        subtitle: 'Test Gemini inference and mock responses',
                        icon: Icons.bug_report_outlined,
                        tokens: tokens,
                        onTap: () => context.push(AppRoutes.aiTest),
                      ),
                      Divider(color: tokens.borderSubtle, height: 1),
                      _SettingsTile(
                        title: 'Design System Gallery',
                        subtitle: 'Inspect titanium design system tokens and widgets',
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
          _SettingsSection(
            title: 'CORE APPLICATION SYSTEM',
            tokens: tokens,
            children: [
              GestureDetector(
                onLongPress: () => _showStateInspector(context, ref, tokens),
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
                      value: '1.1.0+2',
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
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.tokens,
    this.iconColor,
    this.titleColor,
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
                color: iconColor ?? tokens.kineticAccent,
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
                      color: titleColor ?? tokens.textPrimary,
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
