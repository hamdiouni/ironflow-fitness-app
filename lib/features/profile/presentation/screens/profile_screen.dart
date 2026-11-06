import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_entry_button.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/contextual_insight_banner.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/profile/presentation/providers/profile_data_provider.dart';
import '../widgets/profile_account_section.dart';
import '../widgets/profile_header_and_stats.dart';
import '../widgets/profile_plan_cards.dart';

/// Stripe Profile & Settings screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final profileAsync = ref.watch(userProfileProvider);

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
              'PROFILE',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'PROFILE & WORKOUT PLAN',
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
        actions: [
          const AiEntryButton(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: profileAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: tokens.kineticAccent),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error loading profile telemetry: $error',
              style: TextStyle(color: tokens.error),
            ),
          ),
          data: (profile) => profile == null
              ? _NoProfileView(tokens: tokens)
              : _ProfileBody(profile: profile, tokens: tokens),
        ),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView({required this.tokens});
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Icon(Icons.person_outline, size: 48, color: tokens.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'NO PROFILE FOUND',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Set up your body stats to personalize your workout and nutrition plans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'START SETUP',
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              onPressed: () => context.go(AppRoutes.onboarding),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.tokens});
  final UserProfile profile;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Everything below is derived from this user's real records
    // (account, body entries, workouts, active program, saved diet
    // plan/targets, today's meals) — see profile_data_provider.dart.
    // Nothing is regenerated or hardcoded per build anymore.
    final data = ref.watch(profileDataProvider) ??
        buildProfileData(profile: profile);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: ProfileHeader(data: data, tokens: tokens)),
        SliverToBoxAdapter(child: ProfileStatsRow(data: data, tokens: tokens)),
        SliverToBoxAdapter(child: ProfileActivityRow(data: data, tokens: tokens)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ContextualInsightBanner(context: InsightContext.profile),
          ),
        ),
        SliverToBoxAdapter(
          child: ProfileGoalCard(data: data, tokens: tokens),
        ),
        SliverToBoxAdapter(
          child: ProfileDietPlanCard(data: data, tokens: tokens),
        ),
        SliverToBoxAdapter(
          child: ProfileAccountSection(ref: ref, tokens: tokens),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
