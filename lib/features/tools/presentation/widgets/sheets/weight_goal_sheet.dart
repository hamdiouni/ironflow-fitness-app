import 'package:flutter/material.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../core/providers/units_provider.dart';
import '../../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../domain/calculators/weight_goal_planner.dart';

class WeightGoalSheet extends StatefulWidget {
  final UserProfile? profile;
  final UnitsSystem units;

  const WeightGoalSheet({
    super.key,
    this.profile,
    this.units = UnitsSystem.metric,
  });

  static Future<void> show(
    BuildContext context, {
    UserProfile? profile,
    UnitsSystem units = UnitsSystem.metric,
  }) {
    return AppBottomSheet.show(
      context: context,
      title: 'WEIGHT GOAL PLANNER',
      child: WeightGoalSheet(profile: profile, units: units),
    );
  }

  @override
  State<WeightGoalSheet> createState() => _WeightGoalSheetState();
}

class _WeightGoalSheetState extends State<WeightGoalSheet> {
  late double _current;
  late double _target;
  double _weeklyRate = WeightGoalPlanner.defaultWeeklyRateKg;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _current = p?.weightKg ?? UserProfileDefaults.weightKg;
    _target = p?.effectiveTargetWeightKg ??
        (_current - UserProfileDefaults.targetWeightDeltaKg);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final weightUnit = UnitsConverter.getWeightUnit(widget.units);
    final weightScale = UnitsConverter.convertWeightToDisplay(1.0, widget.units);
    final displayCurrent =
        UnitsConverter.convertWeightToDisplay(_current, widget.units);
    final displayTarget =
        UnitsConverter.convertWeightToDisplay(_target, widget.units);
    final displayRate =
        UnitsConverter.convertWeightToDisplay(_weeklyRate, widget.units);
    final result = WeightGoalPlanner.plan(
      currentWeightKg: _current,
      targetWeightKg: _target,
      weeklyRateKg: _weeklyRate,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: displayCurrent.toStringAsFixed(1),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'CURRENT WEIGHT',
                    suffixText: weightUnit,
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null) {
                      final kg = UnitsConverter.convertWeightToStorage(
                          d, widget.units);
                      if (kg > 20) setState(() => _current = kg);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: displayTarget.toStringAsFixed(1),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'TARGET WEIGHT',
                    suffixText: weightUnit,
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null) {
                      final kg = UnitsConverter.convertWeightToStorage(
                          d, widget.units);
                      if (kg > 20) setState(() => _target = kg);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekly Rate Slider
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PACE / WEEK',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tokens.textMuted,
                      ),
                    ),
                    Text(
                      '${displayRate.toStringAsFixed(2)} $weightUnit / week',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tokens.kineticAccent,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _weeklyRate,
                  min: 0.25,
                  max: 1.0,
                  divisions: 3,
                  activeColor: tokens.kineticAccent,
                  onChanged: (v) => setState(() => _weeklyRate = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timeline highlight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(
                color: tokens.kineticAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMATED COMPLETION',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: tokens.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '~${result.estimatedWeeks.toStringAsFixed(1)} WEEKS',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: tokens.kineticAccent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.formatSummary(
                    weightUnit: weightUnit,
                    weightScale: weightScale,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'DONE',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

