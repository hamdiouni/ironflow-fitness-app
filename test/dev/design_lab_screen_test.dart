import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/dev/design_lab/design_lab_screen.dart';
import 'package:progression_tracker/dev/design_lab/design_lab_theme.dart';

const bool _capturePngs = bool.fromEnvironment('CAPTURE_WAVE4');

Future<void> _loadBundledFonts() async {
  const fonts = {
    'Inter': 'assets/fonts/Inter.ttf',
    'SpaceGrotesk': 'assets/fonts/SpaceGrotesk.ttf',
  };
  for (final entry in fonts.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final iconCandidates = [
    if (flutterRoot != null && flutterRoot.isNotEmpty)
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    'C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/opt/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final path in iconCandidates) {
    final iconFile = File(path);
    if (iconFile.existsSync()) {
      final bytes = iconFile.readAsBytesSync();
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
      break;
    }
  }
}

Future<void> _captureToFile(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String relativePath,
) async {
  if (!_capturePngs) return;
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.0);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  });
  final outFile = File(relativePath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsBytesSync(bytes!);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadBundledFonts);

  Future<void> pumpLab({
    required WidgetTester tester,
    required LabDirection direction,
    required bool isDark,
    required int tab,
    required Size size,
    double textScale = 1.0,
    String? capturePath,
  }) async {
    final key = GlobalKey();
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          devicePixelRatio: 1.0,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: DesignLabScreen(
              key: ValueKey('${direction.id}-$isDark-$tab-${size.width}-$textScale'),
              initialDirection: direction,
              initialIsDark: isDark,
              initialTab: tab,
              showControlsBar: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    if (capturePath != null) {
      await _captureToFile(tester, key, capturePath);
    }
  }

  group('Wave 4.1 Design Lab Verification & Optional Capture', () {
    testWidgets('interactive switcher changes direction and brightness safely',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DesignLabScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kinetic Block'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warm Studio'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    for (final dir in LabDirection.values) {
      testWidgets('${dir.id}: renders all screens cleanly across mobile & wide',
          (tester) async {
        final base = 'docs/design-preview/${dir.id}';

        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 0,
          size: const Size(390, 844),
          capturePath: '$base/today_main_390x844.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: false,
          tab: 0,
          size: const Size(390, 844),
          capturePath: '$base/today_alt_390x844.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 0,
          size: const Size(1280, 800),
          capturePath: '$base/today_wide_1280x800.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 1,
          size: const Size(390, 844),
          capturePath: '$base/active_workout_390x844.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 2,
          size: const Size(390, 844),
          capturePath: '$base/fuel_daily_390x844.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 3,
          size: const Size(390, 844),
          capturePath: '$base/progress_charts_390x844.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 3,
          size: const Size(1280, 800),
          capturePath: '$base/progress_charts_wide_1280x800.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 4,
          size: const Size(390, 844),
          capturePath: '$base/component_sheet_390x844.png',
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: false,
          tab: 4,
          size: const Size(390, 844),
          capturePath: '$base/component_sheet_light_390x844.png',
        );

        // Compact 360px + 1.5x text scale stress check on Today & Active Workout
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 0,
          size: const Size(360, 800),
          textScale: 1.5,
        );
        await pumpLab(
          tester: tester,
          direction: dir,
          isDark: true,
          tab: 1,
          size: const Size(360, 800),
          textScale: 1.5,
        );
      });
    }
  });
}
