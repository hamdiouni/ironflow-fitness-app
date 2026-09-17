import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/daily_nutrition_summary.dart';
import '../providers/paginated_nutrition_provider.dart';

/// Displays the full nutrition history with lazy loading for performance.
///
/// Uses pagination to load nutrition entries in batches of 20 days, loading more
/// as the user scrolls. This handles 1000+ nutrition entries efficiently (Requirement 8.1).
class NutritionHistoryScreen extends ConsumerStatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  ConsumerState<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends ConsumerState<NutritionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedNutritionProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      ref.read(paginatedNutritionProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedNutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition History'),
        actions: [
          if (state.totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${state.nutritionHistory.length}/${state.totalCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paginatedNutritionProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PaginatedNutritionState state) {
    if (state.isLoading && state.nutritionHistory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.nutritionHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load nutrition history.\n${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(paginatedNutritionProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.nutritionHistory.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          'No nutrition data yet.\nStart logging your meals!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      itemCount: state.nutritionHistory.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.nutritionHistory.length) {
          // Loading indicator at the end
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _NutritionHistoryItem(summary: state.nutritionHistory[index]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// List item widget
// ---------------------------------------------------------------------------

class _NutritionHistoryItem extends StatelessWidget {
  const _NutritionHistoryItem({required this.summary});

  final DailyNutritionSummary summary;

  // Static DateFormat instances avoid re-allocation on every build call,
  // which matters when scrolling through 1000+ items (Requirement 8.1).
  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');
  static final _dayFormat = DateFormat('d');
  static final _monthFormat = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateFormat.format(summary.date);
    final caloriesLabel = '${summary.totalCalories.toStringAsFixed(0)} kcal';
    final proteinLabel = '${summary.totalProtein.toStringAsFixed(1)}g protein';
    final mealCount = summary.meals.length;
    final mealCountLabel = '$mealCount meal${mealCount == 1 ? '' : 's'}';

    // Calculate macro percentages for progress indicators
    final calorieTarget = summary.target?.macros.calories ?? 2000;
    final proteinTarget = summary.target?.macros.protein ?? 150;
    final carbsTarget = summary.target?.macros.carbs ?? 200;
    final fatsTarget = summary.target?.macros.fats ?? 60;

    final calorieProgress = (summary.totalCalories / calorieTarget).clamp(0.0, 1.0);
    final proteinProgress = (summary.totalProtein / proteinTarget).clamp(0.0, 1.0);
    final carbsProgress = (summary.totalCarbs / carbsTarget).clamp(0.0, 1.0);
    final fatsProgress = (summary.totalFats / fatsTarget).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date badge
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Column(
                children: [
                  Text(
                    _dayFormat.format(summary.date),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    _monthFormat.format(summary.date).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Row(
                    children: [
                      _Stat(
                        icon: Icons.restaurant,
                        label: mealCountLabel,
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      _Stat(
                        icon: Icons.local_fire_department,
                        label: caloriesLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    proteinLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  // Macro progress bars
                  _MacroProgressBars(
                    calorieProgress: calorieProgress,
                    proteinProgress: proteinProgress,
                    carbsProgress: carbsProgress,
                    fatsProgress: fatsProgress,
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

// ---------------------------------------------------------------------------
// Small stat chip
// ---------------------------------------------------------------------------

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: secondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: secondary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Macro progress bars
// ---------------------------------------------------------------------------

class _MacroProgressBars extends StatelessWidget {
  const _MacroProgressBars({
    required this.calorieProgress,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatsProgress,
  });

  final double calorieProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatsProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProgressBar(
          progress: calorieProgress,
          color: AppTheme.primaryColor,
          height: 4,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: _ProgressBar(
                progress: proteinProgress,
                color: AppTheme.proteinColor,
                height: 3,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ProgressBar(
                progress: carbsProgress,
                color: AppTheme.carbsColor,
                height: 3,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ProgressBar(
                progress: fatsProgress,
                color: AppTheme.fatsColor,
                height: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar widget
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.color,
    required this.height,
  });

  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: color.withValues(alpha: 0.2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: color,
          ),
        ),
      ),
    );
  }
}