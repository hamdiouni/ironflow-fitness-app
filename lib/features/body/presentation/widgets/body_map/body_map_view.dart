import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_recovery_status.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'anatomy_renderer.dart';
import 'muscle_detail_sheet.dart';
export 'anatomy_renderer.dart';

/// Full interactive Body Map view component (Wave 4 / Wave 5.2).
///
/// Features front & back 2D anatomical muscle rendering via [AnatomyRenderer]
/// with sub-millisecond path hit-testing, recovery estimates, volume heatmap
/// mode, and an accessible semantic list alternative.
class BodyMapView extends ConsumerStatefulWidget {
  const BodyMapView({
    super.key,
    this.compact = false,
    this.onMuscleSelected,
    this.renderer = const Vector2DAnatomyRenderer(),
  });

  /// When true, renders a lightweight compact version (e.g. for Home / Summary).
  final bool compact;

  /// Optional callback when a muscle region is tapped.
  final ValueChanged<MuscleRegion>? onMuscleSelected;

  /// Pluggable anatomy renderer (defaults to [Vector2DAnatomyRenderer]).
  final AnatomyRenderer renderer;

  @override
  ConsumerState<BodyMapView> createState() => _BodyMapViewState();
}

class _BodyMapViewState extends ConsumerState<BodyMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isListViewMode = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _selectRegion(MuscleRegion region) {
    AppHaptics.shared.selectionChanged();
    ref.read(selectedMuscleRegionProvider.notifier).select(region);
    widget.onMuscleSelected?.call(region);

    final recoveryMap =
        ref.read(muscleRecoveryProvider).valueOrNull ?? const {};
    final data = recoveryMap[region] ?? MuscleRecoveryData.fresh(region);

    _showDetailSheet(context, data);
  }

  void _showDetailSheet(BuildContext context, MuscleRecoveryData data) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MuscleDetailSheet(
        recoveryData: data,
        onToggleSoreness: (isSore) {
          ref
              .read(manualSorenessProvider.notifier)
              .toggle(data.region.id, isSore);
        },
      ),
    ).whenComplete(() {
      ref.read(selectedMuscleRegionProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isFront = ref.watch(bodyMapViewModeProvider);
    final isHeatmap = ref.watch(bodyMapHeatmapModeProvider);
    final selectedRegion = ref.watch(selectedMuscleRegionProvider);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!disableAnimations && selectedRegion != null && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if ((disableAnimations || selectedRegion == null) && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
    final recoveryAsync = ref.watch(muscleRecoveryProvider);
    final recoveryMap = recoveryAsync.valueOrNull ?? const {};

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
      children: [
        // Top Toolbar
        if (!widget.compact) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                // Front / Back Segmented Control
                Container(
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSegmentButton(
                        label: 'FRONT',
                        isSelected: isFront,
                        onTap: () {
                          AppHaptics.shared.selectionChanged();
                          ref
                              .read(bodyMapViewModeProvider.notifier)
                              .setFront();
                        },
                        tokens: tokens,
                      ),
                      _buildSegmentButton(
                        label: 'BACK',
                        isSelected: !isFront,
                        onTap: () {
                          AppHaptics.shared.selectionChanged();
                          ref.read(bodyMapViewModeProvider.notifier).setBack();
                        },
                        tokens: tokens,
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Metric Mode Toggle (Recovery vs Heatmap)
                    Container(
                      decoration: BoxDecoration(
                        color: tokens.card,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSegmentButton(
                            label: 'RECOVERY',
                            isSelected: !isHeatmap,
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              ref
                                  .read(bodyMapHeatmapModeProvider.notifier)
                                  .setMode(false);
                            },
                            tokens: tokens,
                          ),
                          _buildSegmentButton(
                            label: 'HEATMAP',
                            isSelected: isHeatmap,
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              ref
                                  .read(bodyMapHeatmapModeProvider.notifier)
                                  .setMode(true);
                            },
                            tokens: tokens,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Accessible List View Toggle
                    IconButton(
                      key: const Key('body_map_list_mode_button'),
                      tooltip: _isListViewMode
                          ? 'Switch to interactive vector map'
                          : 'Switch to accessible list view',
                      icon: Icon(
                        _isListViewMode
                            ? Icons.accessibility_new_rounded
                            : Icons.format_list_bulleted_rounded,
                        color: _isListViewMode
                            ? tokens.kineticAccent
                            : tokens.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        AppHaptics.shared.selectionChanged();
                        setState(() => _isListViewMode = !_isListViewMode);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Main Display: Map Canvas or Accessible List (side-by-side at >= 900px)
        constraints.hasBoundedHeight
            ? Expanded(
                child: !widget.compact && constraints.maxWidth >= 900
                    ? Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildMapCanvas(
                              context,
                              isFront,
                              isHeatmap,
                              selectedRegion,
                              recoveryMap,
                              tokens,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: _buildAccessibleListView(
                              context,
                              isFront,
                              recoveryMap,
                              tokens,
                            ),
                          ),
                        ],
                      )
                    : _isListViewMode
                        ? _buildAccessibleListView(
                            context,
                            isFront,
                            recoveryMap,
                            tokens,
                          )
                        : _buildMapCanvas(
                            context,
                            isFront,
                            isHeatmap,
                            selectedRegion,
                            recoveryMap,
                            tokens,
                          ),
              )
            : SizedBox(
                height: 520,
                child: _isListViewMode
                    ? _buildAccessibleListView(
                        context,
                        isFront,
                        recoveryMap,
                        tokens,
                      )
                    : _buildMapCanvas(
                        context,
                        isFront,
                        isHeatmap,
                        selectedRegion,
                        recoveryMap,
                        tokens,
                      ),
              ),

        // Bottom Legend & Readiness Summary
        if (!widget.compact) _buildBottomLegend(context, isHeatmap, tokens),
      ],
    );
      },
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeTokens tokens,
  }) {
    return Semantics(
      button: true,
      enabled: true,
      selected: isSelected,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? tokens.kineticAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isSelected ? tokens.onAccent : tokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapCanvas(
    BuildContext context,
    bool isFront,
    bool isHeatmap,
    MuscleRegion? selectedRegion,
    Map<MuscleRegion, MuscleRecoveryData> recoveryMap,
    AppThemeTokens tokens,
  ) {
    return widget.renderer.build(
      context,
      AnatomyRenderConfig(
        isFront: isFront,
        isHeatmapMode: isHeatmap,
        recoveryMap: recoveryMap,
        selectedRegion: selectedRegion,
        tokens: tokens,
        pulseAnimation: _pulseController,
        onRegionSelected: _selectRegion,
      ),
    );
  }

  Widget _buildAccessibleListView(
    BuildContext context,
    bool isFront,
    Map<MuscleRegion, MuscleRecoveryData> recoveryMap,
    AppThemeTokens tokens,
  ) {
    final regions = isFront ? MuscleRegion.frontRegions : MuscleRegion.backRegions;

    return Semantics(
      label: 'Accessible muscle recovery estimate list',
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final region = regions[index];
          final data = recoveryMap[region] ?? MuscleRecoveryData.fresh(region);
          final pct = (data.score * 100).toInt();

          final tierColor = switch (data.tier) {
            RecoveryTier.fresh => const Color(0xFF10B981),
            RecoveryTier.recovering => const Color(0xFFF59E0B),
            RecoveryTier.fatigued => const Color(0xFFEF4444),
            RecoveryTier.sore => const Color(0xFFA855F7),
          };

          return Semantics(
            button: true,
            label: '${region.displayName}, ${data.tier.name.toUpperCase()} recovery estimate, $pct percent, ${data.sets7Days} sets in last 7 days',
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => _selectRegion(region),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: tierColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            region.displayName,
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          Text(
                            region.anatomicalName,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 11,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$pct% ${data.tier.label.toUpperCase()}',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: tierColor,
                          ),
                        ),
                        Text(
                          '${data.sets7Days} sets 7d · est.',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 10.5,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomLegend(
    BuildContext context,
    bool isHeatmap,
    AppThemeTokens tokens,
  ) {
    if (isHeatmap) {
      final units = ref.read(unitsProvider);
      final weightUnit = UnitsConverter.getWeightUnit(units);
      String band(double kg) {
        final v = UnitsConverter.convertWeightToDisplay(kg, units);
        return '${(v / 1000).toStringAsFixed(1)}k';
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            _buildLegendItem(
              'LOW (0-${band(2000)} $weightUnit)',
              const Color(0xFF0EA5E9),
            ),
            _buildLegendItem(
              'MODERATE (${band(2000)}-${band(6000)})',
              tokens.cyanAccent,
            ),
            _buildLegendItem(
              'HIGH (${band(6000)}-${band(12000)})',
              tokens.kineticAccent,
            ),
            _buildLegendItem(
              'PEAK (${band(12000)}+)',
              const Color(0xFFF59E0B),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          _buildLegendItem('FRESH', const Color(0xFF10B981)),
          _buildLegendItem('RECOVERING', const Color(0xFFF59E0B)),
          _buildLegendItem('NEEDS REST', const Color(0xFFEF4444)),
          _buildLegendItem('SORE', const Color(0xFFA855F7)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
      ],
    );
  }
}
