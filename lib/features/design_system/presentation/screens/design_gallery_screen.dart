import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/presentation/components/components.dart';

/// Debug-only Design System Gallery demonstrating all tokens and components
/// in both light and dark modes. Gated behind [kDebugMode].
class DesignGalleryScreen extends ConsumerStatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  ConsumerState<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends ConsumerState<DesignGalleryScreen> {
  int _selectedChipIndex = 0;
  double _sliderProgress = 0.68;
  final _textController = TextEditingController(text: 'Bench Press');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug only screen')),
      );
    }

    final tokens = context.tokens;
    final currentThemeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Gallery'),
        actions: [
          IconButton(
            tooltip: 'Toggle Light/Dark Theme',
            icon: Icon(
              currentThemeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.lg,
          vertical: AppSpacings.md,
        ),
        children: [
          // ── Theme Info Banner ───────────────────────────────────────────────
          AppCard(
            isGlowing: true,
            child: Row(
              children: [
                Icon(
                  tokens.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: tokens.kineticAccent,
                  size: 28,
                ),
                const SizedBox(width: AppSpacings.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONOLITHIC SCI-FI',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: tokens.kineticAccent,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Mode: ${tokens.isDark ? "Stealth Carbon (Dark)" : "Architectural Titanium (Light)"}',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Color Swatches ──────────────────────────────────────────────────
          const AppSectionHeader(title: 'Color Tokens'),
          Wrap(
            spacing: AppSpacings.sm,
            runSpacing: AppSpacings.sm,
            children: [
              _SwatchTile(color: tokens.kineticAccent, name: 'Kinetic Lime'),
              _SwatchTile(color: tokens.cyanAccent, name: 'Cyan Pulse'),
              _SwatchTile(color: tokens.violetAccent, name: 'Violet Accent'),
              _SwatchTile(color: tokens.canvas, name: 'Canvas'),
              _SwatchTile(color: tokens.panel, name: 'Panel'),
              _SwatchTile(color: tokens.card, name: 'Card'),
              _SwatchTile(color: tokens.elevated, name: 'Elevated'),
              _SwatchTile(color: tokens.error, name: 'Error / Alert'),
              _SwatchTile(color: tokens.warning, name: 'Warning'),
              _SwatchTile(color: tokens.protein, name: 'Protein'),
            ],
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Typography ──────────────────────────────────────────────────────
          const AppSectionHeader(title: 'Typography & Numerics'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Large 34',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  'Headline Medium 20',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Title Medium 15 (SemiBold)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacings.sm),
                Text(
                  'Body Large: Precision engineering meets luxury minimalism.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacings.md),
                Text(
                  '180.5 KG / 01:24:50',
                  style: AppTypography.tabularMetric(
                    fontSize: 24,
                    color: tokens.kineticAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Buttons ─────────────────────────────────────────────────────────
          const AppSectionHeader(title: 'Buttons (48dp Touch Targets)'),
          Wrap(
            spacing: AppSpacings.md,
            runSpacing: AppSpacings.md,
            children: [
              AppButton(
                label: 'Primary Kinetic',
                icon: const Icon(Icons.flash_on),
                onPressed: () {},
              ),
              AppButton(
                label: 'Secondary Titanium',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              AppButton(
                label: 'Outline Accent',
                variant: AppButtonVariant.outline,
                onPressed: () {},
              ),
              AppButton(
                label: 'Ghost Button',
                variant: AppButtonVariant.ghost,
                onPressed: () {},
              ),
              AppButton(
                label: 'Destructive',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
              ),
              AppButton(
                label: 'Loading State',
                isLoading: true,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                onPressed: null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Telemetry Stat Tiles ────────────────────────────────────────────
          const AppSectionHeader(title: 'Telemetry Stat Tiles'),
          Row(
            children: [
              Expanded(
                child: AppStatTile(
                  title: 'Total Volume',
                  value: '8,420',
                  unit: 'kg',
                  icon: const Icon(Icons.fitness_center),
                  delta: '+12.4%',
                  isPositiveDelta: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacings.md),
              Expanded(
                child: AppStatTile(
                  title: 'Daily Streak',
                  value: '18',
                  unit: 'days',
                  icon: const Icon(Icons.local_fire_department),
                  accentColor: tokens.warning,
                  delta: 'BEST',
                  isPositiveDelta: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Progress Indicators ─────────────────────────────────────────────
          const AppSectionHeader(title: 'Progress Bars & Telemetry Rings'),
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppProgressRing(
                      progress: _sliderProgress,
                      size: 72,
                      centerWidget: Text(
                        '${(_sliderProgress * 100).toInt()}%',
                        style: AppTypography.tabularMetric(
                          fontSize: 16,
                          color: tokens.kineticAccent,
                        ),
                      ),
                    ),
                    AppProgressRing(
                      progress: 0.85,
                      size: 72,
                      progressColor: tokens.cyanAccent,
                      centerWidget: Text(
                        '85%',
                        style: AppTypography.tabularMetric(
                          fontSize: 16,
                          color: tokens.cyanAccent,
                        ),
                      ),
                    ),
                    AppProgressRing(
                      progress: 0.42,
                      size: 72,
                      progressColor: tokens.violetAccent,
                      centerWidget: Text(
                        '42%',
                        style: AppTypography.tabularMetric(
                          fontSize: 16,
                          color: tokens.violetAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacings.lg),
                AppProgressBar(
                  progress: _sliderProgress,
                  showGlow: true,
                ),
                const SizedBox(height: AppSpacings.md),
                Slider(
                  value: _sliderProgress,
                  onChanged: (v) => setState(() => _sliderProgress = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Chips ───────────────────────────────────────────────────────────
          const AppSectionHeader(title: 'Filter Chips'),
          Wrap(
            spacing: AppSpacings.sm,
            runSpacing: AppSpacings.sm,
            children: [
              for (int i = 0; i < 4; i++)
                AppChip(
                  label: ['Chest', 'Back', 'Legs', 'Shoulders'][i],
                  isSelected: _selectedChipIndex == i,
                  onTap: () => setState(() => _selectedChipIndex = i),
                ),
            ],
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Inputs ──────────────────────────────────────────────────────────
          const AppSectionHeader(title: 'Input Fields'),
          AppTextField(
            label: 'Exercise Name',
            controller: _textController,
            prefixIcon: Icon(Icons.search, color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacings.md),
          const AppTextField(
            label: 'Set Weight (kg)',
            hintText: 'e.g. 100.0',
            keyboardType: TextInputType.number,
            helperText: 'Previous best was 95.0 kg',
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Interactive List Tiles ──────────────────────────────────────────
          const AppSectionHeader(title: 'Interactive List Tiles'),
          AppListTile(
            title: 'Barbell Bench Press',
            subtitle: '4 sets completed • 3,200 kg volume',
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tokens.kineticAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Icon(Icons.check, color: tokens.kineticAccent, size: 20),
            ),
            trailing: Text(
              '100 kg x 8',
              style: AppTypography.tabularMetric(
                fontSize: 14,
                color: tokens.textPrimary,
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacings.sm),
          AppListTile(
            title: 'Incline Dumbbell Press',
            subtitle: 'Pending 3 sets',
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tokens.elevated,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Icon(Icons.schedule, color: tokens.textSecondary, size: 20),
            ),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Shimmer Loaders ─────────────────────────────────────────────────
          const AppSectionHeader(title: 'Skeleton Shimmer Loaders'),
          AppCard(
            child: Row(
              children: [
                const AppShimmer(width: 48, height: 48, isCircle: true),
                const SizedBox(width: AppSpacings.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppShimmer(width: 140, height: 16),
                      SizedBox(height: AppSpacings.xs),
                      AppShimmer(width: 220, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacings.xl),

          // ── Dialogs & Bottom Sheet Modals ───────────────────────────────────
          const AppSectionHeader(title: 'Modals & Overlays'),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Open Bottom Sheet',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      title: 'Select Exercise',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Monolithic Sci-Fi bottom sheet with drag handle.'),
                          const SizedBox(height: AppSpacings.lg),
                          AppButton(
                            label: 'Done',
                            isFullWidth: true,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacings.md),
              Expanded(
                child: AppButton(
                  label: 'Open Dialog',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    AppDialog.show(
                      context: context,
                      title: 'Finish Workout?',
                      content: const Text('You have completed 12 sets today!'),
                      icon: const Icon(Icons.celebration),
                      confirmLabel: 'Save & Finish',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacings.huge),
        ],
      ),
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({required this.color, required this.name});
  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacings.sm),
      decoration: BoxDecoration(
        color: context.tokens.card,
        borderRadius: BorderRadius.circular(context.tokens.radiusSm),
        border: Border.all(color: context.tokens.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacings.radiusXs),
              border: Border.all(color: context.tokens.borderSubtle, width: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacings.xs),
          Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
