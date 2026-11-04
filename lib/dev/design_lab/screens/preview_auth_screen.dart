import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewAuthScreen extends StatefulWidget {
  final DesignTokens tokens;

  const PreviewAuthScreen({
    super.key,
    required this.tokens,
  });

  @override
  State<PreviewAuthScreen> createState() => _PreviewAuthScreenState();
}

class _PreviewAuthScreenState extends State<PreviewAuthScreen> {
  int _selectedGoalIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav & Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedScaleButton(
                        onPressed: () {},
                        child: Icon(Icons.arrow_back, color: tokens.textSecondary, size: 22),
                      ),
                      Text(
                        'STEP 2 OF 4',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: tokens.accent,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Skip',
                          style: TextStyle(color: tokens.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress indicator bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: tokens.elevated,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FakeData.onboardingStepTitle,
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: tokens.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      FakeData.onboardingStepSubtitle,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Goal selection cards (Archetype 7)
                    ...List.generate(FakeData.onboardingGoals.length, (index) {
                      final goal = FakeData.onboardingGoals[index];
                      final isSelected = _selectedGoalIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedGoalIndex = index),
                        child: AnimatedContainer(
                          duration: tokens.durationQuick,
                          curve: tokens.curveQuick,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? tokens.accent.withValues(alpha: 0.08) : tokens.panel,
                            borderRadius: BorderRadius.circular(tokens.cardRadius),
                            border: Border.all(
                              color: isSelected ? tokens.accent : tokens.borderSubtle,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? tokens.accent : tokens.textMuted,
                                    width: 2,
                                  ),
                                  color: isSelected ? tokens.accent : Colors.transparent,
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, size: 14, color: tokens.onAccent)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal['title']!,
                                      style: TextStyle(
                                        fontFamily: tokens.displayFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: tokens.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      goal['desc']!,
                                      style: TextStyle(
                                        color: tokens.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border(top: BorderSide(color: tokens.borderSubtle)),
              ),
              child: AnimatedScaleButton(
                onPressed: () {},
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: tokens.onAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
