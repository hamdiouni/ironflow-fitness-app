import 'package:flutter/material.dart';

import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/design_lab_widgets.dart';

class LabTodayScreen extends StatelessWidget {
  const LabTodayScreen({
    super.key,
    required this.tokens,
    required this.isWide,
    this.onStartWorkout,
    this.onOpenFuel,
  });

  final LabTokens tokens;
  final bool isWide;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onOpenFuel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.pagePadding),
      children: [
        _buildHeader(),
        SizedBox(height: tokens.sectionGap),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildTodayWorkoutCard(),
                    SizedBox(height: tokens.sectionGap),
                    _buildQuickActions(),
                    SizedBox(height: tokens.sectionGap),
                    _buildCoachCard(),
                  ],
                ),
              ),
              SizedBox(width: tokens.sectionGap),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildReadinessCard(),
                    SizedBox(height: tokens.sectionGap),
                    _buildFuelSummaryCard(),
                    SizedBox(height: tokens.sectionGap),
                    _buildConsistencyCard(),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _buildReadinessCard(),
          SizedBox(height: tokens.sectionGap),
          _buildTodayWorkoutCard(),
          SizedBox(height: tokens.sectionGap),
          _buildFuelSummaryCard(),
          SizedBox(height: tokens.sectionGap),
          _buildQuickActions(),
          SizedBox(height: tokens.sectionGap),
          _buildCoachCard(),
          SizedBox(height: tokens.sectionGap),
          _buildConsistencyCard(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: tokens.labelStyle(11, color: tokens.secondaryAccent),
              ),
              const SizedBox(height: 2),
              Text(
                LabFakeData.greeting,
                style: tokens.headingStyle(24),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        LabTag(
          tokens: tokens,
          label: '${LabFakeData.streakDays}d streak',
          color: tokens.warning,
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: tokens.raised,
          child: Icon(Icons.person_rounded, size: 18, color: tokens.textPrimary),
        ),
      ],
    );
  }

  Widget _buildReadinessCard() {
    return LabCard(
      tokens: tokens,
      child: Row(
        children: [
          LabRingGauge(
            tokens: tokens,
            progress: LabFakeData.readinessPercent / 100,
            centerText: '${LabFakeData.readinessPercent}%',
            color: tokens.success,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Muscle Recovery',
                        style: tokens.headingStyle(15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    LabTag(tokens: tokens, label: 'Ready', color: tokens.success),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  LabFakeData.readinessSummary,
                  style: tokens.bodyStyle(
                    13,
                    weight: FontWeight.w400,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutCard() {
    return LabCard(
      tokens: tokens,
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LabTag(tokens: tokens, label: 'Scheduled Today', color: tokens.accent),
              const Spacer(),
              Flexible(
                child: Text(
                  LabFakeData.programTitle,
                  style: tokens.labelStyle(11, color: tokens.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            LabFakeData.todayWorkoutName,
            style: tokens.headingStyle(21),
          ),
          const SizedBox(height: 4),
          Text(
            LabFakeData.todayWorkoutMeta,
            style: tokens.bodyStyle(
              13,
              weight: FontWeight.w500,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: LabPrimaryButton(
              tokens: tokens,
              label: 'Start Workout',
              icon: Icons.play_arrow_rounded,
              onPressed: onStartWorkout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelSummaryCard() {
    final pct = LabFakeData.caloriesConsumed / LabFakeData.caloriesTarget;
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Daily Nutrition', style: tokens.headingStyle(15)),
              const Spacer(),
              InkWell(
                onTap: onOpenFuel,
                child: Text(
                  'Open Fuel →',
                  style: tokens.bodyStyle(12, weight: FontWeight.w700, color: tokens.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              LabRingGauge(
                tokens: tokens,
                progress: pct,
                centerText: '${(pct * 100).round()}%',
                color: tokens.warning,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${LabFakeData.caloriesConsumed.round()}',
                            style: tokens.numberStyle(22),
                          ),
                          TextSpan(
                            text: ' / ${LabFakeData.caloriesTarget.round()} kcal',
                            style: tokens.bodyStyle(
                              13,
                              weight: FontWeight.w500,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        LabTag(
                          tokens: tokens,
                          label: 'P ${LabFakeData.proteinG.round()}g',
                          color: tokens.protein,
                        ),
                        LabTag(
                          tokens: tokens,
                          label: 'C ${LabFakeData.carbsG.round()}g',
                          color: tokens.carbs,
                        ),
                        LabTag(
                          tokens: tokens,
                          label: 'F ${LabFakeData.fatsG.round()}g',
                          color: tokens.fats,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: LabSecondaryButton(
            tokens: tokens,
            label: 'Quick Session',
            icon: Icons.add_rounded,
            onPressed: onStartWorkout,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LabSecondaryButton(
            tokens: tokens,
            label: 'Log Food',
            icon: Icons.restaurant_rounded,
            onPressed: onOpenFuel,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabTag(
            tokens: tokens,
            label: 'Training Coach',
            color: tokens.secondaryAccent,
          ),
          const SizedBox(height: 10),
          Text(LabFakeData.coachTitle, style: tokens.headingStyle(16)),
          const SizedBox(height: 6),
          Text(
            LabFakeData.coachMessage,
            style: tokens.bodyStyle(
              13,
              weight: FontWeight.w400,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          LabSecondaryButton(
            tokens: tokens,
            label: 'Ask Coach About Today',
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weekly Goal', style: tokens.headingStyle(15)),
              const Spacer(),
              Text(
                '${LabFakeData.weeklyCompleted} / ${LabFakeData.weeklyGoalTarget} workouts',
                style: tokens.numberStyle(14, color: tokens.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _DayDot(
                  tokens: tokens,
                  day: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                  done: i == 0 || i == 2 || i == 4,
                  today: i == 5,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.tokens,
    required this.day,
    required this.done,
    required this.today,
  });

  final LabTokens tokens;
  final String day;
  final bool done;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: done
                ? tokens.accent
                : today
                    ? tokens.raised
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: done
                  ? tokens.accent
                  : today
                      ? tokens.secondaryAccent
                      : tokens.border,
              width: today ? 1.5 : 1,
            ),
          ),
          child: done
              ? Icon(Icons.check_rounded, size: 16, color: tokens.onAccent)
              : null,
        ),
        const SizedBox(height: 4),
        Text(day, style: tokens.labelStyle(10, color: tokens.textMuted)),
      ],
    );
  }
}
