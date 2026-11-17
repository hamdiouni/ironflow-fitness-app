import 'package:flutter/material.dart';

import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/design_lab_widgets.dart';

class LabProgressScreen extends StatelessWidget {
  const LabProgressScreen({
    super.key,
    required this.tokens,
    required this.isWide,
  });

  final LabTokens tokens;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.pagePadding),
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildTabStrip(),
        SizedBox(height: tokens.sectionGap),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSummaryRow(),
                    SizedBox(height: tokens.sectionGap),
                    _buildVolumeChartCard(),
                  ],
                ),
              ),
              SizedBox(width: tokens.sectionGap),
              Expanded(
                flex: 2,
                child: _buildPrListCard(),
              ),
            ],
          )
        else ...[
          _buildSummaryRow(),
          SizedBox(height: tokens.sectionGap),
          _buildVolumeChartCard(),
          SizedBox(height: tokens.sectionGap),
          _buildPrListCard(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress', style: tokens.headingStyle(24)),
        Text(
          'Strength trend, recovery map, weight & photos',
          style: tokens.bodyStyle(
            13,
            weight: FontWeight.w400,
            color: tokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabStrip() {
    const tabs = ['Lifts', 'Muscles', 'Weight', 'Photos'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: BorderRadius.circular(
          tokens.direction == LabDirection.kineticBlock ? 8 : 999,
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: i == 0 ? tokens.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    tokens.direction == LabDirection.kineticBlock ? 6 : 999,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: tokens.bodyFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: i == 0 ? tokens.onAccent : tokens.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _MetricBox(
            tokens: tokens,
            label: 'Workouts',
            value: '21',
            sub: 'Last 6 weeks',
            color: tokens.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricBox(
            tokens: tokens,
            label: 'Streak',
            value: '${LabFakeData.streakDays}d',
            sub: 'Best: 14d',
            color: tokens.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricBox(
            tokens: tokens,
            label: 'Goal Rate',
            value: '86%',
            sub: 'On target',
            color: tokens.success,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeChartCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weekly Volume Load', style: tokens.headingStyle(16)),
              const Spacer(),
              LabTag(tokens: tokens, label: '+36% vs W1', color: tokens.success),
            ],
          ),
          const SizedBox(height: 14),
          LabVolumeBars(tokens: tokens, points: LabFakeData.weeklyVolume),
        ],
      ),
    );
  }

  Widget _buildPrListCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Estimated 1RM', style: tokens.headingStyle(16)),
              const Spacer(),
              Text(
                '${LabFakeData.catalogExerciseCount} moves',
                style: tokens.labelStyle(11, color: tokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < LabFakeData.topLifts.length; i++) ...[
            if (i > 0) Divider(height: 16, color: tokens.border),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LabFakeData.topLifts[i].exercise,
                        style: tokens.bodyStyle(14, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        LabFakeData.topLifts[i].delta,
                        style: tokens.bodyStyle(
                          12,
                          weight: FontWeight.w500,
                          color: tokens.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  LabFakeData.topLifts[i].estimated1Rm,
                  style: tokens.numberStyle(17, color: tokens.accent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.tokens,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final LabTokens tokens;
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LabCard(
      tokens: tokens,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tokens.labelStyle(10, color: tokens.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: tokens.numberStyle(22, color: color)),
          const SizedBox(height: 2),
          Text(
            sub,
            style: tokens.bodyStyle(11, weight: FontWeight.w400, color: tokens.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
