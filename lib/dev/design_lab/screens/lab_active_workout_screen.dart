import 'package:flutter/material.dart';

import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/design_lab_widgets.dart';

/// Active workout preview comparing a scannable table + sticky rest countdown bar
/// against the truncated AppBar & tall stacked cards in the current app.
class LabActiveWorkoutScreen extends StatelessWidget {
  const LabActiveWorkoutScreen({
    super.key,
    required this.tokens,
    required this.isWide,
  });

  final LabTokens tokens;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: isWide
              ? Padding(
                  padding: EdgeInsets.all(tokens.pagePadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ListView(
                          children: [
                            for (final ex in LabFakeData.activeExercises) ...[
                              _buildExerciseCard(ex),
                              SizedBox(height: tokens.sectionGap),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: tokens.sectionGap),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildSessionOverviewCard(),
                            SizedBox(height: tokens.sectionGap),
                            _buildShortcutCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(tokens.pagePadding),
                  children: [
                    for (final ex in LabFakeData.activeExercises) ...[
                      _buildExerciseCard(ex),
                      SizedBox(height: tokens.sectionGap),
                    ],
                  ],
                ),
        ),
        _buildStickyRestBar(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.pagePadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_back_rounded, color: tokens.textPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upper Body',
                  style: tokens.headingStyle(17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '24:18 • 2/6 sets • 2,120 kg volume',
                  style: tokens.labelStyle(11, color: tokens.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.raised,
              borderRadius: BorderRadius.circular(tokens.buttonRadius),
              border: Border.all(color: tokens.border),
            ),
            child: Text('kg', style: tokens.numberStyle(12)),
          ),
          const SizedBox(width: 8),
          LabPrimaryButton(
            tokens: tokens,
            label: 'Finish',
            compact: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(LabActiveExercise exercise) {
    final isKinetic = tokens.direction == LabDirection.kineticBlock;
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tokens.raised,
                  borderRadius: BorderRadius.circular(tokens.buttonRadius),
                ),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: tokens.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: tokens.headingStyle(16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      exercise.targetSummary,
                      style: tokens.bodyStyle(
                        12,
                        weight: FontWeight.w400,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              LabTag(tokens: tokens, label: exercise.muscle, color: tokens.secondaryAccent),
            ],
          ),
          const SizedBox(height: 12),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('SET', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('PREVIOUS', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('KG', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('REPS', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('DONE', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 8),
          for (final set in exercise.sets)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: set.isActiveRow
                    ? tokens.accent.withValues(alpha: tokens.isDark ? 0.14 : 0.1)
                    : set.completed
                        ? tokens.success.withValues(alpha: tokens.isDark ? 0.1 : 0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(tokens.buttonRadius),
                border: set.isActiveRow
                    ? Border.all(color: tokens.accent.withValues(alpha: 0.6))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      set.typeLabel == 'W' ? 'W' : '${set.number}',
                      style: tokens.numberStyle(
                        isKinetic ? 17 : 14,
                        color: set.typeLabel == 'W'
                            ? tokens.warning
                            : tokens.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      set.previous,
                      style: tokens.bodyStyle(
                        12,
                        weight: FontWeight.w500,
                        color: tokens.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.raised,
                        borderRadius: BorderRadius.circular(
                          tokens.buttonRadius == 999 ? 10 : tokens.buttonRadius,
                        ),
                      ),
                      child: Text(
                        set.weight,
                        style: tokens.numberStyle(isKinetic ? 16 : 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.raised,
                        borderRadius: BorderRadius.circular(
                          tokens.buttonRadius == 999 ? 10 : tokens.buttonRadius,
                        ),
                      ),
                      child: Text(
                        set.reps,
                        style: tokens.numberStyle(isKinetic ? 16 : 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 40,
                    height: 34,
                    decoration: BoxDecoration(
                      color: set.completed
                          ? tokens.success
                          : set.isActiveRow
                              ? tokens.accent
                              : tokens.raised,
                      borderRadius: BorderRadius.circular(
                        tokens.buttonRadius == 999 ? 10 : tokens.buttonRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: set.completed || set.isActiveRow
                          ? tokens.onAccent
                          : tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          if (exercise.sets.any((s) => s.isActiveRow)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _StepChip(tokens: tokens, label: '-2.5 kg'),
                const SizedBox(width: 6),
                _StepChip(tokens: tokens, label: '+2.5 kg'),
                const Spacer(),
                Text(
                  '+ Add Set',
                  style: tokens.bodyStyle(12, weight: FontWeight.w700, color: tokens.accent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionOverviewCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session Scoreboard', style: tokens.headingStyle(16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EST. 1RM', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    Text('102.5 kg', style: tokens.numberStyle(24, color: tokens.accent)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SETS LEFT', style: tokens.labelStyle(10, color: tokens.textMuted)),
                    Text('4 / 6', style: tokens.numberStyle(24)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Keyboard Shortcuts', style: tokens.headingStyle(15)),
          const SizedBox(height: 8),
          for (final item in const [
            ('Space / Enter', 'Complete active set'),
            ('R', 'Toggle or skip rest timer'),
            ('+ / -', 'Adjust weight by 2.5 kg'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  LabTag(tokens: tokens, label: item.$1, color: tokens.secondaryAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: tokens.bodyStyle(12, color: tokens.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyRestBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.pagePadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: tokens.raised,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: tokens.secondaryAccent),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rest', style: tokens.bodyStyle(12, color: tokens.textSecondary)),
                  const SizedBox(width: 8),
                  Text('01:15', style: tokens.numberStyle(20, color: tokens.secondaryAccent)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepChip(tokens: tokens, label: '-15s'),
                const SizedBox(width: 6),
                _StepChip(tokens: tokens, label: '+30s'),
                const SizedBox(width: 8),
                Text(
                  'Skip',
                  style: tokens.bodyStyle(13, weight: FontWeight.w700, color: tokens.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.tokens, required this.label});

  final LabTokens tokens;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(
          tokens.direction == LabDirection.kineticBlock ? 4 : 999,
        ),
        border: Border.all(color: tokens.border),
      ),
      child: Text(label, style: tokens.numberStyle(12)),
    );
  }
}
