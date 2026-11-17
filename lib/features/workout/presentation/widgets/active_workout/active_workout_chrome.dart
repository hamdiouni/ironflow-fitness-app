import 'dart:async';
import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/l10n/app_localizations.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';

/// Empty-state prompt shown inside an active workout before exercises are added.
class WorkoutEmptyExerciseHint extends StatelessWidget {
  const WorkoutEmptyExerciseHint({super.key, required this.onAddExercise});
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppStateView.empty(
          title: 'NO EXERCISES YET',
          message: 'Add exercises to this workout to begin logging sets.',
          actionLabel: '+ ADD EXERCISE',
          onAction: onAddExercise,
        ),
      ),
    );
  }
}

/// Primary finish button displayed at the bottom of the active workout layout.
class FinishWorkoutButton extends StatelessWidget {
  const FinishWorkoutButton({
    super.key,
    required this.enabled,
    required this.onFinish,
  });

  final bool enabled;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AppButton(
          label: (AppLocalizations.of(context)?.finishWorkout ??
                  'FINISH WORKOUT')
              .toUpperCase(),
          variant: AppButtonVariant.primary,
          isFullWidth: true,
          onPressed: enabled ? onFinish : null,
        ),
      ),
    );
  }
}

/// Live tabular elapsed timer badge shown in the active workout AppBar.
class WorkoutElapsedBadge extends StatefulWidget {
  const WorkoutElapsedBadge({
    super.key,
    required this.startTime,
    required this.tokens,
  });

  final DateTime startTime;
  final AppThemeTokens tokens;

  @override
  State<WorkoutElapsedBadge> createState() => _WorkoutElapsedBadgeState();
}

class _WorkoutElapsedBadgeState extends State<WorkoutElapsedBadge> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startTime);
    final totalSecs = elapsed.isNegative ? 0 : elapsed.inSeconds;
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');

    return Container(
      key: const Key('active_workout_elapsed_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.tokens.panel,
        borderRadius: BorderRadius.circular(widget.tokens.radiusSm),
        border: Border.all(
          color: widget.tokens.cyanAccent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        '$mins:$secs',
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: widget.tokens.cyanAccent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Compact session scoreboard panel rendered in the wide desktop sidebar.
class SessionScoreboardPanel extends StatelessWidget {
  const SessionScoreboardPanel({
    super.key,
    required this.exerciseCount,
    required this.workingSets,
    required this.volumeLabel,
    required this.tokens,
  });

  final int exerciseCount;
  final int workingSets;
  final String volumeLabel;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION SUMMARY',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ScoreStat(
                  label: 'EXERCISES',
                  value: '$exerciseCount',
                  tokens: tokens,
                ),
              ),
              Expanded(
                child: _ScoreStat(
                  label: 'SETS',
                  value: '$workingSets',
                  tokens: tokens,
                ),
              ),
              Expanded(
                child: _ScoreStat(
                  label: 'VOLUME',
                  value: volumeLabel,
                  tokens: tokens,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Hint box listing desktop keyboard shortcuts in the wide workout sidebar.
class KeyboardShortcutsHint extends StatelessWidget {
  const KeyboardShortcutsHint({super.key, required this.tokens});
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Text(
        'Shortcuts: Alt+L Log set · Alt+R Rest timer · Alt+= / Alt+- Weight step',
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 11,
          color: tokens.textSecondary,
        ),
      ),
    );
  }
}

/// Connector button rendered between consecutive exercises allowing lifters
/// to link or unlink them as a superset (Wave 8.3, ADR-004).
class SupersetConnectorDivider extends StatelessWidget {
  const SupersetConnectorDivider({
    super.key,
    required this.isLinked,
    required this.onToggle,
  });

  final bool isLinked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isLinked
                ? tokens.warning.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(
              color: isLinked
                  ? tokens.warning
                  : tokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLinked ? Icons.link_off : Icons.link,
                size: 14,
                color: isLinked ? tokens.warning : tokens.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                isLinked ? 'Linked Superset · Tap to Unlink' : 'Link as Superset',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.displayFontFamily,
                  color: isLinked ? tokens.warning : tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
