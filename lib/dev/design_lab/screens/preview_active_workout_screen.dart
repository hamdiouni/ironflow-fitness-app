import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewActiveWorkoutScreen extends StatefulWidget {
  final DesignTokens tokens;
  final VoidCallback? onFinish;

  const PreviewActiveWorkoutScreen({
    super.key,
    required this.tokens,
    this.onFinish,
  });

  @override
  State<PreviewActiveWorkoutScreen> createState() => _PreviewActiveWorkoutScreenState();
}

class _PreviewActiveWorkoutScreenState extends State<PreviewActiveWorkoutScreen> {
  double _weight = FakeData.activeWeightKg;
  int _reps = FakeData.activeReps;
  bool _setDone = false;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textSecondary),
          onPressed: () {},
        ),
        title: Text(
          'Active Workout',
          style: TextStyle(
            fontFamily: tokens.displayFont,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: widget.onFinish,
              child: Text(
                'Finish',
                style: TextStyle(
                  color: tokens.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.cardRadius),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: tokens.elevated,
                              borderRadius: BorderRadius.circular(tokens.buttonRadius),
                            ),
                            child: Icon(Icons.fitness_center, color: tokens.accent, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FakeData.activeExerciseName,
                                  style: TextStyle(
                                    fontFamily: tokens.displayFont,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  FakeData.activeMuscleGroup,
                                  style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // FOCUS MODE: Current Active Set Card (Archetype 2)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.cardRadius),
                        border: Border.all(color: tokens.accent, width: 2.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SET ${FakeData.currentSetIndex} OF ${FakeData.totalSets}',
                                style: TextStyle(
                                  fontFamily: tokens.displayFont,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                  color: tokens.accent,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tokens.elevated,
                                  borderRadius: BorderRadius.circular(tokens.chipRadius),
                                ),
                                child: Text(
                                  'Target: 8 reps',
                                  style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Oversized Touch Controls (Weight & Reps)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('WEIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.textMuted)),
                                    const SizedBox(height: 8),
                                    QuantityStepper(
                                      value: _weight,
                                      step: 2.5,
                                      min: 0,
                                      max: 300,
                                      unit: 'kg',
                                      backgroundColor: tokens.elevated,
                                      foregroundColor: tokens.textPrimary,
                                      borderRadius: tokens.buttonRadius,
                                      onChanged: (v) => setState(() => _weight = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('REPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.textMuted)),
                                    const SizedBox(height: 8),
                                    QuantityStepper(
                                      value: _reps.toDouble(),
                                      step: 1,
                                      min: 1,
                                      max: 50,
                                      unit: '',
                                      backgroundColor: tokens.elevated,
                                      foregroundColor: tokens.textPrimary,
                                      borderRadius: tokens.buttonRadius,
                                      onChanged: (v) => setState(() => _reps = v.toInt()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Large Complete Set Action
                          AnimatedScaleButton(
                            onPressed: () => setState(() => _setDone = !_setDone),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _setDone ? tokens.success : tokens.accent,
                                borderRadius: BorderRadius.circular(tokens.buttonRadius),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_setDone ? Icons.check_circle : Icons.check_rounded, color: tokens.onAccent, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    _setDone ? 'Set Logged' : 'Log Set',
                                    style: TextStyle(
                                      color: tokens.onAccent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Previous sets summary table
                    Text(
                      'COMPLETED SETS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.textMuted, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.cardRadius),
                      ),
                      child: Column(
                        children: [
                          _buildSetRow(tokens, 1, 95.0, 8, true),
                          Divider(color: tokens.borderSubtle, height: 16),
                          _buildSetRow(tokens, 2, 100.0, 8, true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Persistent Rest Timer Dock at Bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border(top: BorderSide(color: tokens.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: tokens.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Rest Timer',
                        style: TextStyle(color: tokens.textSecondary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    FakeData.restTimerDisplay,
                    style: TextStyle(
                      fontFamily: tokens.displayFont,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(DesignTokens tokens, int setNum, double kg, int reps, bool done) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Set $setNum', style: TextStyle(color: tokens.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
        Text('${kg.toInt()} kg × $reps reps', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
        Icon(Icons.check_circle_rounded, color: tokens.success, size: 18),
      ],
    );
  }
}

