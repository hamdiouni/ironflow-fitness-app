import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../ai/data/datasources/gemini_ai_service.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../onboarding/data/user_profile_storage.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import 'settings_section_tiles.dart';

const String kIronFlowTermsOfService = '''By using Progression Tracker, you agree to the following terms:

1. ACCEPTANCE OF TERMS
By downloading, installing, or using Progression Tracker, you agree to be bound by these Terms of Service.

2. HEALTH DISCLAIMER
Progression Tracker is NOT a medical device and does NOT provide medical advice. Always consult with a healthcare professional before starting any fitness or nutrition program.

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

Last Updated: October 2026''';

const String kIronFlowPrivacyPolicy = '''Progression Tracker Privacy Policy

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

Last Updated: October 2026''';

void showSettingsLogoutDialog(
  BuildContext context,
  WidgetRef ref,
  AppThemeTokens tokens,
) {
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
                  final rootNavigator =
                      Navigator.of(context, rootNavigator: true);
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
                            'Signing out...',
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
                          'Logout is taking longer than expected. Redirecting...',
                        ),
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

void showSettingsDocumentDialog(
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

Future<void> resetSettingsOnboarding(
  BuildContext context,
  WidgetRef ref,
  AppThemeTokens tokens,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      title: Text(
        'RESET ONBOARDING',
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
            foregroundColor: tokens.onAccent,
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
          content: Text(
            'Onboarding reset! Redirecting to setup...',
            style: TextStyle(color: tokens.onAccent),
          ),
          backgroundColor: tokens.kineticAccent,
        ),
      );
      context.go(AppRoutes.onboarding);
    }
  }
}

void showSettingsStateInspector(
  BuildContext context,
  WidgetRef ref,
  AppThemeTokens tokens,
) {
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
          Icon(
            Icons.monitor_heart_outlined,
            color: tokens.kineticAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'APP STATE INSPECTOR',
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
          SettingItem(
            label: 'AUTH STATUS',
            value: authState.isAuthenticated ? 'AUTHENTICATED' : 'ANONYMOUS',
            tokens: tokens,
          ),
          const SizedBox(height: 8),
          SettingItem(
            label: 'USER ID',
            value: (authState.user != null && authState.user!.id.isNotEmpty)
                ? authState.user!.id.substring(
                    0,
                    authState.user!.id.length > 12
                        ? 12
                        : authState.user!.id.length,
                  )
                : 'NONE',
            tokens: tokens,
          ),
          const SizedBox(height: 8),
          SettingItem(
            label: 'ONBOARDING STATUS',
            value: isOnboarded ? 'COMPLETED' : 'PENDING',
            tokens: tokens,
          ),
          const SizedBox(height: 8),
          SettingItem(
            label: 'AI ROUTE',
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

