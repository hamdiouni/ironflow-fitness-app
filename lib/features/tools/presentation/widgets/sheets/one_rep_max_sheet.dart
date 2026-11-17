import 'package:flutter/material.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../core/providers/units_provider.dart';
import '../../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../domain/calculators/one_rep_max_calculator.dart';

class OneRepMaxSheet extends StatefulWidget {
  final double initialWeight;
  final int initialReps;
  final UnitsSystem units;

  const OneRepMaxSheet({
    super.key,
    this.initialWeight = 100.0,
    this.initialReps = 5,
    this.units = UnitsSystem.metric,
  });

  static Future<void> show(
    BuildContext context, {
    double initialWeight = 100.0,
    int initialReps = 5,
    UnitsSystem units = UnitsSystem.metric,
  }) {
    final resolvedInitial =
        units == UnitsSystem.imperial && initialWeight == 100.0
            ? 225.0
            : initialWeight;
    return AppBottomSheet.show(
      context: context,
      title: '1RM CALCULATOR',
      child: OneRepMaxSheet(
        initialWeight: resolvedInitial,
        initialReps: initialReps,
        units: units,
      ),
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
    final weightUnit = UnitsConverter.getWeightUnit(widget.units);
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'WEIGHT LIFTED',
                    suffixText: weightUnit,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        onChanged: (val) =>
                            setState(() => _reps = val.round()),
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
              border: Border.all(
                color: tokens.kineticAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
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
                  '${result.recommended1RM.toStringAsFixed(1)} $weightUnit',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: tokens.kineticAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Brzycki: ${result.brzycki.toStringAsFixed(1)} $weightUnit • Epley: ${result.epley.toStringAsFixed(1)} $weightUnit',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        '${item.weight.toStringAsFixed(1)} $weightUnit',
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

