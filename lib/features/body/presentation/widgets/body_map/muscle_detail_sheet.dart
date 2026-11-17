import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_recovery_status.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/shared/presentation/components/medical_disclaimer_banner.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Interactive bottom sheet showing recovery diagnostics, training history,
/// and "Train This" action for a selected muscle region (Wave 4).
class MuscleDetailSheet extends ConsumerWidget {
  const MuscleDetailSheet({
    super.key,
    required this.recoveryData,
    required this.onToggleSoreness,
  });

  final MuscleRecoveryData recoveryData;
  final ValueChanged<bool> onToggleSoreness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final region = recoveryData.region;
    final units = ref.watch(unitsProvider);
    final displayVolume = UnitsConverter.convertWeightToDisplay(
      recoveryData.volumeLoad7Days,
      units,
    );
    final weightUnit = UnitsConverter.getWeightUnit(units);

    // Exercises targeting this muscle region
    final targetingExercises = ExerciseCatalog.all
        .where((e) =>
            e.primaryRegions.contains(region.id) ||
            e.secondaryRegions.contains(region.id))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: tokens.canvas,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
        border: Border(top: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.borderSubtle,
                borderRadius: BorderRadius.circular(tokens.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Muscle Name & Recovery Tier Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.displayName,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: tokens.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      region.anatomicalName,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12.5,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTierBadge(context, recoveryData.tier, tokens),
            ],
          ),
          const SizedBox(height: 16),

          // Recovery Metric Card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildRecoveryMeter(context, recoveryData.score, tokens),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECOVERY ESTIMATE',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: tokens.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _recoveryTitle(recoveryData.tier, recoveryData.score),
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _recoverySubtitle(recoveryData),
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          color: tokens.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 7-Day History Summary
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  title: '7D SETS',
                  value: '${recoveryData.sets7Days}',
                  unit: 'sets',
                  tokens: tokens,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatCard(
                  title: '7D VOLUME',
                  value: recoveryData.volumeLoad7Days > 0
                      ? '${displayVolume.toInt()}'
                      : '0',
                  unit: weightUnit,
                  tokens: tokens,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatCard(
                  title: 'LAST TRAINED',
                  value: _formatLastTrained(recoveryData.hoursSinceTrained),
                  unit: '',
                  tokens: tokens,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Manual DOMS Soreness Toggle
          InkWell(
            onTap: () {
              AppHaptics.shared.selectionChanged();
              onToggleSoreness(!recoveryData.isManuallyMarkedSore);
            },
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: recoveryData.isManuallyMarkedSore
                    ? const Color(0xFFA855F7).withValues(alpha: 0.12)
                    : tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: recoveryData.isManuallyMarkedSore
                      ? const Color(0xFFA855F7).withValues(alpha: 0.4)
                      : tokens.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    recoveryData.isManuallyMarkedSore
                        ? Icons.healing_rounded
                        : Icons.healing_outlined,
                    size: 18,
                    color: recoveryData.isManuallyMarkedSore
                        ? const Color(0xFFA855F7)
                        : tokens.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mark as Sore (DOMS)',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: recoveryData.isManuallyMarkedSore
                            ? const Color(0xFFA855F7)
                            : tokens.textPrimary,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: recoveryData.isManuallyMarkedSore,
                    activeTrackColor: const Color(0xFFA855F7),
                    onChanged: (val) {
                      AppHaptics.shared.selectionChanged();
                      onToggleSoreness(val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action CTA: "Train This Muscle"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                AppHaptics.shared.selectionChanged();
                final targetUrl =
                    '${AppRoutes.workoutCatalog}?muscle=${Uri.encodeComponent(region.coarseGroup.name)}';
                Navigator.of(context).pop();
                context.go(targetUrl);
              },
              icon: const Icon(Icons.fitness_center_rounded, size: 18),
              label: Text(
                'TRAIN THIS MUSCLE (${targetingExercises.length} EXERCISES)',
                style: const TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.kineticAccent,
                foregroundColor: tokens.onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Medical & Fitness Disclaimer (Wave 6.2 — LEG-03)
          const MedicalDisclaimerBanner(
            compact: true,
            customText: 'Recovery calculations are mathematical estimates based on volume, not clinical diagnostics.',
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(
    BuildContext context,
    RecoveryTier tier,
    AppThemeTokens tokens,
  ) {
    final (color, label) = switch (tier) {
      RecoveryTier.fresh => (const Color(0xFF10B981), 'FRESH'),
      RecoveryTier.recovering => (const Color(0xFFF59E0B), 'RECOVERING'),
      RecoveryTier.fatigued => (const Color(0xFFEF4444), 'NEEDS REST'),
      RecoveryTier.sore => (const Color(0xFFA855F7), 'SORE'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildRecoveryMeter(
    BuildContext context,
    double score,
    AppThemeTokens tokens,
  ) {
    final pct = (score * 100).toInt();
    final color = score >= 0.90
        ? const Color(0xFF10B981)
        : score >= 0.50
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            value: score.clamp(0.0, 1.0),
            strokeWidth: 6,
            backgroundColor: tokens.elevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '$pct%',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required String unit,
    required AppThemeTokens tokens,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: tokens.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 10,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _recoveryTitle(RecoveryTier tier, double score) {
    return switch (tier) {
      RecoveryTier.fresh => 'Ready for Maximum Load',
      RecoveryTier.recovering => 'Recovering Tissue',
      RecoveryTier.fatigued => 'Acute Fatigue — Rest Advised',
      RecoveryTier.sore => 'Soreness Flagged',
    };
  }

  String _recoverySubtitle(MuscleRecoveryData data) {
    if (data.isManuallyMarkedSore) {
      return 'DOMS flagged manually. Light active recovery or rest recommended.';
    }
    if (data.tier == RecoveryTier.fresh) {
      return 'Estimated recovery complete. Primed for progressive overload.';
    }
    final hrs = data.estimatedHoursRemaining;
    return 'Estimated $hrs hours until full baseline recovery.';
  }

  String _formatLastTrained(double? hours) {
    if (hours == null) return 'Never';
    if (hours < 1.0) return '<1h ago';
    if (hours < 24.0) return '${hours.round()}h ago';
    final days = (hours / 24.0).floor();
    return '${days}d ago';
  }
}
