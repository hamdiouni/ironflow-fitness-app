import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../domain/calculators/body_fat_calculator.dart';
import '../../domain/calculators/calorie_macro_calculator.dart';
import '../../domain/calculators/one_rep_max_calculator.dart';
import '../../domain/calculators/water_intake_calculator.dart';
import '../../domain/calculators/weight_goal_planner.dart';

// ── 1. One-Rep Max Sheet ──────────────────────────────────────────────────────

class OneRepMaxSheet extends StatefulWidget {
  final double initialWeight;
  final int initialReps;

  const OneRepMaxSheet({
    super.key,
    this.initialWeight = 100.0,
    this.initialReps = 5,
  });

  static Future<void> show(BuildContext context, {double initialWeight = 100.0, int initialReps = 5}) {
    return AppBottomSheet.show(
      context: context,
      title: '1RM CALCULATOR',
      child: OneRepMaxSheet(initialWeight: initialWeight, initialReps: initialReps),
    );
  }

  @override
  State<OneRepMaxSheet> createState() => _OneRepMaxSheetState();
}

class _OneRepMaxSheetState extends State<OneRepMaxSheet> {
  late double _weight;
  late int _reps;
  late TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight;
    _reps = widget.initialReps;
    _weightCtrl = TextEditingController(text: _weight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final result = OneRepMaxCalculator.calculate(weight: _weight, reps: _reps);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'WEIGHT LIFTED',
                    suffixText: 'kg',
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle),
                    ),
                  ),
                  onChanged: (val) {
                    final d = double.tryParse(val);
                    if (d != null && d >= 0) setState(() => _weight = d);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REPS: $_reps',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.textMuted,
                        ),
                      ),
                      Slider(
                        value: _reps.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        activeColor: tokens.kineticAccent,
                        onChanged: (val) => setState(() => _reps = val.round()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main 1RM result highlight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMATED 1-REP MAX',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: tokens.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${result.recommended1RM.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: tokens.kineticAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Brzycki: ${result.brzycki.toStringAsFixed(1)} kg • Epley: ${result.epley.toStringAsFixed(1)} kg',
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

          // Percentage Breakdown Table
          Text(
            'TRAINING PERCENTAGES',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Column(
              children: result.percentageTable.take(6).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.percentage}% 1RM',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      Text(
                        '~${item.estimatedReps} reps',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 11,
                          color: tokens.textMuted,
                        ),
                      ),
                      Text(
                        '${item.weight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: tokens.kineticAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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

// ── 2. Calorie & Macro Sheet ──────────────────────────────────────────────────

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
                        color: isSelected ? tokens.kineticAccent : Colors.transparent,
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
              border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5), width: 1.5),
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
          if (result.isFloorApplied || result.isUnderweightGuardApplied || result.isMinorGuardApplied) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tokens.isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: Colors.amber.shade700, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Colors.amber.shade700),
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
                  color: tokens.isDark ? Colors.orangeAccent : Colors.deepOrange,
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

// ── 3. Body Fat % Sheet ───────────────────────────────────────────────────────

class BodyFatSheet extends StatefulWidget {
  final UserProfile? profile;

  const BodyFatSheet({super.key, this.profile});

  static Future<void> show(BuildContext context, {UserProfile? profile}) {
    return AppBottomSheet.show(
      context: context,
      title: 'BODY FAT CALCULATOR (US NAVY)',
      child: BodyFatSheet(profile: profile),
    );
  }

  @override
  State<BodyFatSheet> createState() => _BodyFatSheetState();
}

class _BodyFatSheetState extends State<BodyFatSheet> {
  late double _weight;
  late double _height;
  late double _neck;
  late double _waist;
  double? _hip;
  late BiologicalSex _sex;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _weight = p?.weightKg ?? 78.0;
    _height = p?.heightCm ?? 178.0;
    _neck = 38.0;
    _waist = 84.0;
    _hip = 96.0;
    _sex = p?.sex ?? BiologicalSex.male;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final result = BodyFatCalculator.calculate(
      weightKg: _weight,
      heightCm: _height,
      neckCm: _neck,
      waistCm: _waist,
      hipCm: _sex == BiologicalSex.female ? _hip : null,
      sex: _sex,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInput('NECK', '$_neck', 'cm', tokens, (v) {
                  final d = double.tryParse(v);
                  if (d != null) setState(() => _neck = d);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInput('WAIST', '$_waist', 'cm', tokens, (v) {
                  final d = double.tryParse(v);
                  if (d != null) setState(() => _waist = d);
                }),
              ),
              if (_sex == BiologicalSex.female) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInput('HIP', '${_hip ?? 96}', 'cm', tokens, (v) {
                    final d = double.tryParse(v);
                    if (d != null) setState(() => _hip = d);
                  }),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Result display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'BODY FAT PERCENTAGE',
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
                  '${result.bodyFatPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: tokens.kineticAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.kineticAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Text(
                    result.category.title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tokens.kineticAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Fat Mass: ${result.fatMassKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12,
                        color: tokens.textMuted,
                      ),
                    ),
                    Text(
                      'Lean Mass: ${result.leanMassKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ],
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

  Widget _buildInput(String label, String value, String unit, AppThemeTokens tokens, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontFamily: AppTypography.displayFontFamily, color: tokens.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        filled: true,
        fillColor: tokens.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radiusSm)),
      ),
      onChanged: onChanged,
    );
  }
}

// ── 4. Weight Goal Planner Sheet ───────────────────────────────────────────────

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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontFamily: AppTypography.displayFontFamily, color: tokens.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'CURRENT WEIGHT',
                    suffixText: 'kg',
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radiusSm)),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontFamily: AppTypography.displayFontFamily, color: tokens.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'TARGET WEIGHT',
                    suffixText: 'kg',
                    filled: true,
                    fillColor: tokens.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radiusSm)),
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
                      style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: tokens.textMuted),
                    ),
                    Text(
                      '${_weeklyRate.toStringAsFixed(2)} kg / week',
                      style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: tokens.kineticAccent),
                    ),
                  ],
                ),
                Slider(
                  value: _weeklyRate,
                  min: 0.25,
                  max: 1.0,
                  divisions: 3, // 0.25, 0.50, 0.75, 1.00
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
              border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMATED COMPLETION',
                  style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: tokens.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '~${result.estimatedWeeks.toStringAsFixed(1)} WEEKS',
                  style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 30, fontWeight: FontWeight.w800, color: tokens.kineticAccent),
                ),
                const SizedBox(height: 6),
                Text(
                  result.plainEnglishSummary,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: AppTypography.bodyFontFamily, fontSize: 12, color: tokens.textPrimary),
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

// ── 5. Water Intake Sheet ─────────────────────────────────────────────────────

class WaterIntakeSheet extends StatefulWidget {
  final UserProfile? profile;

  const WaterIntakeSheet({super.key, this.profile});

  static Future<void> show(BuildContext context, {UserProfile? profile}) {
    return AppBottomSheet.show(
      context: context,
      title: 'DAILY WATER INTAKE',
      child: WaterIntakeSheet(profile: profile),
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
    _weight = widget.profile?.weightKg ?? 75.0;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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
            initialValue: _weight.toStringAsFixed(1),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontFamily: AppTypography.displayFontFamily, color: tokens.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'BODY WEIGHT',
              suffixText: 'kg',
              filled: true,
              fillColor: tokens.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radiusSm)),
            ),
            onChanged: (v) {
              final d = double.tryParse(v);
              if (d != null && d > 20) setState(() => _weight = d);
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
                    Text('DAILY WORKOUT DURATION', style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: tokens.textMuted)),
                    Text('$_workoutMins min', style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: tokens.kineticAccent)),
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
            title: Text('Hot / Humid Climate', style: TextStyle(fontFamily: AppTypography.bodyFontFamily, fontSize: 13, color: tokens.textPrimary)),
            subtitle: Text('+500 ml for elevated perspiration', style: TextStyle(fontFamily: AppTypography.bodyFontFamily, fontSize: 11, color: tokens.textMuted)),
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
              border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'DAILY HYDRATION TARGET',
                  style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: tokens.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.totalLiters.toStringAsFixed(1)} LITERS',
                  style: TextStyle(fontFamily: AppTypography.displayFontFamily, fontSize: 32, fontWeight: FontWeight.w800, color: tokens.kineticAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  '~${result.glasses} standard glasses (250 ml)',
                  style: TextStyle(fontFamily: AppTypography.bodyFontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Baseline: ${(result.baselineMl / 1000).toStringAsFixed(1)} L • Workout Sweat: ${(result.workoutBonusMl / 1000).toStringAsFixed(1)} L',
                  style: TextStyle(fontFamily: AppTypography.bodyFontFamily, fontSize: 11, color: tokens.textMuted),
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
