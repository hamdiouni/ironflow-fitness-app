import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/daily_nutrition_summary.dart';
import '../../domain/entities/nutrition_targets.dart';
import '../providers/nutrition_providers.dart';
import 'meal_logging_screen.dart';

/// Nutrition tracking screen with layered display of nutrition data.
///
/// Displays three levels of nutrition information:
/// - LEVEL 1: Macros (always visible) - Calories, Protein, Carbs, Fats
/// - LEVEL 2: Micros (expandable) - Fiber, Sugar, Sodium, Potassium
/// - LEVEL 3: Vitamins & Minerals (expandable) - Vitamins A-E, Minerals
///
/// Uses color coding: Green (80-120%), Orange (50-80% or 120-150%), Red (<50% or >150%)
///
/// **Validates: Requirements 3.4, 3.5**
class NutritionTrackingScreen extends ConsumerWidget {
  const NutritionTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _todayDate();
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracking'),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _NutritionTrackingErrorState(
          error: error,
          stackTrace: stackTrace,
          onRetry: () {
            ref.invalidate(dailyNutritionSummaryProvider(today));
          },
        ),
        data: (summary) => _NutritionTrackingBody(summary: summary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMealLoggingDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Meal'),
      ),
    );
  }

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _showMealLoggingDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MealLoggingScreen(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state widget
// ---------------------------------------------------------------------------

class _NutritionTrackingErrorState extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _NutritionTrackingErrorState({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Nutrition Data',
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              style: TextStyle(color: secondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body widget
// ---------------------------------------------------------------------------

class _NutritionTrackingBody extends StatefulWidget {
  final DailyNutritionSummary summary;

  const _NutritionTrackingBody({required this.summary});

  @override
  State<_NutritionTrackingBody> createState() => _NutritionTrackingBodyState();
}

class _NutritionTrackingBodyState extends State<_NutritionTrackingBody> {
  bool _expandMicros = false;
  bool _expandVitaminsAndMinerals = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Daily totals header
          _DailyTotalsHeader(summary: widget.summary),
          const SizedBox(height: AppTheme.spacingLarge),

          // LEVEL 1: Macros (always visible)
          _MacrosSection(summary: widget.summary),
          const SizedBox(height: AppTheme.spacingLarge),

          // LEVEL 2: Micros (expandable)
          _MicrosSection(
            summary: widget.summary,
            isExpanded: _expandMicros,
            onToggle: () {
              setState(() => _expandMicros = !_expandMicros);
            },
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // LEVEL 3: Vitamins & Minerals (expandable)
          _VitaminsAndMineralsSection(
            summary: widget.summary,
            isExpanded: _expandVitaminsAndMinerals,
            onToggle: () {
              setState(() =>
                  _expandVitaminsAndMinerals = !_expandVitaminsAndMinerals);
            },
          ),
          const SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily totals header
// ---------------------------------------------------------------------------

class _DailyTotalsHeader extends StatelessWidget {
  final DailyNutritionSummary summary;

  const _DailyTotalsHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          'Total Calories: ${summary.totalCalories.toStringAsFixed(0)} kcal',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL 1: Macros Section
// ---------------------------------------------------------------------------

class _MacrosSection extends StatelessWidget {
  final DailyNutritionSummary summary;

  const _MacrosSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEVEL 1: Macronutrients',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        _NutrientProgressCard(
          label: 'Calories',
          consumed: summary.totalCalories,
          target: summary.target?.macros.calories ?? 2000,
          unit: 'kcal',
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        _NutrientProgressCard(
          label: 'Protein',
          consumed: summary.totalProtein,
          target: summary.target?.macros.protein ?? 150,
          unit: 'g',
          color: AppTheme.proteinColor,
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        _NutrientProgressCard(
          label: 'Carbohydrates',
          consumed: summary.totalCarbs,
          target: summary.target?.macros.carbs ?? 200,
          unit: 'g',
          color: AppTheme.carbsColor,
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        _NutrientProgressCard(
          label: 'Fats',
          consumed: summary.totalFats,
          target: summary.target?.macros.fats ?? 60,
          unit: 'g',
          color: AppTheme.fatsColor,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL 2: Micros Section (Expandable)
// ---------------------------------------------------------------------------

class _MicrosSection extends StatelessWidget {
  final DailyNutritionSummary summary;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MicrosSection({
    required this.summary,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL 2: Micronutrients',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: onSurface,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          _NutrientProgressCard(
            label: 'Fiber',
            consumed: summary.totalFiber,
            target: summary.target?.micros.fiber ?? 25,
            unit: 'g',
            color: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _NutrientProgressCard(
            label: 'Sugar',
            consumed: summary.totalSugar,
            target: summary.target?.micros.sugar ?? 50,
            unit: 'g',
            color: const Color(0xFFAB47BC),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _NutrientProgressCard(
            label: 'Sodium',
            consumed: summary.totalSodium,
            target: summary.target?.micros.sodium ?? 2300,
            unit: 'mg',
            color: const Color(0xFFEF5350),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _NutrientProgressCard(
            label: 'Potassium',
            consumed: summary.totalPotassium,
            target: summary.target?.micros.potassium ?? 3500,
            unit: 'mg',
            color: const Color(0xFF29B6F6),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL 3: Vitamins & Minerals Section (Expandable)
// ---------------------------------------------------------------------------

class _VitaminsAndMineralsSection extends StatelessWidget {
  final DailyNutritionSummary summary;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _VitaminsAndMineralsSection({
    required this.summary,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL 3: Vitamins & Minerals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: onSurface,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          // Vitamins subsection
          Text(
            'Vitamins',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Vitamin A',
            consumed: summary.totalVitaminA,
            target: summary.target?.vitamins.vitaminA ?? 900,
            unit: 'mcg',
            color: const Color(0xFFFF7043),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Vitamin B',
            consumed: summary.totalVitaminB,
            target: summary.target?.vitamins.vitaminB ?? 2.4,
            unit: 'mcg',
            color: const Color(0xFFFFCA28),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Vitamin C',
            consumed: summary.totalVitaminC,
            target: summary.target?.vitamins.vitaminC ?? 90,
            unit: 'mg',
            color: const Color(0xFFEF5350),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Vitamin D',
            consumed: summary.totalVitaminD,
            target: summary.target?.vitamins.vitaminD ?? 20,
            unit: 'mcg',
            color: const Color(0xFFFFD54F),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Vitamin E',
            consumed: summary.totalVitaminE,
            target: summary.target?.vitamins.vitaminE ?? 15,
            unit: 'mg',
            color: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          // Minerals subsection
          Text(
            'Minerals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Calcium',
            consumed: summary.totalCalcium,
            target: summary.target?.minerals.calcium ?? 1000,
            unit: 'mg',
            color: const Color(0xFF42A5F5),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Iron',
            consumed: summary.totalIron,
            target: summary.target?.minerals.iron ?? 18,
            unit: 'mg',
            color: const Color(0xFFEF5350),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Magnesium',
            consumed: summary.totalMagnesium,
            target: summary.target?.minerals.magnesium ?? 400,
            unit: 'mg',
            color: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _NutrientProgressCard(
            label: 'Zinc',
            consumed: summary.totalZinc,
            target: summary.target?.minerals.zinc ?? 11,
            unit: 'mg',
            color: const Color(0xFFAB47BC),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Nutrient Progress Card Widget
// ---------------------------------------------------------------------------

class _NutrientProgressCard extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final Color color;

  const _NutrientProgressCard({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? ((consumed / target) * 100).toDouble() : 0.0;
    final status = _getStatus(percentage);
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${consumed.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: statusColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          // Percentage and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              _StatusBadge(status: status),
            ],
          ),
        ],
      ),
    );
  }

  NutritionStatus _getStatus(double percentage) {
    if (percentage >= 80 && percentage <= 120) {
      return NutritionStatus.good;
    } else if ((percentage >= 50 && percentage < 80) ||
        (percentage > 120 && percentage <= 150)) {
      return NutritionStatus.moderate;
    } else {
      return NutritionStatus.poor;
    }
  }

  Color _getStatusColor(NutritionStatus status) {
    switch (status) {
      case NutritionStatus.good:
        return const Color(0xFF4CAF50); // Green
      case NutritionStatus.moderate:
        return const Color(0xFFFFA726); // Orange
      case NutritionStatus.poor:
        return const Color(0xFFEF5350); // Red
    }
  }
}

// ---------------------------------------------------------------------------
// Status Badge Widget
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final NutritionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      NutritionStatus.good => ('On Target', const Color(0xFF4CAF50)),
      NutritionStatus.moderate => ('Moderate', const Color(0xFFFFA726)),
      NutritionStatus.poor => ('Off Target', const Color(0xFFEF5350)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
