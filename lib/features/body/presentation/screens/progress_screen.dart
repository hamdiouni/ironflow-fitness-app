import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../widgets/lifts_volume_tab.dart';
import '../widgets/body_map/body_map_view.dart';
import '../widgets/progress/body_weight_tab.dart';
import '../widgets/progress/progress_photos_tab.dart';

/// Stripe Progress Screen displaying:
/// - Tab 0: Lifts & Volume (charts, frequency, volume progression, muscle breakdown merged from Analytics)
/// - Tab 1: Body Weight & Measurements (trend graph, recent entries, body circumferences)
/// - Tab 2: Photos (physique photo gallery and before/after comparison slider)
///
/// Supports query parameter deep-linking via [initialTab] (e.g. ?tab=lifts, ?tab=weight, ?tab=photos).
class ProgressScreen extends ConsumerStatefulWidget {
  final String? initialTab;

  const ProgressScreen({super.key, this.initialTab});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static int _tabIndexFromParam(String? param) {
    if (param == null) return 0;
    switch (param.toLowerCase()) {
      case 'lifts':
      case 'volume':
      case 'analytics':
        return 0;
      case 'bodymap':
      case 'muscle':
      case 'muscles':
      case 'map':
        return 1;
      case 'weight':
      case 'body':
      case 'measurements':
        return 2;
      case 'photos':
      case 'photo':
        return 3;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = _tabIndexFromParam(widget.initialTab);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      AppHaptics.shared.selectionChanged();
    }
  }

  @override
  void didUpdateWidget(covariant ProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      final newIndex = _tabIndexFromParam(widget.initialTab);
      if (newIndex != _tabController.index) {
        _tabController.animateTo(newIndex);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROGRESS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'PERFORMANCE & BODY STATS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
        actions: const [
          AiEntryButton(contextScreen: 'progress'),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: tokens.elevated,
              borderRadius: BorderRadius.circular(AppSpacings.radiusPill),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: tokens.kineticAccent,
                borderRadius: BorderRadius.circular(AppSpacings.radiusPill),
              ),
              labelColor: tokens.onAccent,
              unselectedLabelColor: tokens.textMuted,
              labelStyle: const TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              tabs: const [
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('LIFTS & VOLUME'),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('BODY MAP'),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('BODY WEIGHT'),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('PHOTOS'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiftsVolumeTab(),
          BodyMapView(),
          BodyWeightTab(),
          ProgressPhotosTab(),
        ],
      ),
    );
  }
}
