import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_theme.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../../shared/presentation/components/app_card.dart';
import '../../../../../shared/widgets/weight_trend_graph.dart';
import '../../../../ai/domain/entities/insight.dart';
import '../../../../ai/presentation/providers/global_ai_provider.dart';
import '../../../../ai/presentation/widgets/contextual_insight_banner.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../domain/entities/body_entry.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../../domain/usecases/save_body_entry_use_case.dart';
import '../../providers/body_providers.dart';

class BodyWeightTab extends ConsumerWidget {
  const BodyWeightTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final trendAsync = ref.watch(weightTrendProvider);
    final historyAsync = ref.watch(bodyHistoryProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contextual AI Banner
          const ContextualInsightBanner(context: InsightContext.workout),
          const SizedBox(height: 14),

          // Graph card
          AppCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WEIGHT TREND',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.elevated,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                      ),
                      child: Text(
                        'LAST 30 DAYS',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                trendAsync.when(
                  data: (points) => WeightTrendGraph(
                    dataPoints: points,
                    targetWeight: profileAsync.value?.targetWeightKg,
                  ).animate().fadeIn(duration: 400.ms),
                  loading: () => SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: tokens.kineticAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (e, _) => SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'Failed to load weight data: $e',
                        style: TextStyle(color: tokens.error, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent entries list
          trendAsync.when(
            data: (points) {
              if (points.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No weight entries logged yet.\nTap "LOG WEIGHT" to start calibration.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 13,
                        fontFamily: AppTypography.bodyFontFamily,
                      ),
                    ),
                  ),
                );
              }
              final recent = points.reversed.take(5).toList();
              return AppCard(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECENT LOGS',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recent
                        .map((p) => _WeightEntryRow(point: p, tokens: tokens)),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),
          AppButton(
            label: 'LOG WEIGHT',
            icon: const Icon(Icons.add_rounded, size: 18),
            isFullWidth: true,
            onPressed: () => _showLogWeightDialog(context, ref),
          ),
          const SizedBox(height: 24),

          // Measurements telemetry
          historyAsync.when(
            data: (entries) {
              final withMeasurements =
                  entries.where((e) => e.measurements.isNotEmpty).toList();

              if (withMeasurements.isEmpty) {
                return AppCard(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Center(
                    child: Text(
                      'No body measurements logged yet.\nCalibrate your dimensions below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 13,
                        fontFamily: AppTypography.bodyFontFamily,
                      ),
                    ),
                  ),
                );
              }

              final latest = withMeasurements.first;
              return AppCard(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LATEST TELEMETRY',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: tokens.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(latest.date),
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...MeasurementType.values.map((type) {
                      final value = latest.measurements[type];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.card,
                          borderRadius:
                              BorderRadius.circular(tokens.radiusPill),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _label(type).toUpperCase(),
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: tokens.textMuted,
                              ),
                            ),
                            Text(
                              value != null
                                  ? '${value.toStringAsFixed(1)} CM'
                                  : '—',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: value != null
                                    ? tokens.kineticAccent
                                    : tokens.textMuted,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                color: tokens.kineticAccent,
                strokeWidth: 2,
              ),
            ),
            error: (e, _) => Text(
              'Failed to load measurements',
              style: TextStyle(color: tokens.error),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'LOG MEASUREMENTS',
            variant: AppButtonVariant.secondary,
            icon: const Icon(Icons.straighten_rounded, size: 18),
            isFullWidth: true,
            onPressed: () => _showLogMeasurementsForm(context, ref),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _label(MeasurementType type) => switch (type) {
        MeasurementType.chest => 'Chest',
        MeasurementType.waist => 'Waist',
        MeasurementType.hips => 'Hips',
        MeasurementType.arms => 'Arms',
        MeasurementType.legs => 'Legs',
      };

  Future<void> _showLogWeightDialog(BuildContext context, WidgetRef ref) async {
    final tokens = AppThemeTokens.of(context);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          'LOG WEIGHT',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    color: tokens.textMuted,
                  ),
                  hintText: 'e.g. 75.5',
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14,
                    color: tokens.textMuted.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: tokens.card,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    borderSide:
                        BorderSide(color: tokens.borderSubtle, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    borderSide:
                        BorderSide(color: tokens.borderSubtle, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    borderSide:
                        BorderSide(color: tokens.kineticAccent, width: 1.5),
                  ),
                ),
                validator: (v) {
                  final parsed = double.tryParse(v?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid positive weight';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontWeight: FontWeight.w700,
                color: tokens.textMuted,
              ),
            ),
          ),
          AppButton(
            label: 'SAVE',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final weight = double.parse(controller.text.trim());
        final entry = BodyEntry.create(weight: weight);
        final repository = ref.read(bodyRepositoryProvider);
        final useCase = SaveBodyEntryUseCase(repository);
        await useCase(entry);

        try {
          final storage = ref.read(userProfileStorageProvider);
          final profile = await storage.loadProfile();
          if (profile != null && profile.weightKg != weight) {
            await storage.saveProfile(profile.copyWith(weightKg: weight));
            ref.invalidate(userProfileProvider);
          }
        } catch (_) {}

        try {
          ref.read(globalAIProvider.notifier).onBodyWeightRecorded();
        } catch (_) {}

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Weight ${weight.toStringAsFixed(1)}kg logged!'),
              backgroundColor: tokens.panel,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e, stack) {
        if (context.mounted) {
          ErrorHandler.handleError(context, e, stack);
        }
      } finally {
        controller.dispose();
      }
    } else {
      controller.dispose();
    }
  }

  Future<void> _showLogMeasurementsForm(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final tokens = AppThemeTokens.of(context);
    final controllers = {
      for (final type in MeasurementType.values)
        type: TextEditingController(),
    };
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          'LOG MEASUREMENTS',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MeasurementType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: controllers[type],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 14,
                      color: tokens.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      labelText: '${_label(type)} (cm)',
                      labelStyle: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12,
                        color: tokens.textMuted,
                      ),
                      filled: true,
                      fillColor: tokens.card,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        borderSide:
                            BorderSide(color: tokens.borderSubtle, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        borderSide:
                            BorderSide(color: tokens.borderSubtle, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        borderSide:
                            BorderSide(color: tokens.kineticAccent, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final parsed = double.tryParse(v);
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid positive value';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontWeight: FontWeight.w700,
                color: tokens.textMuted,
              ),
            ),
          ),
          AppButton(
            label: 'SAVE',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final measurements = <MeasurementType, double>{};
        for (final type in MeasurementType.values) {
          final text = controllers[type]!.text.trim();
          if (text.isNotEmpty) {
            final value = double.tryParse(text);
            if (value != null && value > 0) measurements[type] = value;
          }
        }

        final history = ref.read(bodyHistoryProvider).valueOrNull;
        final lastWeight =
            history?.isNotEmpty == true ? history!.first.weight : 1.0;

        final entry = BodyEntry.create(
          weight: lastWeight,
          measurements: measurements,
        );
        final repository = ref.read(bodyRepositoryProvider);
        final useCase = SaveBodyEntryUseCase(repository);
        await useCase(entry);
      } catch (e, stack) {
        if (context.mounted) ErrorHandler.handleError(context, e, stack);
      } finally {
        for (final c in controllers.values) {
          c.dispose();
        }
      }
    } else {
      for (final c in controllers.values) {
        c.dispose();
      }
    }
  }
}

class _WeightEntryRow extends StatelessWidget {
  const _WeightEntryRow({required this.point, required this.tokens});
  final dynamic point;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.kineticAccent,
              boxShadow: [
                BoxShadow(
                  color: tokens.kineticAccent.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            DateFormat('MMM d, yyyy').format(point.date as DateTime),
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13,
              color: tokens.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '${(point.weight as double).toStringAsFixed(1)} kg',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

