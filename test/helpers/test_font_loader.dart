import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

bool _fontsLoaded = false;

/// Loads IronFlow's bundled open-license fonts (`Inter.ttf`, `SpaceGrotesk.ttf`)
/// plus the Flutter SDK `MaterialIcons-Regular.otf` font so screenshot captures
/// render crisp, real typography and icons (never `Ahem` test boxes).
Future<void> loadPreviewFonts(WidgetTester tester) async {
  if (_fontsLoaded) return;
  await tester.runAsync(() async {
    final interBytes = await File('assets/fonts/Inter.ttf').readAsBytes();
    final spaceBytes =
        await File('assets/fonts/SpaceGrotesk.ttf').readAsBytes();

    final interData = ByteData.sublistView(interBytes);
    final spaceData = ByteData.sublistView(spaceBytes);

    final interLoader = FontLoader('Inter')..addFont(Future.value(interData));
    final robotoFallback = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(interBytes)));
    final spaceLoader = FontLoader('SpaceGrotesk')
      ..addFont(Future.value(spaceData));

    await interLoader.load();
    await robotoFallback.load();
    await spaceLoader.load();

    final materialFontCandidates = <String>[
      r'C:\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf',
      if (Platform.environment['FLUTTER_ROOT'] != null)
        '${Platform.environment['FLUTTER_ROOT']}${Platform.pathSeparator}bin${Platform.pathSeparator}cache${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts${Platform.pathSeparator}MaterialIcons-Regular.otf',
    ];

    for (final candidate in materialFontCandidates) {
      final f = File(candidate);
      if (f.existsSync()) {
        final iconBytes = await f.readAsBytes();
        final iconLoader = FontLoader('MaterialIcons')
          ..addFont(Future.value(ByteData.sublistView(iconBytes)));
        await iconLoader.load();
        break;
      }
    }
  });
  _fontsLoaded = true;
}

/// Renders [child] at [logicalSize] (default `2.0` DPR) and writes a PNG file
/// to [outputPath].
Future<void> captureSurfacePng(
  WidgetTester tester, {
  required Widget child,
  required Size logicalSize,
  required String outputPath,
  double pixelRatio = 2.0,
  int pumpCount = 5,
}) async {
  await loadPreviewFonts(tester);

  final boundaryKey = GlobalKey();
  tester.view.devicePixelRatio = pixelRatio;
  tester.view.physicalSize = Size(
    logicalSize.width * pixelRatio,
    logicalSize.height * pixelRatio,
  );

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: MediaQuery(
        data: MediaQueryData(
          size: logicalSize,
          devicePixelRatio: pixelRatio,
          padding: EdgeInsets.only(top: logicalSize.width < 600 ? 24 : 0),
        ),
        child: SizedBox(
          width: logicalSize.width,
          height: logicalSize.height,
          child: child,
        ),
      ),
    ),
  );

  for (var i = 0; i < pumpCount; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      throw StateError('Failed to encode PNG for $outputPath');
    }
    final outFile = File(outputPath);
    outFile.parent.createSync(recursive: true);
    await outFile.writeAsBytes(byteData.buffer.asUint8List());
  });
}

