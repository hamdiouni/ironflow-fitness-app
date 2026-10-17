import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../domain/entities/exercise_definition.dart';
import '../providers/exercise_providers.dart';
import 'exercise_detail_screen.dart';

/// Exercise catalog with muscle-group tabs, search, and Monolithic Sci-Fi cards.
class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({super.key, this.onSelect});
  final void Function(ExerciseDefinition)? onSelect;

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends ConsumerState<ExerciseCatalogScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  static const _tabs = [
    (label: 'ALL',       group: null as MuscleGroup?),
    (label: 'CHEST',     group: MuscleGroup.chest),
    (label: 'BACK',      group: MuscleGroup.back),
    (label: 'LEGS',      group: MuscleGroup.legs),
    (label: 'SHOULDERS', group: MuscleGroup.shoulders),
    (label: 'ARMS',      group: MuscleGroup.arms),
    (label: 'ABS',       group: MuscleGroup.abs),
    (label: 'GLUTES',    group: MuscleGroup.glutes),
    (label: 'CARDIO',    group: MuscleGroup.cardio),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.animation?.addListener(_onTabAnimation);
  }

  int _lastTabIndex = 0;

  void _onTabAnimation() {
    final index = _tabController.index;
    if (index != _lastTabIndex) {
      _lastTabIndex = index;
      final group = _tabs[index].group;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(exerciseFilterProvider.notifier).setMuscleGroup(group);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.animation?.removeListener(_onTabAnimation);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final exercises = ref.watch(filteredExercisesProvider);
    final filter = ref.watch(exerciseFilterProvider);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'EXERCISE CATALOG',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamilyHeadings,
            letterSpacing: 1.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      ref.read(exerciseFilterProvider.notifier).setQuery(v),
                  style: TextStyle(color: tokens.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search exercise database...',
                    hintStyle: TextStyle(color: tokens.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search, size: 20, color: tokens.textMuted),
                    suffixIcon: filter.query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: tokens.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(exerciseFilterProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: tokens.panel,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                    ),
                  ),
                ),
              ),
              // Muscle group tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: tokens.kineticAccent,
                indicatorWeight: 2.5,
                dividerColor: tokens.borderSubtle,
                labelColor: tokens.kineticAccent,
                unselectedLabelColor: tokens.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: _tabs.map((t) {
                  final color = t.group?.color ?? tokens.kineticAccent;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (t.group != null) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamilyHeadings,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Equipment filter row
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _EquipChip(
                  label: 'ANY',
                  selected: filter.equipment == null,
                  tokens: tokens,
                  onTap: () => ref
                      .read(exerciseFilterProvider.notifier)
                      .setEquipment(null),
                ),
                ...Equipment.values.map((eq) => _EquipChip(
                      label: eq.displayName.toUpperCase(),
                      selected: filter.equipment == eq,
                      tokens: tokens,
                      onTap: () => ref
                          .read(exerciseFilterProvider.notifier)
                          .setEquipment(filter.equipment == eq ? null : eq),
                    )),
              ],
            ),
          ),
          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${exercises.length} EXERCISES CATALOGED',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AppStateView.empty(
                        title: 'NO EXERCISES FOUND',
                        message: 'No exercises match the selected query and equipment criteria.',
                        actionLabel: 'RESET FILTERS',
                        onAction: () {
                          _searchController.clear();
                          ref.read(exerciseFilterProvider.notifier).reset();
                        },
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.80,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      return _ExerciseCard(
                        exercise: ex,
                        tokens: tokens,
                        onTap: () {
                          if (widget.onSelect != null) {
                            widget.onSelect!(ex);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseDetailScreen(name: ex.name),
                            ));
                          }
                        },
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: index * 20),
                            duration: const Duration(milliseconds: 180),
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Equipment chip ────────────────────────────────────────────────────────────

class _EquipChip extends StatelessWidget {
  const _EquipChip({
    required this.label,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? tokens.kineticAccent.withValues(alpha: 0.15)
                : tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
            border: Border.all(
              color: selected ? tokens.kineticAccent : tokens.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: tokens.kineticAccent.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 0.5,
              color: selected
                  ? tokens.kineticAccent
                  : tokens.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.tokens,
    required this.onTap,
  });
  final ExerciseDefinition exercise;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          color: tokens.card,
          border: Border.all(
            color: tokens.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: CachedNetworkImage(
                imageUrl: exercise.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, _) => Container(
                  color: tokens.panel,
                  child: Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: tokens.kineticAccent.withValues(alpha: 0.3),
                      size: 28,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: tokens.panel,
                  child: Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: tokens.kineticAccent.withValues(alpha: 0.3),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MuscleTag(exercise.muscleGroup, tokens: tokens),
                      const Spacer(),
                      _DifficultyDots(exercise.difficulty, tokens: tokens),
                    ],
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

class _MuscleTag extends StatelessWidget {
  const _MuscleTag(this.group, {required this.tokens});
  final MuscleGroup group;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: group.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(tokens.radiusXs),
        border: Border.all(
          color: group.color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        group.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          color: group.color,
          fontWeight: FontWeight.w700,
          fontFamily: AppTypography.fontFamilyHeadings,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots(this.difficulty, {required this.tokens});
  final Difficulty difficulty;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < difficulty.level
                ? difficulty.color
                : tokens.textMuted.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
