import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewExerciseDetailScreen extends StatefulWidget {
  final DesignTokens tokens;

  const PreviewExerciseDetailScreen({
    super.key,
    required this.tokens,
  });

  @override
  State<PreviewExerciseDetailScreen> createState() => _PreviewExerciseDetailScreenState();
}

class _PreviewExerciseDetailScreenState extends State<PreviewExerciseDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AnimatedScaleButton(
                    onPressed: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Icon(Icons.arrow_back, color: tokens.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'EXERCISE GUIDE',
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: tokens.accent,
                      ),
                    ),
                  ),
                  AnimatedScaleButton(
                    onPressed: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Icon(Icons.bookmark_border, color: tokens.textPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Hero (Archetype 10)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: tokens.elevated,
                        borderRadius: BorderRadius.circular(tokens.cardRadius),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(tokens.cardRadius),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      tokens.elevated.withValues(alpha: 0.3),
                                      tokens.panel,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: tokens.accent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: tokens.accent.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.play_arrow_rounded, color: tokens.onAccent, size: 36),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Form Execution (0:45)',
                                style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tokens.canvas.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(tokens.chipRadius),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.hd_outlined, size: 14, color: tokens.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    '1080p 60fps',
                                    style: TextStyle(fontSize: 10, color: tokens.textSecondary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Exercise Title & Chips
                    Text(
                      FakeData.activeExerciseName,
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(tokens, 'Chest', tokens.accent, tokens.onAccent),
                        _buildBadge(tokens, 'Barbell', tokens.elevated, tokens.textPrimary),
                        _buildBadge(tokens, 'Compound', tokens.elevated, tokens.textSecondary),
                        _buildBadge(tokens, 'Intermediate', tokens.elevated, tokens.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Segmented Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.chipRadius),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          _buildTabItem(tokens, 0, 'Steps'),
                          _buildTabItem(tokens, 1, 'Key Cues'),
                          _buildTabItem(tokens, 2, 'History'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab Content
                    if (_selectedTabIndex == 0) ...[
                      _buildStepCard(tokens, 1, 'Setup & Grip', 'Lie flat on bench, eyes directly under bar. Grip slightly wider than shoulder width with thumbs wrapped.'),
                      _buildStepCard(tokens, 2, 'Unrack & Settle', 'Inhale deep, pinch shoulder blades together, brace core, and unrack with straight wrists.'),
                      _buildStepCard(tokens, 3, 'Controlled Descent', 'Lower the bar over 2-3 seconds until light contact at lower sternum, elbows at 45° angle.'),
                      _buildStepCard(tokens, 4, 'Drive & Lockout', 'Drive feet through the floor, press bar upwards in slight arc to starting position. Exhale at apex.'),
                    ] else if (_selectedTabIndex == 1) ...[
                      _buildCueCard(tokens, Icons.check_circle_outline, 'Scapula Retraction', 'Keep shoulder blades squeezed together against the bench throughout the rep to protect rotator cuffs.', tokens.success),
                      _buildCueCard(tokens, Icons.check_circle_outline, 'Leg Drive', 'Plant heels firmly into the floor creating whole-body tension without lifting hips.', tokens.success),
                      _buildCueCard(tokens, Icons.warning_amber_rounded, 'Elbow Flare Avoidance', 'Do not flare elbows to 90 degrees; maintain a natural 45 to 70 degree tucked angle.', tokens.warning),
                    ] else ...[
                      _buildHistoryCard(tokens, 'Oct 28', '100 kg × 8 reps', 'PR +5 kg', tokens.accent),
                      _buildHistoryCard(tokens, 'Oct 24', '95 kg × 8 reps', 'Target Hit', tokens.textSecondary),
                      _buildHistoryCard(tokens, 'Oct 20', '95 kg × 7 reps', 'Standard', tokens.textMuted),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border(top: BorderSide(color: tokens.borderSubtle)),
              ),
              child: AnimatedScaleButton(
                onPressed: () {},
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: tokens.onAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Current Routine',
                        style: TextStyle(
                          color: tokens.onAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
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

  Widget _buildBadge(DesignTokens tokens, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tokens.chipRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTabItem(DesignTokens tokens, int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: tokens.durationQuick,
          curve: tokens.curveQuick,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? tokens.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.chipRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? tokens.onAccent : tokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(DesignTokens tokens, int step, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tokens.elevated,
              borderRadius: BorderRadius.circular(tokens.chipRadius),
              border: Border.all(color: tokens.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: TextStyle(
                fontFamily: tokens.displayFont,
                color: tokens.accent,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCueCard(DesignTokens tokens, IconData icon, String title, String body, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(DesignTokens tokens, String date, String stat, String tag, Color tagColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                date,
                style: TextStyle(color: tokens.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Text(
                stat,
                style: TextStyle(color: tokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(tokens.chipRadius),
            ),
            child: Text(
              tag,
              style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
