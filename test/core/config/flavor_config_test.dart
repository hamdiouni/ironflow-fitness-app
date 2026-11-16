import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/config/build_stamp.dart';
import 'package:progression_tracker/core/config/flavor_config.dart';

void main() {
  group('Wave 2.5 & 2.6 — FlavorConfig, JSON Define Files & BuildStamp', () {
    test('AppFlavor.parse resolves dev/staging/production and fails closed to production in release mode', () {
      expect(AppFlavor.parse('dev', isReleaseMode: false), AppFlavor.dev);
      expect(AppFlavor.parse('staging', isReleaseMode: false), AppFlavor.staging);
      expect(AppFlavor.parse('prod', isReleaseMode: false), AppFlavor.production);
      expect(
        AppFlavor.parse('production', isReleaseMode: false),
        AppFlavor.production,
      );

      // Release mode NEVER allows dev flavor
      expect(
        AppFlavor.parse('dev', isReleaseMode: true),
        AppFlavor.production,
      );
      expect(
        AppFlavor.parse('unknown', isReleaseMode: true),
        AppFlavor.production,
      );
    });

    test('FlavorConfig.resolve enforces distinct Firebase projects, app ids, names, icons, and security flags per flavor', () {
      final dev = FlavorConfig.resolve(rawFlavor: 'dev', isReleaseMode: false);
      final staging = FlavorConfig.resolve(
        rawFlavor: 'staging',
        isReleaseMode: false,
      );
      final prod = FlavorConfig.resolve(
        rawFlavor: 'production',
        isReleaseMode: true,
      );

      expect(dev.isDev, isTrue);
      expect(dev.appName, 'IronFlow Dev');
      expect(dev.appIdSuffix, '.dev');
      expect(dev.iconVariant, 'dev');
      expect(dev.firebaseProjectId, 'ironflow-dev');
      expect(dev.showFlavorBanner, isTrue);

      expect(staging.isStaging, isTrue);
      expect(staging.appName, 'IronFlow Staging');
      expect(staging.appIdSuffix, '.staging');
      expect(staging.iconVariant, 'staging');
      expect(staging.firebaseProjectId, 'ironflow-staging');
      expect(staging.useFirebaseAuth, isTrue);
      expect(staging.allowDirectAiKeys, isFalse);
      expect(staging.showFlavorBanner, isTrue);

      expect(prod.isProduction, isTrue);
      expect(prod.appName, 'IronFlow');
      expect(prod.appIdSuffix, isEmpty);
      expect(prod.iconVariant, 'production');
      expect(prod.firebaseProjectId, 'ironflow-5b79d');
      expect(prod.useFirebaseAuth, isTrue);
      expect(prod.allowDirectAiKeys, isFalse);
      expect(prod.appCheckEnforce, isFalse);
      expect(prod.showFlavorBanner, isFalse);
    });

    test('config/dev.json, config/staging.json, and config/production.json exist, contain no secret keys, and isolate dev from production', () {
      final devJson = jsonDecode(
        File('config/dev.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final stagingJson = jsonDecode(
        File('config/staging.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final prodJson = jsonDecode(
        File('config/production.json').readAsStringSync(),
      ) as Map<String, dynamic>;

      expect(devJson['FLAVOR'], 'dev');
      expect(stagingJson['FLAVOR'], 'staging');
      expect(prodJson['FLAVOR'], 'production');

      // Canonical Firebase project alignment & standardized ENFORCE_APP_CHECK flag
      expect(prodJson['FIREBASE_PROJECT_ID'], 'ironflow-5b79d');
      for (final map in [devJson, stagingJson, prodJson]) {
        expect(map.containsKey('ENFORCE_APP_CHECK'), isTrue);
        expect(map['ENFORCE_APP_CHECK'], isFalse);
        expect(map.containsKey('APP_CHECK_ENFORCE'), isFalse);
      }

      // Dev must never reference the production Firebase project or production proxy
      expect(
        devJson['FIREBASE_PROJECT_ID'],
        isNot(equals(prodJson['FIREBASE_PROJECT_ID'])),
      );
      expect(
        devJson['AI_PROXY_URL'],
        isNot(equals(prodJson['AI_PROXY_URL'])),
      );

      // No config file may contain API key fields or literal key prefixes
      for (final map in [devJson, stagingJson, prodJson]) {
        expect(map.containsKey('GEMINI_API_KEY'), isFalse);
        expect(map.containsKey('OPENAI_API_KEY'), isFalse);
        expect(map.containsKey('NVIDIA_API_KEY'), isFalse);
        final serialized = jsonEncode(map);
        expect(serialized.contains('AI' 'za'), isFalse);
        expect(serialized.contains('nv' 'api-'), isFalse);
      }
    });

    test('BuildStamp formats commit SHA, date, version, and flavor deterministically', () {
      final stamp = BuildStamp.fromEnvironment(
        appVersion: '1.1.0+2',
        flavor: 'production',
        gitCommit: 'ca4d06a209d84d5debaa7acb33fa3d7d4c5b880d',
        buildDate: '2026-11-06',
      );

      expect(stamp.shortCommit, 'ca4d06a');
      expect(
        stamp.displayLabel,
        'v1.1.0+2 (production • ca4d06a • 2026-11-06)',
      );
      expect(stamp.toMap(), {
        'app_version': '1.1.0+2',
        'flavor': 'production',
        'git_commit': 'ca4d06a209d84d5debaa7acb33fa3d7d4c5b880d',
        'build_date': '2026-11-06',
      });
    });
  });
}
