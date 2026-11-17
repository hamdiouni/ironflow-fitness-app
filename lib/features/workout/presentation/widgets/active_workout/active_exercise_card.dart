import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/features/workout/data/exercise_video_map.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/shared/animations/set_completion_animation.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/shared/widgets/exercise_media_stage.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/plate_calculator_sheet.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/workout/domain/usecases/workout_metrics.dart';
import 'package:progression_tracker/features/workout/domain/services/strength_engine.dart';

class ActiveExerciseCard extends ConsumerStatefulWidget {
  const ActiveExerciseCard({
    super.key,
    required this.exercise,
    required this.isAnimating,
    required this.onAnimationComplete,
    required this.onLogSet,
    required this.onUpdateSetType,
    this.programExercise,
    this.weightUnit = WeightUnit.kg,
    this.isFocused = false,
    this.supersetLabel,
  });
  final Exercise exercise;
  final bool isAnimating;
  final VoidCallback onAnimationComplete;
  final Future<void> Function(int reps, double weight, [SetType type, int? rpe]) onLogSet;
  final Future<void> Function(int setIndex, SetType newType) onUpdateSetType;
  final ProgramExercise? programExercise;
  final WeightUnit weightUnit;
  final bool isFocused;
  final String? supersetLabel;
  @override
  ConsumerState<ActiveExerciseCard> createState() => ActiveExerciseCardState();
}

class ActiveExerciseCardState extends ConsumerState<ActiveExerciseCard> {
  final _repsController = TextEditingController(text: '8');
  final _weightController = TextEditingController(text: '0');
  final _rpeController = TextEditingController();
  bool _isRirMode = false;
  bool _isLogging = false;
  bool _showVideo = false;
  SetType _selectedSetType = SetType.normal;

  /// Triggers logging the currently entered set (used by keyboard shortcuts).
  Future<void> logCurrentSet() => _handleLogSet();

  /// Adjusts the entered weight in the active display unit by [delta].
  void stepWeight(double delta) {
    final current = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final next = (current + delta).clamp(0.0, 2000.0);
    setState(() {
      _weightController.text = next == next.roundToDouble()
          ? next.toInt().toString()
          : next.toStringAsFixed(1);
    });
  }

  @override
  void initState() {
    super.initState();
    final prog = widget.programExercise;
    if (prog != null) {
      if (prog.targetWeight != null && prog.targetWeight! > 0) {
        _weightController.text = prog.targetWeight!.toStringAsFixed(1);
      }
      final parsedReps = int.tryParse(prog.reps);
      if (parsedReps != null && parsedReps > 0) {
        _repsController.text = parsedReps.toString();
      }
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _rpeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final suggestionAsync = ref.watch(progressionSuggestionProvider(widget.exercise.name));
    final thumbUrl = ExerciseVideoMap.thumbnailUrl(widget.exercise.name);
    
    // Check if all suggested sets are completed
    final allSuggestedSetsCompleted = _checkAllSuggestedSetsCompleted();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showVideo = !_showVideo),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: thumbUrl,
                          width: 72,
                          height: 52,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            width: 72, height: 52,
                            color: tokens.panel,
                            child: Icon(Icons.fitness_center, color: tokens.kineticAccent, size: 22),
                          ),
                        ),
                        Container(
                          width: 72, height: 52,
                          color: Colors.black45,
                          child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.supersetLabel != null)
                            Container(
                              key: Key('superset_badge_${widget.exercise.id}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: tokens.warning.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(tokens.radiusXs),
                                border: Border.all(
                                  color: tokens.warning,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.supersetLabel!,
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: tokens.warning,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              widget.exercise.name,
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTypography.fontFamilyHeadings,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (_) {
                          final bestE1rm = E1rmEngine.bestForExercise(widget.exercise);
                          if (bestE1rm <= 0) return const SizedBox.shrink();
                          final displayE1rm = widget.weightUnit == WeightUnit.lb
                              ? WorkoutMetrics.fromCanonicalKg(bestE1rm, WeightUnit.lb)
                              : bestE1rm;
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'e1RM: ${displayE1rm.toStringAsFixed(1)} ${widget.weightUnit.label}',
                              style: TextStyle(
                                color: tokens.kineticAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTypography.fontFamilyHeadings,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      // Display program exercise suggestion if available
                      if (widget.programExercise != null) ...[
                        Text(
                          widget.programExercise!.targetWeight != null &&
                                  widget.programExercise!.targetWeight! > 0
                              ? 'Target: ${widget.programExercise!.targetWeight!.toStringAsFixed(1)}kg · ${widget.programExercise!.sets} × ${widget.programExercise!.reps}'
                              : 'Target: ${widget.programExercise!.sets} × ${widget.programExercise!.reps}',
                          style: TextStyle(
                            color: allSuggestedSetsCompleted ? tokens.kineticAccent : tokens.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamilyHeadings,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ] else ...[
                        suggestionAsync.when(
                          data: (s) => s != null ? Text(
                            s.isStagnant ? 'Stagnant — Try ${(s.suggestedWeight * 1.05).toStringAsFixed(1)}kg' : 'Target: ${s.suggestedWeight}kg × ${s.suggestedReps}',
                            style: TextStyle(
                              color: s.isStagnant ? tokens.warning : tokens.kineticAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ) : const SizedBox.shrink(),
                          loading: () => SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: tokens.kineticAccent),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.isAnimating) SetCompletionAnimation(onComplete: widget.onAnimationComplete),
              ],
            ),
            if (_showVideo) ...[
              const SizedBox(height: 12),
              _VideoPreviewBanner(exerciseName: widget.exercise.name),
            ],
            if (widget.exercise.sets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.exercise.sets.asMap().entries.map((e) {
                  final setIndex = e.key;
                  final set = e.value;
                  final setNumber = setIndex + 1;
                  final isSuggestedSetCompleted = widget.programExercise != null && setNumber <= widget.programExercise!.sets;
                  final setType = set.type;
                  final typeColor = switch (setType) {
                    SetType.warmup => tokens.cyanAccent,
                    SetType.normal => isSuggestedSetCompleted ? tokens.kineticAccent : tokens.textSecondary,
                    SetType.drop => tokens.warning,
                    SetType.failure => tokens.error,
                  };
                  final rpeText = set.rpe != null
                      ? (_isRirMode ? ' • ${10 - set.rpe!} RIR' : ' • @${set.rpe} RPE')
                      : '';
                  
                  return Tooltip(
                    message: 'Tap to cycle set type (${setType.label})',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      onTap: () async {
                        await AppHaptics.shared.selectionChanged();
                        await widget.onUpdateSetType(setIndex, setType.next);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
                              ),
                              child: Text(
                                setType.shortCode,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: AppTypography.displayFontFamily,
                                ),
                              ),
                            ),
                            Text(
                              widget.weightUnit == WeightUnit.kg
                                  ? 'SET $setNumber: ${set.weight}KG × ${set.reps}$rpeText'
                                  : 'SET $setNumber: ${WorkoutMetrics.fromCanonicalKg(set.weight, WeightUnit.lb).toStringAsFixed(1)}LB × ${set.reps}$rpeText',
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTypography.fontFamilyHeadings,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),

            // ── Set Type Selector Row ─────────────────────────────────
            Row(
              children: SetType.values.map((type) {
                final isSelected = _selectedSetType == type;
                final color = switch (type) {
                  SetType.warmup => tokens.cyanAccent,
                  SetType.normal => tokens.kineticAccent,
                  SetType.drop => tokens.warning,
                  SetType.failure => tokens.error,
                };
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        setState(() {
                          _selectedSetType = type;
                          if (type == SetType.drop &&
                              widget.exercise.sets.isNotEmpty) {
                            final lastSet = widget.exercise.sets.last;
                            final planned = DropSetPlanner.plan(
                              startWeight: lastSet.weight,
                              drops: 1,
                            );
                            if (planned.isNotEmpty) {
                              final display = widget.weightUnit == WeightUnit.lb
                                  ? WorkoutMetrics.fromCanonicalKg(
                                      planned.first,
                                      WeightUnit.lb,
                                    )
                                  : planned.first;
                              _weightController.text =
                                  display.toStringAsFixed(1);
                            }
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.18) : tokens.elevated,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: isSelected
                              ? Border.all(color: color, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            type.label.toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: 0.3,
                              color: isSelected ? color : tokens.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // ── Inputs Row (Reps, Weight, RPE/RIR, Plate Calc, Log Set) ─────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                final rpeStack = Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _NumberField(
                      controller: _rpeController,
                      label: _isRirMode ? 'RIR' : 'RPE',
                      tokens: tokens,
                    ),
                    Positioned(
                      right: 4,
                      child: InkWell(
                        onTap: () {
                          AppHaptics.shared.selectionChanged();
                          setState(() {
                            _isRirMode = !_isRirMode;
                            final val = int.tryParse(_rpeController.text.trim());
                            if (val != null) {
                              final converted = (10 - val).clamp(0, 10);
                              _rpeController.text = converted.toString();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: tokens.cyanAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(tokens.radiusPill),
                            border: Border.all(
                              color: tokens.cyanAccent.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            _isRirMode ? 'RIR' : 'RPE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: tokens.cyanAccent,
                              fontFamily: AppTypography.displayFontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                final plateCalcBtn = IconButton(
                  tooltip: 'Plate Calculator',
                  icon: Icon(Icons.calculate_outlined, color: tokens.kineticAccent, size: 24),
                  onPressed: () {
                    final currentWeight = double.tryParse(_weightController.text) ?? 60.0;
                    PlateCalculatorSheet.show(
                      context,
                      initialWeight: currentWeight,
                      initialUnit: widget.weightUnit == WeightUnit.lb
                          ? PlateUnit.lb
                          : PlateUnit.kg,
                      onApplyWeight: (calcWeight) {
                        setState(() {
                          _weightController.text = calcWeight == calcWeight.roundToDouble()
                              ? calcWeight.toInt().toString()
                              : calcWeight.toStringAsFixed(1);
                        });
                      },
                    );
                  },
                );

                final logSetBtn = SizedBox(
                  height: 48,
                  child: AppButton(
                    label: 'LOG SET',
                    variant: AppButtonVariant.primary,
                    isLoading: _isLogging,
                    onPressed: _isLogging ? null : _handleLogSet,
                  ),
                );

                final weightLabel = 'WEIGHT (${widget.weightUnit.label})';

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _NumberField(
                              controller: _repsController,
                              label: 'REPS',
                              tokens: tokens,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 6,
                            child: _NumberField(
                              controller: _weightController,
                              label: weightLabel,
                              isDecimal: true,
                              tokens: tokens,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(flex: 5, child: rpeStack),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          plateCalcBtn,
                          const SizedBox(width: 8),
                          Expanded(child: logSetBtn),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _NumberField(
                        controller: _repsController,
                        label: 'REPS',
                        tokens: tokens,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 6,
                      child: _NumberField(
                        controller: _weightController,
                        label: weightLabel,
                        isDecimal: true,
                        tokens: tokens,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(flex: 5, child: rpeStack),
                    const SizedBox(width: 4),
                    plateCalcBtn,
                    const SizedBox(width: 4),
                    logSetBtn,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Check if all suggested sets from the program exercise have been completed
  bool _checkAllSuggestedSetsCompleted() {
    if (widget.programExercise == null) return false;
    return widget.exercise.sets.length >= widget.programExercise!.sets;
  }

  Future<void> _handleLogSet() async {
    final reps = int.tryParse(_repsController.text.trim());
    final rawWeight = double.tryParse(_weightController.text.trim());
    final canonicalWeight =
        WorkoutMetrics.toCanonicalKg(rawWeight, widget.weightUnit);
    if (reps == null ||
        !WorkoutMetrics.isValidReps(reps) ||
        canonicalWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid reps and weight')),
      );
      return;
    }

    int? parsedRpe;
    final rpeText = _rpeController.text.trim();
    if (rpeText.isNotEmpty) {
      final val = int.tryParse(rpeText);
      if (val != null) {
        if (_isRirMode) {
          if (val >= 0 && val <= 9) {
            parsedRpe = 10 - val;
          }
        } else {
          if (val >= 1 && val <= 10) {
            parsedRpe = val;
          }
        }
      }
    }

    setState(() => _isLogging = true);
    try {
      await widget.onLogSet(reps, canonicalWeight, _selectedSetType, parsedRpe);
    } catch (e, s) {
      if (mounted) ErrorHandler.handleError(context, e, s);
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }
}

class _VideoPreviewBanner extends StatelessWidget {
  const _VideoPreviewBanner({required this.exerciseName});
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ExerciseMediaStage(
        exerciseName: exerciseName,
        onError: (error) {
          debugPrint('Video player error: $error');
        },
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.tokens,
    this.isDecimal = false,
  });

  final TextEditingController controller;
  final String label;
  final bool isDecimal;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: tokens.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: AppTypography.fontFamilyHeadings,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: tokens.textMuted,
          letterSpacing: 0.5,
        ),
        filled: true,
        fillColor: tokens.elevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
        ),
      ),
    );
  }
}
