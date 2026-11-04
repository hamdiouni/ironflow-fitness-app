import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewWorkoutSummaryScreen extends StatelessWidget {
  final DesignTokens tokens;
  final VoidCallback? onDone;

  const PreviewWorkoutSummaryScreen({
    super.key,
    required this.tokens,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Celebratory Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tokens.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: tokens.success, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WORKOUT COMPLETE',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: tokens.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Session Summary',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Milestone Metric Cards (Stepped Highlights Archetype 3)
              Row(
                children: [
                  Expanded(child: _buildMetricTile(tokens, 'TIME', FakeData.summaryDuration)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricTile(tokens, 'VOLUME', FakeData.summaryVolume)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricTile(tokens, 'SETS', '${FakeData.summarySetsCompleted}')),
                ],
              ),
              const SizedBox(height: 20),

              // PR Highlight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  border: Border.all(color: tokens.warning.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.military_tech_rounded, color: tokens.warning, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${FakeData.summaryPRCount} Personal Records Broken',
                          style: TextStyle(
                            fontFamily: tokens.displayFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...FakeData.summaryPRs.map((pr) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: tokens.warning, shape: BoxShape.circle)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(pr, style: TextStyle(color: tokens.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recovery & Nutrition Next Step
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_rounded, color: tokens.accent, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Post-Workout Fuel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: tokens.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Log 40g protein within 2 hours to optimize synthesis.', style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Done Action
              AnimatedScaleButton(
                onPressed: onDone,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Save Session & Close',
                    style: TextStyle(color: tokens.onAccent, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(DesignTokens tokens, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tokens.textMuted, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: tokens.displayFont,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: tokens.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

