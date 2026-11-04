import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewQuantitySheet extends StatefulWidget {
  final DesignTokens tokens;
  final VoidCallback? onConfirm;

  const PreviewQuantitySheet({
    super.key,
    required this.tokens,
    this.onConfirm,
  });

  @override
  State<PreviewQuantitySheet> createState() => _PreviewQuantitySheetState();
}

class _PreviewQuantitySheetState extends State<PreviewQuantitySheet> {
  double _grams = FakeData.defaultGrams;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final calories = ((_grams / 100.0) * FakeData.foodCaloriesPer100g).toInt();
    final protein = ((_grams / 100.0) * FakeData.foodProteinPer100g).toStringAsFixed(1);
    final carbs = ((_grams / 100.0) * FakeData.foodCarbsPer100g).toStringAsFixed(1);
    final fat = ((_grams / 100.0) * FakeData.foodFatPer100g).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.sheetRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Food Title & Default Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  FakeData.selectedFoodName,
                  style: TextStyle(
                    fontFamily: tokens.displayFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              Text(
                '$calories kcal',
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: tokens.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${protein}g P • ${carbs}g C • ${fat}g F',
            style: TextStyle(color: tokens.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Interactive Stepper
          Center(
            child: SizedBox(
              width: 220,
              child: QuantityStepper(
                value: _grams,
                step: 10,
                min: 10,
                max: 1000,
                unit: 'g',
                backgroundColor: tokens.elevated,
                foregroundColor: tokens.textPrimary,
                borderRadius: tokens.buttonRadius,
                onChanged: (v) => setState(() => _grams = v),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Live "After Adding" Balance Preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.elevated,
              borderRadius: BorderRadius.circular(tokens.cardRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily remaining after log:',
                  style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                ),
                Text(
                  '${FakeData.caloriesRemaining - calories} kcal',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button
          AnimatedScaleButton(
            onPressed: widget.onConfirm,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: tokens.accent,
                borderRadius: BorderRadius.circular(tokens.buttonRadius),
              ),
              alignment: Alignment.center,
              child: Text(
                'Log to Meal',
                style: TextStyle(color: tokens.onAccent, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
