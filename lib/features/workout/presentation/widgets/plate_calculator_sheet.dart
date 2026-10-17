import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/services/app_haptics.dart';

/// Unit mode for the plate calculator.
enum PlateUnit { kg, lb }

/// Monolithic Sci-Fi Offline Plate Calculator modal bottom sheet.
/// Calculates the exact plate combination needed per side of the barbell
/// and renders a visual representation of the loaded barbell sleeve.
class PlateCalculatorSheet extends StatefulWidget {
  final double initialWeight;
  final PlateUnit initialUnit;
  final void Function(double weight)? onApplyWeight;

  const PlateCalculatorSheet({
    super.key,
    this.initialWeight = 60.0,
    this.initialUnit = PlateUnit.kg,
    this.onApplyWeight,
  });

  /// Static helper to show the Plate Calculator as a modal bottom sheet.
  static Future<double?> show(
    BuildContext context, {
    double initialWeight = 60.0,
    PlateUnit initialUnit = PlateUnit.kg,
    void Function(double weight)? onApplyWeight,
  }) {
    AppHaptics.shared.selectionChanged();
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlateCalculatorSheet(
        initialWeight: initialWeight,
        initialUnit: initialUnit,
        onApplyWeight: onApplyWeight,
      ),
    );
  }

  @override
  State<PlateCalculatorSheet> createState() => _PlateCalculatorSheetState();
}

class _PlateCalculatorSheetState extends State<PlateCalculatorSheet> {
  late PlateUnit _unit;
  late double _barWeight;
  late double _targetWeight;
  late TextEditingController _controller;

  // Standard Olympic plate sets
  static const List<double> _kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
  static const List<double> _lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

  // Standard Barbell weights
  static const List<double> _kgBars = [20.0, 15.0, 10.0];
  static const List<double> _lbBars = [45.0, 35.0, 15.0];

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
    _barWeight = _unit == PlateUnit.kg ? 20.0 : 45.0;
    _targetWeight = widget.initialWeight > _barWeight ? widget.initialWeight : _barWeight;
    _controller = TextEditingController(text: _formatWeight(_targetWeight));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatWeight(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    if ((val * 10) == (val * 10).roundToDouble()) {
      return val.toStringAsFixed(1);
    }
    return val.toStringAsFixed(2);
  }

  void _onUnitChanged(PlateUnit newUnit) {
    if (_unit == newUnit) return;
    AppHaptics.shared.selectionChanged();
    setState(() {
      _unit = newUnit;
      if (_unit == PlateUnit.kg) {
        _targetWeight = _targetWeight * 0.45359237;
        _targetWeight = 2.5 * (_targetWeight / 2.5).round();
        _barWeight = 20.0;
      } else {
        _targetWeight = _targetWeight * 2.20462;
        _targetWeight = 5.0 * (_targetWeight / 5.0).round();
        _barWeight = 45.0;
      }
      if (_targetWeight < _barWeight) _targetWeight = _barWeight;
      _controller.text = _formatWeight(_targetWeight);
    });
  }

  void _adjustWeight(double delta) {
    AppHaptics.shared.setLogged();
    setState(() {
      _targetWeight = (_targetWeight + delta).clamp(_barWeight, 500.0);
      _controller.text = _formatWeight(_targetWeight);
    });
  }

  Map<double, int> _calculatePlatesPerSide() {
    final available = _unit == PlateUnit.kg ? _kgPlates : _lbPlates;
    final Map<double, int> result = {};

    if (_targetWeight <= _barWeight) {
      return result;
    }

    double weightPerSide = (_targetWeight - _barWeight) / 2.0;

    for (final plate in available) {
      if (weightPerSide >= plate) {
        final count = (weightPerSide / plate).floor();
        if (count > 0) {
          result[plate] = count;
          weightPerSide -= count * plate;
          weightPerSide = (weightPerSide * 100).round() / 100;
        }
      }
    }

    return result;
  }

  Color _getPlateColor(double weight, AppThemeTokens tokens) {
    if (_unit == PlateUnit.kg) {
      switch (weight.toString()) {
        case '25.0':
          return const Color(0xFFEF4444);
        case '20.0':
          return const Color(0xFF3B82F6);
        case '15.0':
          return const Color(0xFFF59E0B);
        case '10.0':
          return const Color(0xFF10B981);
        case '5.0':
          return const Color(0xFFF1F5F9);
        case '2.5':
          return const Color(0xFF475569);
        case '1.25':
          return tokens.kineticAccent;
        default:
          return tokens.borderSubtle;
      }
    } else {
      switch (weight.toString()) {
        case '45.0':
          return const Color(0xFF3B82F6);
        case '35.0':
          return const Color(0xFFF59E0B);
        case '25.0':
          return const Color(0xFF10B981);
        case '10.0':
          return const Color(0xFFF1F5F9);
        case '5.0':
          return const Color(0xFF475569);
        case '2.5':
          return tokens.kineticAccent;
        default:
          return tokens.borderSubtle;
      }
    }
  }

  double _getPlateHeightFraction(double weight) {
    final available = _unit == PlateUnit.kg ? _kgPlates : _lbPlates;
    final maxWeight = available.first;
    final minWeight = available.last;
    final normalized = (weight - minWeight) / (maxWeight - minWeight);
    return (0.42 + 0.58 * normalized).clamp(0.40, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final unitLabel = _unit == PlateUnit.kg ? 'KG' : 'LB';
    final platesPerSide = _calculatePlatesPerSide();

    double loadedPerSide = 0;
    platesPerSide.forEach((plate, count) {
      loadedPerSide += plate * count;
    });
    final totalLoaded = _barWeight + (loadedPerSide * 2);
    final remainder = (_targetWeight - totalLoaded).abs();
    final hasRemainder = remainder > 0.05;

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
                  ),
                  child: Icon(Icons.calculate_outlined, color: tokens.kineticAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLATE CALCULATOR',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'OFFLINE BARBELL SLEEVE TELEMETRY',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _UnitButton(
                        label: 'KG',
                        isSelected: _unit == PlateUnit.kg,
                        tokens: tokens,
                        onTap: () => _onUnitChanged(PlateUnit.kg),
                      ),
                      _UnitButton(
                        label: 'LB',
                        isSelected: _unit == PlateUnit.lb,
                        tokens: tokens,
                        onTap: () => _onUnitChanged(PlateUnit.lb),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Target Weight Matrix Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TARGET LOAD',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'BAR: ${_formatWeight(_barWeight)} $unitLabel',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.kineticAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatWeight(_targetWeight),
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textPrimary,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unitLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Stepper Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepButton(
                        label: _unit == PlateUnit.kg ? '-5' : '-10',
                        tokens: tokens,
                        onTap: () => _adjustWeight(_unit == PlateUnit.kg ? -5.0 : -10.0),
                      ),
                      const SizedBox(width: 8),
                      _StepButton(
                        label: _unit == PlateUnit.kg ? '-2.5' : '-5',
                        tokens: tokens,
                        onTap: () => _adjustWeight(_unit == PlateUnit.kg ? -2.5 : -5.0),
                      ),
                      const SizedBox(width: 14),
                      _StepButton(
                        label: _unit == PlateUnit.kg ? '+2.5' : '+5',
                        tokens: tokens,
                        isAccent: true,
                        onTap: () => _adjustWeight(_unit == PlateUnit.kg ? 2.5 : 5.0),
                      ),
                      const SizedBox(width: 8),
                      _StepButton(
                        label: _unit == PlateUnit.kg ? '+5' : '+10',
                        tokens: tokens,
                        isAccent: true,
                        onTap: () => _adjustWeight(_unit == PlateUnit.kg ? 5.0 : 10.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Bar Selection Chips
            Row(
              children: [
                Text(
                  'BAR WEIGHT:',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      for (final bar in (_unit == PlateUnit.kg ? _kgBars : _lbBars))
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              setState(() {
                                _barWeight = bar;
                                if (_targetWeight < _barWeight) {
                                  _targetWeight = _barWeight;
                                  _controller.text = _formatWeight(_targetWeight);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(tokens.radiusSm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _barWeight == bar
                                    ? tokens.kineticAccent.withValues(alpha: 0.15)
                                    : tokens.card,
                                borderRadius: BorderRadius.circular(tokens.radiusSm),
                                border: Border.all(
                                  color: _barWeight == bar
                                      ? tokens.kineticAccent
                                      : tokens.borderSubtle,
                                ),
                              ),
                              child: Text(
                                '${_formatWeight(bar)} $unitLabel',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  color: _barWeight == bar
                                      ? tokens.kineticAccent
                                      : tokens.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── VISUAL BARBELL SLEEVE ─────────────────────────────────────
            Text(
              'SLEEVE CONFIGURATION (ONE SIDE)',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Row(
                children: [
                  // Barbell Shaft
                  Container(
                    width: 32,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFF475569)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Collar stop
                  Container(
                    width: 14,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      border: Border.all(color: const Color(0xFF475569)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),

                  // Loaded Plates Stack
                  Expanded(
                    child: platesPerSide.isEmpty
                        ? Center(
                            child: Text(
                              'NO PLATES LOADED (BAR ONLY)',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                color: tokens.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              for (final entry in platesPerSide.entries)
                                for (int i = 0; i < entry.value; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Center(
                                      child: Container(
                                        width: 22,
                                        height: 94 * _getPlateHeightFraction(entry.key),
                                        decoration: BoxDecoration(
                                          color: _getPlateColor(entry.key, tokens),
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getPlateColor(entry.key, tokens).withValues(alpha: 0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: RotatedBox(
                                            quarterTurns: 3,
                                            child: Text(
                                              _formatWeight(entry.key),
                                              style: TextStyle(
                                                fontFamily: AppTypography.displayFontFamily,
                                                color: (_getPlateColor(entry.key, tokens) == const Color(0xFFF1F5F9) ||
                                                        _getPlateColor(entry.key, tokens) == const Color(0xFFF59E0B) ||
                                                        _getPlateColor(entry.key, tokens) == tokens.kineticAccent)
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              Center(
                                child: Container(
                                  width: 24,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF475569),
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(3),
                                    ),
                                    border: Border.all(color: const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Plates per side breakdown list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EACH SIDE REQUIRES:',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${_formatWeight(loadedPerSide)} $unitLabel',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.kineticAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (platesPerSide.isEmpty)
                    Text(
                      'No plates needed. Lift the bar alone.',
                      style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final entry in platesPerSide.entries)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPlateColor(entry.key, tokens).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              border: Border.all(color: _getPlateColor(entry.key, tokens).withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '${entry.value} × ${_formatWeight(entry.key)} $unitLabel',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                color: tokens.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (hasRemainder) ...[
                    const SizedBox(height: 8),
                    Text(
                      '⚠️ Unmatched remainder: ${_formatWeight(remainder)} $unitLabel. Closest achievable: ${_formatWeight(totalLoaded)} $unitLabel.',
                      style: TextStyle(
                        color: tokens.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'CLOSE',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                if (widget.onApplyWeight != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'APPLY WEIGHT',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        AppHaptics.shared.selectionChanged();
                        widget.onApplyWeight!(_targetWeight);
                        Navigator.of(context).pop(_targetWeight);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  const _UnitButton({
    required this.label,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tokens.kineticAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            color: isSelected ? Colors.black : tokens.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final AppThemeTokens tokens;
  final VoidCallback onTap;
  final bool isAccent;

  const _StepButton({
    required this.label,
    required this.tokens,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isAccent ? tokens.kineticAccent.withValues(alpha: 0.15) : tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(
            color: isAccent ? tokens.kineticAccent : tokens.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            color: isAccent ? tokens.kineticAccent : tokens.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
