import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewProgressScreen extends StatefulWidget {
  final DesignTokens tokens;

  const PreviewProgressScreen({
    super.key,
    required this.tokens,
  });

  @override
  State<PreviewProgressScreen> createState() => _PreviewProgressScreenState();
}

class _PreviewProgressScreenState extends State<PreviewProgressScreen> {
  int _selectedRange = 1; // 1M

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANALYTICS',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: tokens.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Body & Lifts',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.chipRadius),
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: Icon(Icons.tune_rounded, color: tokens.textSecondary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Range Selector
              Row(
                children: [
                  _buildRangePill(tokens, 0, '1W'),
                  const SizedBox(width: 8),
                  _buildRangePill(tokens, 1, '1M'),
                  const SizedBox(width: 8),
                  _buildRangePill(tokens, 2, '3M'),
                  const SizedBox(width: 8),
                  _buildRangePill(tokens, 3, '1Y'),
                ],
              ),
              const SizedBox(height: 20),

              // Bento Grid - Hero Card: Weight Trend (Archetype 8)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BODY WEIGHT',
                          style: TextStyle(
                            fontFamily: tokens.displayFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: tokens.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tokens.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(tokens.chipRadius),
                          ),
                          child: Text(
                            '-2.6 kg (30d)',
                            style: TextStyle(
                              color: tokens.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedCountUpText(
                          targetValue: 79.8,
                          decimalPlaces: 1,
                          style: TextStyle(
                            fontFamily: tokens.displayFont,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'kg',
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Target: 78.0 kg',
                          style: TextStyle(
                            color: tokens.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Custom Sparkline / Trend visualization
                    SizedBox(
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(FakeData.weightTrend.length, (index) {
                          final val = FakeData.weightTrend[index];
                          // Normalizing height
                          final minVal = 79.0;
                          final maxVal = 83.0;
                          final fraction = ((val - minVal) / (maxVal - minVal)).clamp(0.1, 1.0);
                          final isLatest = index == FakeData.weightTrend.length - 1;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    val.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isLatest ? FontWeight.w700 : FontWeight.w500,
                                      color: isLatest ? tokens.accent : tokens.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: fraction * 60,
                                    decoration: BoxDecoration(
                                      color: isLatest ? tokens.accent : tokens.elevated,
                                      borderRadius: BorderRadius.circular(tokens.chipRadius),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    FakeData.weightDates[index].split(' ')[1],
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: tokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Bento Row 1: Split tiles
              Row(
                children: [
                  // Consistency tile
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.cardRadius),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.bolt, color: tokens.warning, size: 24),
                          const SizedBox(height: 12),
                          Text(
                            'CONSISTENCY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: tokens.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '14 Days',
                            style: TextStyle(
                              fontFamily: tokens.displayFont,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '94% on plan',
                            style: TextStyle(fontSize: 12, color: tokens.success, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Strength Index tile
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.cardRadius),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.fitness_center, color: tokens.accent, size: 24),
                          const SizedBox(height: 12),
                          Text(
                            'BENCH 1RM EST.',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: tokens.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '125 kg',
                            style: TextStyle(
                              fontFamily: tokens.displayFont,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+5.5 kg this block',
                            style: TextStyle(fontSize: 12, color: tokens.accent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // PR Milestones List
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECENT RECORDS',
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...FakeData.summaryPRs.map((pr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events, size: 16, color: tokens.warning),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pr,
                                style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangePill(DesignTokens tokens, int index, String label) {
    final isSelected = _selectedRange == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRange = index),
      child: AnimatedContainer(
        duration: tokens.durationQuick,
        curve: tokens.curveQuick,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tokens.accent : tokens.panel,
          borderRadius: BorderRadius.circular(tokens.chipRadius),
          border: Border.all(color: isSelected ? tokens.accent : tokens.borderSubtle),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? tokens.onAccent : tokens.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
