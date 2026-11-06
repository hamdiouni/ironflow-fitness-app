import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/profile/presentation/providers/profile_data_provider.dart';

// ── Profile Header ────────────────────────────────────────────────────────────

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
    final photoUrl = data.accountUser?.photoUrl?.trim();
    final memberSince = data.accountUser?.createdAt;
    final memberSinceLabel =
        memberSince == null ? '' : ' · SINCE ${memberSince.year}';
    final protocolLabel = data.activeProgram != null
        ? 'DAY ${data.activeProgram!.currentDayIndex + 1} · '
            '${data.activeProgram!.program.daysPerWeek}X / WEEK'
        : '${profile.workoutDaysPerWeek} DAYS / WEEK TARGET';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            // Stripe Avatar Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Center(
                child: (photoUrl != null && photoUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        child: Image.network(
                          photoUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            data.initials,
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              color: tokens.kineticAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        data.initials,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.kineticAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.displayName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (data.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        color: tokens.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${profile.goal.emoji} ${profile.goal.displayName.toUpperCase()} · '
                    '${profile.fitnessLevel.displayName.toUpperCase()} · '
                    '${profile.equipment.displayName.toUpperCase()}'
                    '$memberSinceLabel',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: tokens.kineticAccent.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      protocolLabel,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        color: tokens.kineticAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'AGE',
              value: '${profile.age}',
              unit: 'YRS',
              color: tokens.cyanAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'WEIGHT',
              // Latest logged body entry, not the frozen onboarding
              // weight (which is only the pre-logging fallback).
              value: data.currentWeightKg.toStringAsFixed(1),
              unit: data.latestBodyEntry == null ? 'KG' : 'KG · LATEST',
              color: tokens.kineticAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'HEIGHT',
              value: profile.heightCm.toStringAsFixed(0),
              unit: 'CM',
              color: tokens.violetAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'BMI',
              value: data.bmi.toStringAsFixed(1),
              unit: 'INDEX',
              color: _bmiColor(data.bmi),
              tokens: tokens,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms);
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return tokens.cyanAccent;
    if (bmi < 25) return tokens.kineticAccent;
    if (bmi < 30) return tokens.warning;
    return tokens.error;
  }
}

/// Real training totals for this user, computed from their workout
/// history (see [buildProfileData]) — replaces any stored/global
/// counters on this screen.
class ProfileActivityRow extends StatelessWidget {
  const ProfileActivityRow({super.key, required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  String _volumeLabel(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}k';
    return kg.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'WORKOUTS',
              value: '${data.totalWorkouts}',
              unit: 'TOTAL',
              color: tokens.kineticAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'THIS WEEK',
              value: '${data.workoutsThisWeek}',
              unit: 'SESSIONS',
              color: tokens.cyanAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'STREAK',
              value: '${data.currentStreakDays}',
              unit: 'DAYS',
              color: tokens.violetAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'VOLUME',
              value: _volumeLabel(data.totalVolumeKg),
              unit: 'KG LIFTED',
              color: tokens.warning,
              tokens: tokens,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 110.ms);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.tokens,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
