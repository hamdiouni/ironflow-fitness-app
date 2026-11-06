import 'package:flutter/material.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../shared/presentation/components/app_bottom_sheet.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../domain/calculators/body_fat_calculator.dart';

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
              border: Border.all(
                color: tokens.kineticAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

  Widget _buildInput(
    String label,
    String value,
    String unit,
    AppThemeTokens tokens,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontFamily: AppTypography.displayFontFamily,
        color: tokens.textPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        filled: true,
        fillColor: tokens.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

