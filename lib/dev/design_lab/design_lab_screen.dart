import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'design_lab_theme.dart';
import 'screens/lab_active_workout_screen.dart';
import 'screens/lab_components_screen.dart';
import 'screens/lab_fuel_screen.dart';
import 'screens/lab_progress_screen.dart';
import 'screens/lab_today_screen.dart';
import 'widgets/design_lab_widgets.dart';

/// Interactive Wave 4.1 Design Lab strictly isolated under `lib/dev/design_lab/`
/// and mounted on `/design-preview` only in debug mode.
class DesignLabScreen extends StatefulWidget {
  const DesignLabScreen({
    super.key,
    this.initialDirection = LabDirection.slateTeal,
    this.initialIsDark = true,
    this.initialTab = 0,
    this.showControlsBar = true,
  });

  final LabDirection initialDirection;
  final bool initialIsDark;
  final int initialTab;
  final bool showControlsBar;

  @override
  State<DesignLabScreen> createState() => _DesignLabScreenState();
}

class _DesignLabScreenState extends State<DesignLabScreen> {
  late LabDirection _direction;
  late bool _isDark;
  late int _selectedTab;
  bool _forcePhonePreview = false;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
    _isDark = widget.initialIsDark;
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug preview unavailable in release builds.')),
      );
    }

    final tokens = LabTokens.forConfig(_direction, isDark: _isDark);

    return Theme(
      data: LabTokens.buildMaterialTheme(tokens),
      child: Scaffold(
        backgroundColor: tokens.canvas,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.showControlsBar) _buildControlsBar(tokens),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final effectiveWidth = _forcePhonePreview
                        ? 390.0
                        : constraints.maxWidth;
                    final isWide = effectiveWidth >= 900;

                    final content = LabResponsiveShell(
                      tokens: tokens,
                      selectedNavIndex: _selectedTab,
                      onSelectNav: (i) => setState(() => _selectedTab = i),
                      isWide: isWide,
                      body: _buildBody(tokens, isWide: isWide),
                    );

                    if (_forcePhonePreview && constraints.maxWidth > 430) {
                      return Center(
                        child: Container(
                          width: 390,
                          height: 844,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: tokens.border, width: 2),
                          ),
                          child: content,
                        ),
                      );
                    }
                    return content;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LabTokens tokens, {required bool isWide}) {
    return switch (_selectedTab) {
      0 => LabTodayScreen(
          tokens: tokens,
          isWide: isWide,
          onStartWorkout: () => setState(() => _selectedTab = 1),
          onOpenFuel: () => setState(() => _selectedTab = 2),
        ),
      1 => LabActiveWorkoutScreen(tokens: tokens, isWide: isWide),
      2 => LabFuelScreen(tokens: tokens, isWide: isWide),
      3 => LabProgressScreen(tokens: tokens, isWide: isWide),
      _ => LabComponentsScreen(
          tokens: tokens,
          isWide: isWide,
          onToggleBrightness: () => setState(() => _isDark = !_isDark),
        ),
    };
  }

  Widget _buildControlsBar(LabTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final dir in LabDirection.values)
            ChoiceChip(
              label: Text(dir.shortLabel),
              selected: _direction == dir,
              onSelected: (_) => setState(() => _direction = dir),
            ),
          IconButton(
            tooltip: 'Toggle Light/Dark',
            onPressed: () => setState(() => _isDark = !_isDark),
            icon: Icon(
              _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: tokens.accent,
            ),
          ),
          IconButton(
            tooltip: 'Toggle 390px Frame',
            onPressed: () => setState(() => _forcePhonePreview = !_forcePhonePreview),
            icon: Icon(
              _forcePhonePreview
                  ? Icons.desktop_windows_rounded
                  : Icons.smartphone_rounded,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
