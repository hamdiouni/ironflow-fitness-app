import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../workout/presentation/widgets/plate_calculator_sheet.dart';
import '../widgets/calculator_sheets.dart';

/// Hub screen displaying all 6 pure, scientific calculators with instant modal launchers.
class ToolsHubScreen extends ConsumerWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    final tools = [
      _ToolDefinition(
        id: 'plate',
        title: 'Barbell Plate Calculator',
        badge: 'BARBELL LOAD',
        description: 'Calculate exact plates per side for any Olympic barbell in kg or lb with sleeve visualizer.',
        icon: Icons.fitness_center_rounded,
        accentColor: tokens.kineticAccent,
        onTap: () => PlateCalculatorSheet.show(context),
      ),
      _ToolDefinition(
        id: '1rm',
        title: '1RM Strength Calculator',
        badge: 'STRENGTH',
        description: 'Estimate your true 1-Rep Max from submaximal sets with Brzycki and Epley formulas and full intensity breakdown.',
        icon: Icons.speed_rounded,
        accentColor: tokens.isDark ? Colors.amberAccent : Colors.orange,
        onTap: () => OneRepMaxSheet.show(context),
      ),
      _ToolDefinition(
        id: 'calorie_macro',
        title: 'Calorie & Macro Calculator',
        badge: 'NUTRITION',
        description: 'Calculate precise BMR, maintenance TDEE, and protein/carb/fat targets using Mifflin-St Jeor with metabolic safety floors.',
        icon: Icons.restaurant_menu_rounded,
        accentColor: tokens.isDark ? Colors.lightGreenAccent : Colors.green,
        onTap: () => CalorieMacroSheet.show(context, profile: profile),
      ),
      _ToolDefinition(
        id: 'body_fat',
        title: 'Body Fat % Calculator',
        badge: 'COMPOSITION',
        description: 'Determine body fat percentage, lean mass, and fat mass using the proven US Navy tape-measure method.',
        icon: Icons.accessibility_new_rounded,
        accentColor: tokens.isDark ? Colors.cyanAccent : Colors.teal,
        onTap: () => BodyFatSheet.show(context, profile: profile),
      ),
      _ToolDefinition(
        id: 'weight_planner',
        title: 'Weight Goal Planner',
        badge: 'TIMELINE',
        description: 'Plan safe, realistic weight loss or muscle gain timelines with estimated finish dates and caloric adjustments.',
        icon: Icons.calendar_month_rounded,
        accentColor: tokens.isDark ? Colors.purpleAccent : Colors.purple,
        onTap: () => WeightGoalSheet.show(context, profile: profile),
      ),
      _ToolDefinition(
        id: 'water_intake',
        title: 'Daily Water Intake Target',
        badge: 'HYDRATION',
        description: 'Calculate baseline water requirements plus sweat replacement for workout sessions and hot climates.',
        icon: Icons.water_drop_rounded,
        accentColor: tokens.isDark ? Colors.lightBlueAccent : Colors.blue,
        onTap: () => WaterIntakeSheet.show(context, profile: profile),
      ),
    ];

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.panel,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CALCULATORS & TOOLS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'FITNESS CALCULATORS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              itemCount: tools.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return _ToolCard(tool: tool, tokens: tokens)
                    .animate()
                    .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                    .slideY(begin: 0.08, end: 0.0, curve: Curves.easeOut);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolDefinition {
  final String id;
  final String title;
  final String badge;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _ToolDefinition({
    required this.id,
    required this.title,
    required this.badge,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolDefinition tool;
  final AppThemeTokens tokens;

  const _ToolCard({required this.tool, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('tool_card_${tool.id}'),
      onTap: tool.onTap,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tool.accentColor.withValues(alpha: tokens.isDark ? 0.15 : 0.12),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(
                  color: tool.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(tool.icon, color: tool.accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tokens.card,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        child: Text(
                          tool.badge,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: tokens.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tool.title,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.description,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
