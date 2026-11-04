import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewRecipesScreen extends StatefulWidget {
  final DesignTokens tokens;

  const PreviewRecipesScreen({super.key, required this.tokens});

  @override
  State<PreviewRecipesScreen> createState() => _PreviewRecipesScreenState();
}

class _PreviewRecipesScreenState extends State<PreviewRecipesScreen> {
  int _servings = 2;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        title: Text(
          'Recipes',
          style: TextStyle(
            fontFamily: tokens.displayFont,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: tokens.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Recipe Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.cardRadius),
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
                          'FEATURED',
                          style: TextStyle(color: tokens.accent, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(FakeData.recipePrepTime, style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    FakeData.recipeTitle,
                    style: TextStyle(
                      fontFamily: tokens.displayFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${FakeData.recipeCalories} kcal • ${FakeData.recipeProtein}g protein per serving',
                    style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),

                  // Servings Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Servings:', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                      QuantityStepper(
                        value: _servings.toDouble(),
                        step: 1,
                        min: 1,
                        max: 8,
                        unit: 'serv',
                        backgroundColor: tokens.elevated,
                        foregroundColor: tokens.textPrimary,
                        borderRadius: tokens.buttonRadius,
                        onChanged: (v) => setState(() => _servings = v.toInt()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Short Step Cards (Archetype 10)
            Text(
              'INSTRUCTIONS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.textMuted, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            ...FakeData.recipeSteps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final step = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: tokens.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$idx',
                        style: TextStyle(color: tokens.accent, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(color: tokens.textPrimary, fontSize: 14, height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

