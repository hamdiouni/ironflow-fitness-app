import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/splits/entities/hybrid_split.dart';
import '../../domain/splits/entities/split.dart';
import '../../domain/splits/services/split_catalog.dart';
import '../../domain/splits/services/split_schedule_builder.dart';
import '../providers/active_program_providers.dart';
import '../widgets/split_generator/days_stepper.dart';
import '../widgets/split_generator/guidance_badge.dart';
import '../widgets/split_generator/hybrid_mode_selector.dart';
import '../widgets/split_generator/muscle_frequency_card.dart';
import '../widgets/split_generator/schedule_day_preview.dart';
import '../widgets/split_generator/split_card.dart';

enum SplitCategory {
  standard,
  hybrids,
  custom,
}

enum PreviewMode {
  schedule,
  frequency,
}

/// Dynamic Sci-Fi Split Protocol Generator screen.
/// Allows full freedom to pick any split, hybrid mode, days 1..7,
/// preview live schedule & muscle frequency telemetry, customize exercises,
/// and save with instant Undo capability.
class ProgramSelectionScreen extends ConsumerStatefulWidget {
  const ProgramSelectionScreen({super.key});

  @override
  ConsumerState<ProgramSelectionScreen> createState() => _ProgramSelectionScreenState();
}

class _ProgramSelectionScreenState extends ConsumerState<ProgramSelectionScreen> {
  static const _builder = SplitScheduleBuilder();

  SplitCategory _category = SplitCategory.standard;
  PreviewMode _previewMode = PreviewMode.schedule;

  late Split _selectedSplit;
  int _daysPerWeek = 4;
  HybridMode _hybridMode = HybridMode.combinedCycle;

  WorkoutProgram? _cachedProgram;
  bool _initialized = false;

  final Map<int, List<ProgramExercise>> _customizedExercises = {};

  @override
  void initState() {
    super.initState();
    _selectedSplit = SplitCatalog.pushPullLegs;
  }

  void _syncInitialProfile(UserProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _daysPerWeek = profile.workoutDaysPerWeek.clamp(1, 7);
    _selectedSplit = SplitCatalog.getRecommendedSplitForDays(_daysPerWeek);
    _rebuildProgram(profile);
  }

  void _rebuildProgram(UserProfile profile) {
    Split splitToBuild = _selectedSplit;
    if (_selectedSplit is HybridSplit) {
      splitToBuild = (_selectedSplit as HybridSplit).copyWithMode(_hybridMode);
    }

    final rawProgram = _builder.buildProgram(
      split: splitToBuild,
      daysPerWeek: _daysPerWeek,
      profile: profile,
    );

    // Apply any local exercise customizations
    final updatedDays = rawProgram.days.map((day) {
      if (_customizedExercises.containsKey(day.dayNumber)) {
        return day.copyWith(exercises: _customizedExercises[day.dayNumber]!);
      }
      return day;
    }).toList();

    _cachedProgram = rawProgram.copyWith(days: updatedDays);
  }

  void _handleSplitSelected(Split split, UserProfile profile) {
    setState(() {
      _selectedSplit = split;
      _customizedExercises.clear();
      _rebuildProgram(profile);
    });
  }

  void _handleDaysChanged(int days, UserProfile profile) {
    setState(() {
      _daysPerWeek = days;
      _rebuildProgram(profile);
    });
  }

  void _handleHybridModeChanged(HybridMode mode, UserProfile profile) {
    setState(() {
      _hybridMode = mode;
      _rebuildProgram(profile);
    });
  }

  void _handleExerciseSwapped(
    int dayIndex,
    int exerciseIndex,
    String newExerciseName,
    UserProfile profile,
  ) {
    if (_cachedProgram == null) return;
    final day = _cachedProgram!.days[dayIndex];
    final updatedList = List<ProgramExercise>.from(day.exercises);
    final oldEx = updatedList[exerciseIndex];
    final oldName = oldEx.exerciseName;
    updatedList[exerciseIndex] = oldEx.copyWith(exerciseName: newExerciseName);

    setState(() {
      _customizedExercises[day.dayNumber] = updatedList;
      _rebuildProgram(profile);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swapped $oldName for $newExerciseName'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.amberAccent,
            onPressed: () {
              if (!mounted) return;
              final currentList = List<ProgramExercise>.from(
                _customizedExercises[day.dayNumber] ?? day.exercises,
              );
              currentList[exerciseIndex] = oldEx;
              setState(() {
                _customizedExercises[day.dayNumber] = currentList;
                _rebuildProgram(profile);
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _applyProgram(
    BuildContext context,
    WorkoutProgram program,
    UserProfile profile,
  ) async {
    final activeProgram = ref.read(activeProgramProvider).value;
    if (activeProgram != null) {
      final tokens = AppThemeTokens.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: tokens.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            side: BorderSide(color: tokens.borderSubtle, width: 1),
          ),
          title: Text(
            'CHANGE ACTIVE PROTOCOL?',
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyHeadings,
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          content: Text(
            'This will replace "${activeProgram.program.name}" with "${program.name}". Your past workout history is safely saved.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyBody,
              color: tokens.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              key: const Key('cancel_replace_program_btn'),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('CANCEL', style: TextStyle(color: tokens.textMuted)),
            ),
            TextButton(
              key: const Key('confirm_replace_program_btn'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'REPLACE',
                style: TextStyle(color: tokens.cyanAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final activeNotifier = ref.read(activeProgramProvider.notifier);
    await activeNotifier.setActiveProgram(program, archivePrevious: true);

    // Sync workout days to user profile if split frequency changed
    if (program.daysPerWeek != profile.workoutDaysPerWeek) {
      try {
        final userId = ref.read(authNotifierProvider).user?.id;
        final updatedProfile = profile.copyWith(workoutDaysPerWeek: program.daysPerWeek);
        final storage = ref.read(userProfileStorageProvider);
        await storage.saveProfile(updatedProfile, userId: userId);
        ref.invalidate(userProfileProvider);
      } catch (_) {}
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Protocol initialized: ${program.name}'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () async {
            final restored = await activeNotifier.undoProgramChange();
            if (context.mounted && restored) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Previous protocol restored.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ),
    );

    _navigateBack(context);
  }

  void _navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        context.go(AppRoutes.workout);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    final profile = userProfileAsync.value ??
        const UserProfile(
          goal: FitnessGoal.gainMuscle,
          age: 26,
          weightKg: 75,
          heightCm: 178,
          fitnessLevel: FitnessLevel.intermediate,
          equipment: EquipmentType.gym,
          workoutDaysPerWeek: 4,
          budget: BudgetLevel.medium,
          sex: BiologicalSex.male,
        );

    _syncInitialProfile(profile);

    if (_cachedProgram == null) {
      _rebuildProgram(profile);
    }

    final guidance = _selectedSplit.getScheduleGuidance(_daysPerWeek, profile.fitnessLevel);
    final frequencyReport = _builder.computeFrequencyReport(
      split: _selectedSplit is HybridSplit
          ? (_selectedSplit as HybridSplit).copyWithMode(_hybridMode)
          : _selectedSplit,
      daysPerWeek: _daysPerWeek,
    );

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tokens.textPrimary, size: 20),
          onPressed: () => _navigateBack(context),
        ),
        title: Text(
          'PROTOCOL GENERATOR',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFamily: AppTypography.fontFamilyHeadings,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                cacheExtent: 3000,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Category Segmented Tabs
                  _buildCategoryTabs(tokens, profile),
                  const SizedBox(height: 14),

                  // Split Cards List
                  ..._buildSplitCards(profile),
                  const SizedBox(height: 14),

                  // Hybrid Mode Toggle if applicable
                  if (_selectedSplit.isHybrid) ...[
                    HybridModeSelector(
                      selectedMode: _hybridMode,
                      onModeChanged: (mode) => _handleHybridModeChanged(mode, profile),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Days Stepper (1..7)
                  DaysStepper(
                    daysPerWeek: _daysPerWeek,
                    onChanged: (days) => _handleDaysChanged(days, profile),
                  ),
                  const SizedBox(height: 10),

                  // Non-blocking Guidance Badge
                  if (guidance != null) ...[
                    SplitGuidanceBadge(message: guidance),
                    const SizedBox(height: 14),
                  ],

                  // Live Preview Segmented Header
                  _buildPreviewTabs(tokens),
                  const SizedBox(height: 12),

                  // Preview Content
                  if (_previewMode == PreviewMode.schedule)
                    ScheduleDayPreview(
                      program: _cachedProgram!,
                      equipment: profile.equipment,
                      onExerciseSwapped: (dayIdx, exIdx, newName) =>
                          _handleExerciseSwapped(dayIdx, exIdx, newName, profile),
                    )
                  else
                    MuscleFrequencyCard(report: frequencyReport),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Persistent Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border(top: BorderSide(color: tokens.borderSubtle)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('apply_protocol_btn'),
                  onPressed: _cachedProgram == null
                      ? null
                      : () => _applyProgram(context, _cachedProgram!, profile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                    ),
                    elevation: 4,
                    shadowColor: tokens.cyanAccent.withValues(alpha: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.black, size: 22),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'APPLY PROTOCOL',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppTypography.fontFamilyHeadings,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setCategory(SplitCategory category, UserProfile profile) {
    setState(() {
      _category = category;
      if (category == SplitCategory.hybrids && !_selectedSplit.isHybrid) {
        _selectedSplit = SplitCatalog.pplXArnold(mode: _hybridMode);
        _customizedExercises.clear();
        _rebuildProgram(profile);
      } else if (category == SplitCategory.standard && _selectedSplit.isHybrid) {
        _selectedSplit = SplitCatalog.pushPullLegs;
        _customizedExercises.clear();
        _rebuildProgram(profile);
      } else if (category == SplitCategory.custom && _selectedSplit != SplitCatalog.mixCustom) {
        _selectedSplit = SplitCatalog.mixCustom;
        _customizedExercises.clear();
        _rebuildProgram(profile);
      }
    });
  }

  Widget _buildCategoryTabs(AppThemeTokens tokens, UserProfile profile) {
    return Row(
      children: [
        _CategoryTabButton(
          title: 'STANDARD',
          isSelected: _category == SplitCategory.standard,
          tokens: tokens,
          onTap: () => _setCategory(SplitCategory.standard, profile),
        ),
        const SizedBox(width: 8),
        _CategoryTabButton(
          title: 'HYBRIDS',
          isSelected: _category == SplitCategory.hybrids,
          tokens: tokens,
          onTap: () => _setCategory(SplitCategory.hybrids, profile),
        ),
        const SizedBox(width: 8),
        _CategoryTabButton(
          title: 'MIX / CUSTOM',
          isSelected: _category == SplitCategory.custom,
          tokens: tokens,
          onTap: () => _setCategory(SplitCategory.custom, profile),
        ),
      ],
    );
  }

  List<Widget> _buildSplitCards(UserProfile profile) {
    final List<Split> splits;
    switch (_category) {
      case SplitCategory.standard:
        splits = [
          SplitCatalog.pushPullLegs,
          SplitCatalog.upperLower,
          SplitCatalog.fullBody,
          SplitCatalog.arnoldSplit,
        ];
        break;
      case SplitCategory.hybrids:
        splits = [
          SplitCatalog.pplXArnold(mode: _hybridMode),
          SplitCatalog.arnoldXUpperLower(mode: _hybridMode),
          SplitCatalog.pplXUpperLower(mode: _hybridMode),
        ];
        break;
      case SplitCategory.custom:
        splits = [
          SplitCatalog.mixCustom,
          SplitCatalog.createDynamicHybrid(
            splitA: SplitCatalog.fullBody,
            splitB: SplitCatalog.arnoldSplit,
            mode: _hybridMode,
          ),
        ];
        break;
    }

    return splits.map((s) {
      final isSelected = _selectedSplit.id == s.id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SplitSelectionCard(
          split: s,
          isSelected: isSelected,
          onTap: () => _handleSplitSelected(s, profile),
        ),
      );
    }).toList();
  }

  Widget _buildPreviewTabs(AppThemeTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              key: const Key('preview_mode_schedule'),
              onTap: () => setState(() => _previewMode = PreviewMode.schedule),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _previewMode == PreviewMode.schedule
                      ? tokens.cyanAccent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(
                    color: _previewMode == PreviewMode.schedule
                        ? tokens.cyanAccent
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  'SCHEDULE MATRIX',
                  style: TextStyle(
                    color: _previewMode == PreviewMode.schedule
                        ? tokens.cyanAccent
                        : tokens.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTypography.fontFamilyHeadings,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              key: const Key('preview_mode_frequency'),
              onTap: () => setState(() => _previewMode = PreviewMode.frequency),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _previewMode == PreviewMode.frequency
                      ? tokens.cyanAccent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(
                    color: _previewMode == PreviewMode.frequency
                        ? tokens.cyanAccent
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  'MUSCLE FREQUENCY',
                  style: TextStyle(
                    color: _previewMode == PreviewMode.frequency
                        ? tokens.cyanAccent
                        : tokens.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTypography.fontFamilyHeadings,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  const _CategoryTabButton({
    required this.title,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? tokens.cyanAccent.withValues(alpha: 0.18)
                : tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(
              color: isSelected ? tokens.cyanAccent : tokens.borderSubtle,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? tokens.cyanAccent : tokens.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
