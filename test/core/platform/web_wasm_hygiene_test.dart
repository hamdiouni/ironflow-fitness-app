import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave 6.2 & 6.3 — Web/Wasm, PWA, Android & iOS Platform Hygiene', () {
    test('lib/ contains zero legacy dart:html, dart:js, dart:js_util, or package:js imports', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final forbiddenImportPattern = RegExp(
        r'''^\s*(import|export)\s+['"](dart:html|dart:js|dart:js_util|package:js/[^'"]+|package:js)['"]''',
        multiLine: true,
      );

      final violations = <String>[];
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final content = entity.readAsStringSync();
        if (forbiddenImportPattern.hasMatch(content)) {
          violations.add(entity.path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Found legacy non-Wasm web imports in lib/: $violations',
      );
    });

    test('web/index.html uses versioned SW bootstrap and Option B Iron Scoreboard splash without cache wiping', () {
      final indexFile = File('web/index.html');
      expect(indexFile.existsSync(), isTrue);
      final html = indexFile.readAsStringSync();

      // Must not unconditionally wipe service workers or CacheStorage on load.
      expect(html.contains('r.unregister()'), isFalse);
      expect(html.contains('caches.delete('), isFalse);

      // Must include Option B Iron Scoreboard colors, splash shell, and SW build stamp.
      expect(html, contains('#0A0B0E'));
      expect(html, contains('#F3F4F6'));
      expect(html, contains('#F59E0B'));
      expect(html, contains('id="ironflow-splash"'));
      expect(html, contains('id="ironflow-build-stamp"'));
      expect(html, contains('{{flutter_service_worker_version}}'));
      expect(html, contains('flutter-first-frame'));
      expect(html, contains('flutter_bootstrap.js'));
    });

    test('web/manifest.json aligns with Option B Iron Scoreboard palette', () {
      final manifestFile = File('web/manifest.json');
      expect(manifestFile.existsSync(), isTrue);
      final decoded =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;

      expect(decoded['name'], 'IronFlow');
      expect(decoded['short_name'], 'IronFlow');
      expect(decoded['background_color'], '#0A0B0E');
      expect(decoded['theme_color'], '#F59E0B');
    });

    test('android/app/build.gradle.kts uses Kotlin compilerOptions, no duplicate Firebase BoM, and fail-fast release signing', () {
      final gradleFile = File('android/app/build.gradle.kts');
      expect(gradleFile.existsSync(), isTrue);
      final gradle = gradleFile.readAsStringSync();

      expect(gradle.contains('kotlinOptions'), isFalse);
      expect(gradle, contains('compilerOptions'));
      expect(gradle, contains('JvmTarget.JVM_17'));
      expect(gradle.contains('com.google.firebase:firebase-bom'), isFalse);
      expect(gradle.contains('com.google.firebase:firebase-analytics'), isFalse);
      expect(gradle, contains('allowUnsignedRelease'));
      expect(gradle, contains('throw GradleException('));
    });

    test('android/app/proguard-rules.pro removes no-op io.hive rules', () {
      final proguardFile = File('android/app/proguard-rules.pro');
      expect(proguardFile.existsSync(), isTrue);
      final rules = proguardFile.readAsStringSync();

      expect(rules.contains('io.hive.'), isFalse);
    });

    test('ios/Podfile and ios/Runner/Info.plist are provisioned for iOS 15+ and App Store compliance', () {
      final podfile = File('ios/Podfile');
      expect(podfile.existsSync(), isTrue);
      final podfileContent = podfile.readAsStringSync();
      expect(podfileContent, contains("platform :ios, '15.0'"));
      expect(podfileContent, contains('flutter_install_all_ios_pods'));

      final infoPlist = File('ios/Runner/Info.plist');
      expect(infoPlist.existsSync(), isTrue);
      final plistContent = infoPlist.readAsStringSync();
      expect(plistContent, contains('<key>ITSAppUsesNonExemptEncryption</key>'));
    });
  });
}
