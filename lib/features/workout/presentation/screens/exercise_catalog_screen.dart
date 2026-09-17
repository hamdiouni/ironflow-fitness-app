import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/exercise_definition.dart';
import '../providers/exercise_providers.dart';
import 'exercise_detail_screen.dart';

/// Exercise catalog with muscle-group tabs and search.
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
    (label: 'All',       group: null as MuscleGroup?),
    (label: 'Chest',     group: MuscleGroup.chest),
    (label: 'Back',      group: MuscleGroup.back),
    (label: 'Legs',      group: MuscleGroup.legs),
    (label: 'Shoulders', group: MuscleGroup.shoulders),
    (label: 'Arms',      group: MuscleGroup.arms),
    (label: 'Abs',       group: MuscleGroup.abs),
    (label: 'Glutes',    group: MuscleGroup.glutes),
    (label: 'Cardio',    group: MuscleGroup.cardio),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // FIX: use animation listener instead of addListener to catch tab changes
    // reliably — addListener fires on every animation frame, not just on settle.
    _tabController.animation?.addListener(_onTabAnimation);
  }

  int _lastTabIndex = 0;

  void _onTabAnimation() {
    final index = _tabController.index;
    if (index != _lastTabIndex) {
      _lastTabIndex = index;
      final group = _tabs[index].group;
      // Use post-frame to avoid calling setState during build
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
    final exercises = ref.watch(filteredExercisesProvider);
    final filter = ref.watch(exerciseFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      ref.read(exerciseFilterProvider.notifier).setQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: filter.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(exerciseFilterProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                ),
              ),
              // Muscle group tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: _tabs.map((t) {
                  final color = t.group?.color ?? theme.colorScheme.primary;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (t.group != null) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(t.label, style: const TextStyle(fontSize: 12)),
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
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _EquipChip(
                  label: 'Any',
                  selected: filter.equipment == null,
                  onTap: () => ref
                      .read(exerciseFilterProvider.notifier)
                      .setEquipment(null),
                ),
                ...Equipment.values.map((eq) => _EquipChip(
                      label: eq.displayName,
                      selected: filter.equipment == eq,
                      onTap: () => ref
                          .read(exerciseFilterProvider.notifier)
                          .setEquipment(filter.equipment == eq ? null : eq),
                    )),
              ],
            ),
          ),
          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${exercises.length} exercises',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          // Grid
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('No exercises found',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      return _ExerciseCard(
                        exercise: ex,
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
                            delay: Duration(milliseconds: index * 25),
                            duration: const Duration(milliseconds: 200),
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
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected
                  ? primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});
  final ExerciseDefinition exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
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
                placeholder: (_, __) => Container(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  child: Center(
                    child: Icon(Icons.fitness_center,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        size: 32),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  child: Center(
                    child: Icon(Icons.fitness_center,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        size: 32),
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MuscleTag(exercise.muscleGroup),
                      const Spacer(),
                      _DifficultyDots(exercise.difficulty),
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
  const _MuscleTag(this.group);
  final MuscleGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: group.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        group.displayName,
        style: TextStyle(
          fontSize: 10,
          color: group.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots(this.difficulty);
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < difficulty.level
                ? difficulty.color
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }
}
