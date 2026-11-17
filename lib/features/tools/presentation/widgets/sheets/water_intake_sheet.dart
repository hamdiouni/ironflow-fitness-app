import 'package:flutter/material.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../core/providers/units_provider.dart';
import '../../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../domain/calculators/water_intake_calculator.dart';

class WaterIntakeSheet extends StatefulWidget {
  final UserProfile? profile;
  final UnitsSystem units;

  const WaterIntakeSheet({
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
      title: 'DAILY WATER INTAKE',
      child: WaterIntakeSheet(profile: profile, units: units),
    );
  }

  @override
  State<WaterIntakeSheet> createState() => _WaterIntakeSheetState();
}

class _WaterIntakeSheetState extends State<WaterIntakeSheet> {
  late double _weight;
  int _workoutMins = 45;
  bool _isHotClimate = false;

  @override
  void initState() {
    super.initState();
    _weight = widget.profile?.weightKg ?? UserProfileDefaults.weightKg;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final weightUnit = UnitsConverter.getWeightUnit(widget.units);
    final displayWeight =
        UnitsConverter.convertWeightToDisplay(_weight, widget.units);
    final result = WaterIntakeCalculator.calculate(
      weightKg: _weight,
      workoutMinutes: _workoutMins,
      isHotClimate: _isHotClimate,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: displayWeight.toStringAsFixed(1),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'BODY WEIGHT',
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
                final kg =
                    UnitsConverter.convertWeightToStorage(d, widget.units);
                if (kg > 20) setState(() => _weight = kg);
              }
            },
          ),
          const SizedBox(height: 12),

          // Workout minutes slider
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
                      'DAILY WORKOUT DURATION',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tokens.textMuted,
                      ),
                    ),
                    Text(
                      '$_workoutMins min',
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
                  value: _workoutMins.toDouble(),
                  min: 0,
                  max: 120,
                  divisions: 8,
                  activeColor: tokens.kineticAccent,
                  onChanged: (v) => setState(() => _workoutMins = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Hot climate switch
          SwitchListTile(
            value: _isHotClimate,
            activeThumbColor: tokens.kineticAccent,
            activeTrackColor: tokens.kineticAccent.withValues(alpha: 0.5),
            title: Text(
              'Hot / Humid Climate',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textPrimary,
              ),
            ),
            subtitle: Text(
              '+500 ml for elevated perspiration',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 11,
                color: tokens.textMuted,
              ),
            ),
            onChanged: (v) => setState(() => _isHotClimate = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // Result display
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
                  'DAILY HYDRATION TARGET',
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
                  '${result.totalLiters.toStringAsFixed(1)} LITERS',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: tokens.kineticAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '~${result.glasses} standard glasses (250 ml)',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Baseline: ${(result.baselineMl / 1000).toStringAsFixed(1)} L • Workout Sweat: ${(result.workoutBonusMl / 1000).toStringAsFixed(1)} L',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
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

