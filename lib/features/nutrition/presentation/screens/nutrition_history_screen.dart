import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../domain/entities/daily_nutrition_summary.dart';
import '../providers/paginated_nutrition_provider.dart';

/// Displays the full nutrition history with lazy loading for performance.
///
/// Upgraded to the Monolithic Sci-Fi design system.
/// Uses pagination to load nutrition entries in batches of 20 days.
class NutritionHistoryScreen extends ConsumerStatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  ConsumerState<NutritionHistoryScreen> createState() =>
      _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState
    extends ConsumerState<NutritionHistoryScreen> {
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
      ref.read(paginatedNutritionProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final state = ref.watch(paginatedNutritionProvider);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'NUTRITION LOGS',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: tokens.textPrimary,
          ),
        ),
        actions: [
          if (state.totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tokens.cyanAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(
                      color: tokens.cyanAccent.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${state.nutritionHistory.length} / ${state.totalCount}',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: tokens.cyanAccent,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: tokens.kineticAccent,
        backgroundColor: tokens.panel,
        onRefresh: () =>
            ref.read(paginatedNutritionProvider.notifier).refresh(),
        child: _buildBody(state, tokens),
      ),
    );
  }

  Widget _buildBody(PaginatedNutritionState state, AppThemeTokens tokens) {
    if (state.isLoading && state.nutritionHistory.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: tokens.kineticAccent,
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.error != null && state.nutritionHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: tokens.error),
              const SizedBox(height: 16),
              Text(
                'LOG ARCHIVE UNREACHABLE',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'RETRY ARCHIVE FETCH',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () =>
                    ref.read(paginatedNutritionProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
      );
    }

    if (state.nutritionHistory.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: tokens.textMuted),
            const SizedBox(height: 16),
            Text(
              'NO ARCHIVED TELEMETRY',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Log your first meal to initialize your database',
              style: TextStyle(color: tokens.textMuted, fontSize: 13),
            ),
          ],
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                color: tokens.kineticAccent,
                strokeWidth: 2,
              ),
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

  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');
  static final _dayFormat = DateFormat('d');
  static final _monthFormat = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final dateLabel = _dateFormat.format(summary.date);
    final caloriesLabel = '${summary.totalCalories.toStringAsFixed(0)} KCAL';
    final proteinLabel = '${summary.totalProtein.toStringAsFixed(1)}g protein';
    final mealCount = summary.meals.length;
    final mealCountLabel = '$mealCount meal${mealCount == 1 ? '' : 's'}';

    final calorieTarget = summary.target?.macros.calories ?? 2000;
    final proteinTarget = summary.target?.macros.protein ?? 150;
    final carbsTarget = summary.target?.macros.carbs ?? 200;
    final fatsTarget = summary.target?.macros.fats ?? 60;

    final calorieProgress =
        (summary.totalCalories / calorieTarget).clamp(0.0, 1.0);
    final proteinProgress =
        (summary.totalProtein / proteinTarget).clamp(0.0, 1.0);
    final carbsProgress =
        (summary.totalCarbs / carbsTarget).clamp(0.0, 1.0);
    final fatsProgress =
        (summary.totalFats / fatsTarget).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(
                color: tokens.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _dayFormat.format(summary.date),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: tokens.kineticAccent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  _monthFormat.format(summary.date).toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: tokens.textMuted,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      caloriesLabel,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.restaurant_rounded, size: 12, color: tokens.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      mealCountLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: tokens.textMuted,
                        fontFamily: AppTypography.bodyFontFamily,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      proteinLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: tokens.protein,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTypography.bodyFontFamily,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Macro progress bars
                _MacroProgressBars(
                  calorieProgress: calorieProgress,
                  proteinProgress: proteinProgress,
                  carbsProgress: carbsProgress,
                  fatsProgress: fatsProgress,
                  tokens: tokens,
                ),
              ],
            ),
          ),
        ],
      ),
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
    required this.tokens,
  });

  final double calorieProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatsProgress;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProgressBar(
          progress: calorieProgress,
          color: tokens.kineticAccent,
          height: 4,
          tokens: tokens,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _ProgressBar(
                progress: proteinProgress,
                color: tokens.protein,
                height: 3,
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ProgressBar(
                progress: carbsProgress,
                color: tokens.carbs,
                height: 3,
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ProgressBar(
                progress: fatsProgress,
                color: tokens.fats,
                height: 3,
                tokens: tokens,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.color,
    required this.height,
    required this.tokens,
  });

  final double progress;
  final Color color;
  final double height;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: tokens.card,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}