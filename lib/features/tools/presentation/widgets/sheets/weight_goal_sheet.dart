import 'package:flutter/material.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../domain/calculators/weight_goal_planner.dart';

class WeightGoalSheet extends StatefulWidget {
  final UserProfile? profile;

  const WeightGoalSheet({super.key, this.profile});

  static Future<void> show(BuildContext context, {UserProfile? profile}) {
    return AppBottomSheet.show(
      context: context,
      title: 'WEIGHT GOAL PLANNER',
      child: WeightGoalSheet(profile: profile),
    );
  }

  @override
  State<WeightGoalSheet> createState() => _WeightGoalSheetState();
}

class _WeightGoalSheetState extends State<WeightGoalSheet> {
  late double _current;
  late double _target;
  double _weeklyRate = 0.5;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _current = p?.weightKg ?? 80.0;
    _target = p?.effectiveTargetWeightKg ?? (_current - 5.0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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
                  initialValue: _current.toStringAsFixed(1),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'CURRENT WEIGHT',
                    suffixText: 'kg',
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null && d > 20) setState(() => _current = d);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _target.toStringAsFixed(1),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'TARGET WEIGHT',
                    suffixText: 'kg',
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null && d > 20) setState(() => _target = d);
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
                      '${_weeklyRate.toStringAsFixed(2)} kg / week',
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
                  result.plainEnglishSummary,
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

