import 'package:flutter/material.dart';

import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/design_lab_widgets.dart';

class LabFuelScreen extends StatelessWidget {
  const LabFuelScreen({
    super.key,
    required this.tokens,
    required this.isWide,
  });

  final LabTokens tokens;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.pagePadding),
      children: [
        _buildHeader(),
        SizedBox(height: tokens.sectionGap),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildDailyTargetCard(),
                    SizedBox(height: tokens.sectionGap),
                    _buildQuickSearchPreviewCard(),
                  ],
                ),
              ),
              SizedBox(width: tokens.sectionGap),
              Expanded(
                flex: 3,
                child: _buildMealHistoryCard(),
              ),
            ],
          )
        else ...[
          _buildDailyTargetCard(),
          SizedBox(height: tokens.sectionGap),
          _buildQuickSearchPreviewCard(),
          SizedBox(height: tokens.sectionGap),
          _buildMealHistoryCard(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nutrition', style: tokens.headingStyle(24)),
              Text(
                'Daily calories and macros',
                style: tokens.bodyStyle(
                  13,
                  weight: FontWeight.w400,
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        LabSecondaryButton(
          tokens: tokens,
          label: 'History',
          icon: Icons.history_rounded,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDailyTargetCard() {
    final pct = LabFakeData.caloriesConsumed / LabFakeData.caloriesTarget;
    final remaining =
        (LabFakeData.caloriesTarget - LabFakeData.caloriesConsumed).round();
    return LabCard(
      tokens: tokens,
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LabRingGauge(
                tokens: tokens,
                progress: pct,
                centerText: '${(pct * 100).round()}%',
                color: tokens.accent,
                size: 64,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$remaining kcal left', style: tokens.numberStyle(22)),
                    const SizedBox(height: 2),
                    Text(
                      '${LabFakeData.caloriesConsumed.round()} of ${LabFakeData.caloriesTarget.round()} kcal logged',
                      style: tokens.bodyStyle(
                        12,
                        weight: FontWeight.w500,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MacroBar(
            tokens: tokens,
            label: 'Protein',
            current: LabFakeData.proteinG,
            target: LabFakeData.proteinTargetG,
            color: tokens.protein,
          ),
          const SizedBox(height: 8),
          _MacroBar(
            tokens: tokens,
            label: 'Carbs',
            current: LabFakeData.carbsG,
            target: LabFakeData.carbsTargetG,
            color: tokens.carbs,
          ),
          const SizedBox(height: 8),
          _MacroBar(
            tokens: tokens,
            label: 'Fats',
            current: LabFakeData.fatsG,
            target: LabFakeData.fatsTargetG,
            color: tokens.fats,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: LabPrimaryButton(
              tokens: tokens,
              label: 'Search & Log Food',
              icon: Icons.add_rounded,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchPreviewCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: tokens.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search ${LabFakeData.catalogFoodCount}+ database & custom foods',
                  style: tokens.bodyStyle(
                    13,
                    weight: FontWeight.w500,
                    color: tokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tokens.raised,
              borderRadius: BorderRadius.circular(tokens.buttonRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create Custom Food', style: tokens.headingStyle(13)),
                      const SizedBox(height: 2),
                      Text(
                        'Saves to your personal food list so it appears right in search.',
                        style: tokens.bodyStyle(
                          12,
                          weight: FontWeight.w400,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                LabTag(tokens: tokens, label: 'Custom', color: tokens.secondaryAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistoryCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Today\'s Meals', style: tokens.headingStyle(16)),
              const Spacer(),
              Text(
                '${LabFakeData.meals.length} entries',
                style: tokens.labelStyle(11, color: tokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < LabFakeData.meals.length; i++) ...[
            if (i > 0) Divider(height: 16, color: tokens.border),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              LabFakeData.meals[i].name,
                              style: tokens.bodyStyle(14, weight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (LabFakeData.meals[i].isCustom) ...[
                            const SizedBox(width: 6),
                            LabTag(
                              tokens: tokens,
                              label: 'Custom',
                              color: tokens.secondaryAccent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LabFakeData.meals[i].timing,
                        style: tokens.bodyStyle(
                          12,
                          weight: FontWeight.w400,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${LabFakeData.meals[i].kcal} kcal',
                      style: tokens.numberStyle(14),
                    ),
                    Text(
                      'P ${LabFakeData.meals[i].proteinG} • C ${LabFakeData.meals[i].carbsG} • F ${LabFakeData.meals[i].fatsG}',
                      style: tokens.labelStyle(10, color: tokens.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.tokens,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  final LabTokens tokens;
  final String label;
  final double current;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: tokens.bodyStyle(12, weight: FontWeight.w600)),
            const Spacer(),
            Text(
              '${current.round()} / ${target.round()} g',
              style: tokens.numberStyle(12, color: tokens.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: tokens.raised,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
