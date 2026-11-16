import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';

/// Loads bundled TTF font assets (`Inter` and `SpaceGrotesk`) into the Flutter
/// test engine so golden tests render real typography instead of Ahem blocks.
Future<void> _loadBundledFonts() async {
  final fonts = <String, String>{
    'Inter': 'assets/fonts/Inter.ttf',
    'SpaceGrotesk': 'assets/fonts/SpaceGrotesk.ttf',
  };

  for (final entry in fonts.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) {
      throw StateError('Missing bundled font file for goldens: ${entry.value}');
    }
    final Uint8List bytes = file.readAsBytesSync();
    final ByteData byteData = ByteData.view(bytes.buffer);
    final loader = FontLoader(entry.key)..addFont(Future.value(byteData));
    await loader.load();
  }
}

Widget _buildDesignSystemShowcase({required ThemeData theme}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(480, 680),
        devicePixelRatio: 1.0,
        disableAnimations: true,
      ),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                title: 'Today\'s Training',
                subtitle: 'Direction 4 — Soft & Layered',
                actionLabel: 'See All',
                onAction: () {},
                padding: const EdgeInsets.only(bottom: 12),
              ),
              Row(
                children: [
                  const Expanded(
                    child: AppStatTile(
                      title: 'Total Volume',
                      value: '8,420',
                      unit: 'kg',
                      delta: '+6.2%',
                      isPositiveDelta: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppStatTile(
                      title: 'Daily Calories',
                      value: '2,150',
                      unit: 'kcal',
                      delta: '-4.0%',
                      isPositiveDelta: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                isSelected: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppChip(
                          label: 'Push Day',
                          isSelected: true,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        AppChip(
                          label: 'Hypertrophy',
                          isSelected: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const AppProgressBar(progress: 0.68, showGlow: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Start Workout',
                      variant: AppButtonVariant.primary,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Secondary',
                      variant: AppButtonVariant.secondary,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Outline',
                      variant: AppButtonVariant.outline,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Delete',
                      variant: AppButtonVariant.destructive,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: AppProgressRing(
                  progress: 0.75,
                  size: 64,
                  centerWidget: Text('75%'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Cross-OS pixel tolerance comparator used only on non-Windows hosts (e.g., Linux CI)
/// where FreeType/Skia glyph anti-aliasing differs slightly from Windows baselines.
class _CrossOsGoldenFileComparator extends LocalFileComparator {
  _CrossOsGoldenFileComparator(super.testFile, {required this.maxDiffRate});

  final double maxDiffRate;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    try {
      if (result.passed || result.diffPercent <= maxDiffRate) {
        return true;
      }
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    } finally {
      result.dispose();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final GoldenFileComparator previousComparator = goldenFileComparator;

  setUpAll(() async {
    await _loadBundledFonts();
    if (!Platform.isWindows && previousComparator is LocalFileComparator) {
      goldenFileComparator = _CrossOsGoldenFileComparator(
        previousComparator.basedir.resolve('design_system_goldens_test.dart'),
        maxDiffRate: 0.03,
      );
    }
  });

  tearDownAll(() {
    goldenFileComparator = previousComparator;
  });

  group('Wave 2.3 — Direction 4 Design System Goldens (Real Bundled Fonts)', () {
    testWidgets('renders Direction 4 components in Light theme with real fonts', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(480, 680));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildDesignSystemShowcase(theme: AppTheme.lightTheme),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/direction4_components_light.png'),
      );
    });

    testWidgets('renders Direction 4 components in Dark theme with real fonts', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(480, 680));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildDesignSystemShowcase(theme: AppTheme.darkTheme),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/direction4_components_dark.png'),
      );
    });
  });
}

