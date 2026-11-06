import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';

// ── Settings Section ──────────────────────────────────────────────────────────

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({super.key, required this.ref, required this.tokens});
  final WidgetRef ref;
  final AppThemeTokens tokens;

  void _showLogoutDialog(BuildContext context) {
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
          'Are you sure you want to log out? Your workouts, nutrition, and stats are saved on your device.',
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT & PREFERENCES',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Body Stats & Goals',
                  onTap: () => context.go(AppRoutes.onboarding),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.calculate_outlined,
                  label: 'Fitness Calculators & Tools',
                  onTap: () => context.push(AppRoutes.tools),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  label: 'System Preferences & Data',
                  onTap: () => context.push(AppRoutes.settings),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: tokens.error,
                    size: 20,
                  ),
                  title: Text(
                    'LOG OUT',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: tokens.error,
                    size: 14,
                  ),
                  onTap: () => _showLogoutDialog(context),
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: tokens.kineticAccent, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          color: tokens.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: tokens.textMuted,
        size: 13,
      ),
      onTap: onTap,
      dense: true,
    );
  }
}

