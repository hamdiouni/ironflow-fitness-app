import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/services/exercise_catalog.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../providers/active_program_providers.dart';
import '../providers/workout_providers.dart';
import '../widgets/plate_calculator_sheet.dart';
import '../widgets/workout_tab/workout_active_program_content.dart';

/// Workout screen showing the user's active program and quick-start options.
///
/// Displays:
/// - Contextual AI Insight Banner (hybrid AI placement)
/// - Empty state when no active program exists
/// - Active program header with progress bar
/// - Week view with monolithic day chips
/// - Current day content display
/// - Program editor navigation
///
/// **Validates: Requirements 1.6, 8.1, 9.1, 9.5, 17.1, 17.2, 17.3, 17.4, 19.1, 19.4, 19.5**
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final activeProgramAsync = ref.watch(activeProgramProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'WORKOUT',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamilyHeadings,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          const AiEntryButton(contextScreen: 'workout'),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            key: const Key('workout_actions_menu_btn'),
            tooltip: 'Workout Actions',
            icon: Icon(Icons.more_horiz_rounded, color: tokens.textPrimary),
            color: tokens.panel,
            onSelected: (value) {
              switch (value) {
                case 'split':
                  context.go(AppRoutes.workoutProgramSelection);
                case 'edit':
                  context.go(AppRoutes.workoutEditor);
                case 'plates':
                  PlateCalculatorSheet.show(context);
                case 'history':
                  context.go(AppRoutes.workoutHistory);
              }
            },
            itemBuilder: (_) {
              final hasProgram = activeProgramAsync.valueOrNull != null;
              return [
                if (hasProgram) ...[
                  const PopupMenuItem(
                    value: 'split',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.auto_awesome_motion_outlined),
                      title: Text('Change Split'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit Program'),
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'plates',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calculate_outlined),
                    title: Text('Plate Calculator'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.history),
                    title: Text('Workout History'),
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: activeProgramAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
            ),
          ),
          error: (error, stackTrace) => _ErrorState(
            error: error,
            stackTrace: stackTrace,
            onRetry: () => ref.refresh(activeProgramProvider),
          ),
          data: (activeProgram) {
            if (activeProgram == null) {
              return const _EmptyState();
            }
            return WorkoutActiveProgramContent(
              activeProgram: activeProgram,
              historyAsync: historyAsync,
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppStateView.error(
          title: 'UNABLE TO LOAD',
          message: error.toString(),
          onRetry: onRetry,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stripe Hero Card for Program State
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.kineticAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                      ),
                      child: Text(
                        'ROUTINE STATUS',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.kineticAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Icon(Icons.tune_rounded, size: 18, color: tokens.textMuted),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'NO ACTIVE PROGRAM',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a custom AI routine or load an existing program to begin tracking.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13,
                    color: tokens.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: AppButton(
                    label: 'GENERATE PROGRAM',
                    variant: AppButtonVariant.primary,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    onPressed: () =>
                        context.go(AppRoutes.workoutProgramSelection),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'QUICK START OPTIONS',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          // Free Workout Session Card
          Consumer(
            builder: (context, ref, _) => AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () async {
                AppHaptics.shared.selectionChanged();
                await ref
                    .read(workoutNotifierProvider.notifier)
                    .start(initialExercises: const []);
                if (context.mounted) context.go(AppRoutes.workoutActive);
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tokens.elevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on_rounded,
                      color: tokens.kineticAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Empty Workout',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Log exercises freely on the fly',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: tokens.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Exercise Database Card
          AppCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.push(AppRoutes.workoutCatalog),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: tokens.cyanAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise Library',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Browse ${ExerciseCatalog.all.length} compound & isolation movements',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: tokens.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
