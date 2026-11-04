import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewTodayScreen extends StatelessWidget {
  final DesignTokens tokens;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onLogMeal;

  const PreviewTodayScreen({
    super.key,
    required this.tokens,
    this.onStartWorkout,
    this.onLogMeal,
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
                        'TODAY',
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
                        'Ready to train',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.chipRadius),
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 16, color: tokens.warning),
                        const SizedBox(width: 4),
                        Text(
                          '${FakeData.currentStreak} d',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Readiness Banner (Archetype 1)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: tokens.isDark ? 0.3 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    LiveMacroRing(
                      progress: FakeData.readinessScore / 100.0,
                      primaryColor: tokens.accent,
                      backgroundColor: tokens.elevated,
                      size: 64,
                      strokeWidth: 6,
                      centerChild: AnimatedCountUpText(
                        targetValue: FakeData.readinessScore,
                        suffix: '%',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Optimal Recovery',
                            style: TextStyle(
                              fontFamily: tokens.displayFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CNS and muscle recovery high. Great day for heavy pressing.',
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Main Workout Card (Archetype 1 Action Hero)
              Text(
                'UP NEXT',
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  border: Border.all(color: tokens.accent.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tokens.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(tokens.chipRadius),
                          ),
                          child: Text(
                            'SCHEDULED',
                            style: TextStyle(
                              color: tokens.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          FakeData.nextWorkoutSplit,
                          style: TextStyle(
                            color: tokens.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      FakeData.nextWorkoutTitle,
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5 exercises • 18 total sets',
                      style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    AnimatedScaleButton(
                      onPressed: onStartWorkout,
                      child: Container(
                        width: double.infinity,
                        height: 46,
                        decoration: BoxDecoration(
                          color: tokens.accent,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: tokens.onAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Start Workout',
                              style: TextStyle(
                                color: tokens.onAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fuel Snapshot
              Text(
                'DAILY NUTRITION',
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${FakeData.caloriesRemaining} kcal left',
                            style: TextStyle(
                              fontFamily: tokens.displayFont,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${FakeData.proteinConsumed.toInt()}g of ${FakeData.proteinTarget.toInt()}g protein',
                            style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedScaleButton(
                      onPressed: onLogMeal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: tokens.elevated,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: tokens.textPrimary),
                            const SizedBox(width: 4),
                            Text(
                              'Log Food',
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
