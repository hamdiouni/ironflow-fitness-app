import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Direction 4 Soft & Layered offline-first local & interactive showcase access.
///
/// Allows users to use IronFlow 100% offline with local AES-256 encrypted Hive
/// storage without requiring cloud credentials, or explore a pre-seeded demo.
class OfflineAccessSection extends ConsumerStatefulWidget {
  const OfflineAccessSection({
    super.key,
    required this.postAuthRouteResolver,
  });

  final String Function() postAuthRouteResolver;

  @override
  ConsumerState<OfflineAccessSection> createState() =>
      _OfflineAccessSectionState();
}

class _OfflineAccessSectionState extends ConsumerState<OfflineAccessSection> {
  bool _isEnteringOffline = false;
  bool _isEnteringDemo = false;

  Future<void> _enterLocalGuest() async {
    if (_isEnteringOffline || _isEnteringDemo) return;
    setState(() => _isEnteringOffline = true);
    AppHaptics.shared.buttonPress();
    try {
      await ref.read(authNotifierProvider.notifier).signInAsLocalGuest();
      ref.invalidate(isOnboardedProvider);
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      final isOnboarded = await ref.read(isOnboardedProvider.future);
      if (!mounted) return;
      if (isOnboarded) {
        context.go(widget.postAuthRouteResolver());
      } else {
        context.go(AppRoutes.onboarding);
      }
    } finally {
      if (mounted) {
        setState(() => _isEnteringOffline = false);
      }
    }
  }

  Future<void> _enterDemoShowcase() async {
    if (_isEnteringOffline || _isEnteringDemo) return;
    setState(() => _isEnteringDemo = true);
    AppHaptics.shared.buttonPress();
    try {
      await ref.read(authNotifierProvider.notifier).signInAsDemoShowcase();
      ref.invalidate(isOnboardedProvider);
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      context.go(widget.postAuthRouteResolver());
    } finally {
      if (mounted) {
        setState(() => _isEnteringDemo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final authState = ref.watch(authNotifierProvider);
    final busy = authState.isLoading || _isEnteringOffline || _isEnteringDemo;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_moon_outlined,
                size: 16,
                color: tokens.cyanAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'OFFLINE-FIRST LOCAL ACCESS',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: tokens.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.cyanAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                ),
                child: Text(
                  'AES-256 Local',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: tokens.cyanAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Use IronFlow completely on-device without a cloud account, or launch the populated showcase.',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 11.5,
              height: 1.35,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Continue Offline (Local Mode)',
            variant: AppButtonVariant.secondary,
            isLoading: _isEnteringOffline,
            isFullWidth: true,
            icon: Icon(
              Icons.offline_bolt_rounded,
              size: 18,
              color: tokens.cyanAccent,
            ),
            onPressed: busy ? null : _enterLocalGuest,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Explore Live Demo (Sample Data)',
            variant: AppButtonVariant.ghost,
            isLoading: _isEnteringDemo,
            isFullWidth: true,
            icon: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: tokens.kineticAccent,
            ),
            onPressed: busy ? null : _enterDemoShowcase,
          ),
        ],
      ),
    );
  }
}

