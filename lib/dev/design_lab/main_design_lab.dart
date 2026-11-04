import 'package:flutter/material.dart';
import 'design_lab_theme.dart';
import 'widgets/design_lab_app_bar.dart';

import 'screens/preview_today_screen.dart';
import 'screens/preview_active_workout_screen.dart';
import 'screens/preview_workout_summary_screen.dart';
import 'screens/preview_fuel_screen.dart';
import 'screens/preview_quantity_sheet.dart';
import 'screens/preview_recipes_screen.dart';
import 'screens/preview_exercise_library_screen.dart';
import 'screens/preview_exercise_detail_screen.dart';
import 'screens/preview_progress_screen.dart';
import 'screens/preview_component_sheet.dart';
import 'screens/preview_auth_screen.dart';

void main() {
  runApp(const DesignLabApp());
}

class DesignLabApp extends StatelessWidget {
  const DesignLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'IronFlow Design Lab',
      debugShowCheckedModeBanner: false,
      home: DesignLabScreen(initialDirection: DesignDirection.softLayered),
    );
  }
}

class DesignLabScreen extends StatefulWidget {
  final DesignDirection initialDirection;
  const DesignLabScreen({
    super.key,
    this.initialDirection = DesignDirection.softLayered,
  });

  @override
  State<DesignLabScreen> createState() => _DesignLabScreenState();
}

class _DesignLabScreenState extends State<DesignLabScreen> {
  late DesignDirection _direction;
  bool _isDark = true;
  int _activeScreenIndex = 0;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
  }

  final List<String> _screenTitles = [
    'Today (Home)',
    'Active Workout (Focus)',
    'Workout Summary',
    'Fuel (Timeline & Hero)',
    'Quantity Sheet',
    'Recipes Carousel',
    'Exercise Library',
    'Exercise Detail',
    'Progress (Bento)',
    'Component Gallery',
    'Onboarding (Auth)',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.fromDirection(_direction, isDark: _isDark);

    return Theme(
      data: tokens.toThemeData(),
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: DesignLabAppBar(
          tokens: tokens,
          currentDirection: _direction,
          isDark: _isDark,
          onDirectionChanged: (dir) => setState(() => _direction = dir),
          onThemeModeChanged: (dark) => setState(() => _isDark = dark),
          activeScreenTitle: _screenTitles[_activeScreenIndex],
          onOpenScreenPicker: () => _showScreenPicker(tokens),
        ),
        body: _buildActiveScreen(tokens),
        bottomNavigationBar: _buildBottomNav(tokens),
      ),
    );
  }

  Widget _buildActiveScreen(DesignTokens tokens) {
    switch (_activeScreenIndex) {
      case 0:
        return PreviewTodayScreen(
          tokens: tokens,
          onStartWorkout: () => setState(() => _activeScreenIndex = 1),
          onLogMeal: () => setState(() => _activeScreenIndex = 4),
        );
      case 1:
        return PreviewActiveWorkoutScreen(
          tokens: tokens,
          onFinish: () => setState(() => _activeScreenIndex = 2),
        );
      case 2:
        return PreviewWorkoutSummaryScreen(
          tokens: tokens,
          onDone: () => setState(() => _activeScreenIndex = 0),
        );
      case 3:
        return PreviewFuelScreen(
          tokens: tokens,
          onAddFood: () => setState(() => _activeScreenIndex = 4),
        );
      case 4:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: PreviewQuantitySheet(tokens: tokens),
          ),
        );
      case 5:
        return PreviewRecipesScreen(tokens: tokens);
      case 6:
        return PreviewExerciseLibraryScreen(
          tokens: tokens,
          onSelectExercise: (_) => setState(() => _activeScreenIndex = 7),
        );
      case 7:
        return PreviewExerciseDetailScreen(
          tokens: tokens,
        );
      case 8:
        return PreviewProgressScreen(tokens: tokens);
      case 9:
        return PreviewComponentSheet(tokens: tokens);
      case 10:
        return PreviewAuthScreen(tokens: tokens);
      default:
        return Center(child: Text('Screen index $_activeScreenIndex'));
    }
  }

  Widget _buildBottomNav(DesignTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Today', tokens),
              _buildNavItem(1, Icons.fitness_center_outlined, Icons.fitness_center, 'Workout', tokens),
              _buildNavItem(3, Icons.restaurant_outlined, Icons.restaurant, 'Fuel', tokens),
              _buildNavItem(8, Icons.bar_chart_outlined, Icons.bar_chart, 'Progress', tokens),
              _buildNavItem(9, Icons.widgets_outlined, Icons.widgets, 'UI Kit', tokens),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    DesignTokens tokens,
  ) {
    final isSelected = _activeScreenIndex == index;
    final icon = isSelected ? filledIcon : outlineIcon;

    return InkWell(
      onTap: () => setState(() => _activeScreenIndex = index),
      borderRadius: BorderRadius.circular(tokens.chipRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? tokens.accent : tokens.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? tokens.accent : tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScreenPicker(DesignTokens tokens) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.sheetRadius)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'SELECT SCREEN PREVIEW',
                  style: TextStyle(
                    fontFamily: tokens.displayFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: tokens.accent,
                  ),
                ),
              ),
              Divider(height: 1, color: tokens.borderSubtle),
              Expanded(
                child: ListView.builder(
                  itemCount: _screenTitles.length,
                  itemBuilder: (context, idx) {
                    final isSelected = _activeScreenIndex == idx;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: tokens.accent.withValues(alpha: 0.1),
                      title: Text(
                        _screenTitles[idx],
                        style: TextStyle(
                          color: isSelected ? tokens.accent : tokens.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: tokens.accent, size: 18)
                          : null,
                      onTap: () {
                        setState(() => _activeScreenIndex = idx);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
