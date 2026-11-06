import 'package:flutter/material.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../domain/calculators/calorie_macro_calculator.dart';

class CalorieMacroSheet extends StatefulWidget {
  final UserProfile? profile;

  const CalorieMacroSheet({super.key, this.profile});

  static Future<void> show(BuildContext context, {UserProfile? profile}) {
    return AppBottomSheet.show(
      context: context,
      title: 'CALORIE & MACRO CALCULATOR',
      child: CalorieMacroSheet(profile: profile),
    );
  }

  @override
  State<CalorieMacroSheet> createState() => _CalorieMacroSheetState();
}

class _CalorieMacroSheetState extends State<CalorieMacroSheet> {
  late double _weight;
  late double _height;
  late int _age;
  late BiologicalSex _sex;
  late ActivityLevel _activity;
  late FitnessGoal _goal;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _weight = p?.weightKg ?? 75.0;
    _height = p?.heightCm ?? 175.0;
    _age = p?.age ?? 26;
    _sex = p?.sex ?? BiologicalSex.male;
    _goal = p?.goal ?? FitnessGoal.maintain;
    _activity = switch (p?.workoutDaysPerWeek ?? 3) {
      <= 2 => ActivityLevel.light,
      <= 4 => ActivityLevel.moderate,
      _ => ActivityLevel.heavy,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final result = CalorieMacroCalculator.calculate(
      weightKg: _weight,
      heightCm: _height,
      age: _age,
      sex: _sex,
      activityLevel: _activity,
      goal: _goal,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Inputs Row
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  label: 'WEIGHT',
                  value: _weight.toStringAsFixed(1),
                  unit: 'kg',
                  tokens: tokens,
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null && d > 20) setState(() => _weight = d);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberInput(
                  label: 'HEIGHT',
                  value: _height.toStringAsFixed(0),
                  unit: 'cm',
                  tokens: tokens,
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null && d > 50) setState(() => _height = d);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberInput(
                  label: 'AGE',
                  value: '$_age',
                  unit: 'y',
                  tokens: tokens,
                  onChanged: (v) {
                    final i = int.tryParse(v);
                    if (i != null && i > 10) setState(() => _age = i);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Goal Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Row(
              children: FitnessGoal.values.map((g) {
                final isSelected = g == _goal;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _goal = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? tokens.kineticAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(tokens.radiusSm - 2),
                      ),
                      child: Text(
                        g.displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.black : tokens.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Calorie Target Highlight
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
                  'DAILY CALORIC TARGET',
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
                  '${result.targetCalories.toInt()} KCAL',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: tokens.kineticAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'BMR: ${result.bmr.toInt()} kcal • Maintenance (TDEE): ${result.tdee.toInt()} kcal',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (result.isFloorApplied ||
              result.isUnderweightGuardApplied ||
              result.isMinorGuardApplied) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tokens.isDark
                    ? Colors.amber.withValues(alpha: 0.15)
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: Colors.amber.shade700, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.isFloorApplied
                          ? 'Safety floor applied: minimum ${_sex == BiologicalSex.male ? 1500 : 1200} kcal/day enforced.'
                          : 'Safety guard active: deficit disabled to protect health.',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Macros row
          Row(
            children: [
              Expanded(
                child: _buildMacroBadge(
                  label: 'PROTEIN',
                  grams: result.proteinGrams,
                  color: tokens.kineticAccent,
                  tokens: tokens,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroBadge(
                  label: 'CARBS',
                  grams: result.carbsGrams,
                  color: tokens.isDark ? Colors.lightBlueAccent : Colors.blue,
                  tokens: tokens,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroBadge(
                  label: 'FATS',
                  grams: result.fatsGrams,
                  color:
                      tokens.isDark ? Colors.orangeAccent : Colors.deepOrange,
                  tokens: tokens,
                ),
              ),
            ],
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

  Widget _buildNumberInput({
    required String label,
    required String value,
    required String unit,
    required AppThemeTokens tokens,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontFamily: AppTypography.displayFontFamily,
        color: tokens.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        filled: true,
        fillColor: tokens.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildMacroBadge({
    required String label,
    required double grams,
    required Color color,
    required AppThemeTokens tokens,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${grams.toInt()}g',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

