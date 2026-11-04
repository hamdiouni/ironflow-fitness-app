import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewFuelScreen extends StatelessWidget {
  final DesignTokens tokens;
  final VoidCallback? onAddFood;

  const PreviewFuelScreen({
    super.key,
    required this.tokens,
    this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FUEL',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: tokens.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Daily Balance',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  AnimatedScaleButton(
                    onPressed: onAddFood,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tokens.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: tokens.onAccent, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // HERO DAILY BALANCE CARD (Archetype 6)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        LiveMacroRing(
                          progress: FakeData.caloriesConsumed / FakeData.calorieGoal.toDouble(),
                          primaryColor: tokens.accent,
                          backgroundColor: tokens.elevated,
                          size: 110,
                          strokeWidth: 8,
                          centerChild: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedCountUpText(
                                targetValue: FakeData.caloriesRemaining,
                                style: TextStyle(
                                  fontFamily: tokens.displayFont,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              Text('kcal left', style: TextStyle(color: tokens.textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMacroRow(tokens, 'Protein', FakeData.proteinConsumed, FakeData.proteinTarget, 'g', tokens.accent),
                            const SizedBox(height: 10),
                            _buildMacroRow(tokens, 'Carbs', FakeData.carbsConsumed, FakeData.carbsTarget, 'g', tokens.warning),
                            const SizedBox(height: 10),
                            _buildMacroRow(tokens, 'Fats', FakeData.fatConsumed, FakeData.fatTarget, 'g', tokens.success),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Chronological Meals Timeline (Archetype 6)
              Text(
                'MEALS TIMELINE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.textMuted, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              ...FakeData.mealsTimeline.map((meal) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.cardRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  meal['title'] as String,
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: tokens.textPrimary),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  meal['time'] as String,
                                  style: TextStyle(color: tokens.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meal['items'] as String,
                              style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          '${meal['calories']} kcal',
                          style: TextStyle(
                            fontFamily: tokens.displayFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroRow(DesignTokens tokens, String label, double current, double goal, String unit, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('${current.toInt()}/${goal.toInt()} $unit', style: TextStyle(color: tokens.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(color: tokens.elevated, borderRadius: BorderRadius.circular(2)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          ),
        ),
      ],
    );
  }
}

