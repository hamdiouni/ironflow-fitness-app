import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/exercise_definition.dart';
import '../../../domain/splits/entities/muscle_frequency_report.dart';

/// Telemetry card rendering muscle frequency breakdown and volume distribution.
class MuscleFrequencyCard extends StatelessWidget {
  final MuscleFrequencyReport report;

  const MuscleFrequencyCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final entries = report.frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.radar_rounded,
                    color: tokens.cyanAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WEEKLY MUSCLE FREQUENCY',
                    style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      fontFamily: AppTypography.fontFamilyHeadings,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Text(
                  '${report.totalTrainingSessionsPerWeek} SESSIONS/WK',
                  style: TextStyle(
                    color: tokens.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTypography.fontFamilyHeadings,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...entries.map((entry) {
            final muscleGroup = entry.key;
            final muscleName = muscleGroup.displayName;
            final count = entry.value;
            final status = report.getStatus(muscleGroup);

            final (statusText, statusColor) = switch (status) {
              FrequencyStatus.optimal => ('OPTIMAL', tokens.success),
              FrequencyStatus.low => ('LOW', tokens.warning),
              FrequencyStatus.high => ('HIGH', tokens.violetAccent),
              FrequencyStatus.none => ('0x', tokens.textMuted),
            };

            final progress = (count / 4.0).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      muscleName,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: tokens.panel,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${count}x/wk',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 54,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTypography.fontFamilyHeadings,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
