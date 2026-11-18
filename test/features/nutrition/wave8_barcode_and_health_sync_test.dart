import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/body/data/services/method_channel_health_gateway.dart';
import 'package:progression_tracker/features/body/domain/services/health_sync_service.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/services/open_food_facts_service.dart';
import 'package:progression_tracker/features/nutrition/presentation/widgets/food_search/barcode_scanner_sheet.dart';
import 'package:progression_tracker/features/settings/presentation/widgets/health_sync_settings_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Candidate 8.2 — OpenFoodFactsService & Barcode Scanner (ADR-008)', () {
    test('normalizes barcodes and validates length and GS1 Modulo-10 check digits', () {
      expect(OpenFoodFactsService.normalizeBarcode(' 07489-2702408-1 '), '0748927024081');
      expect(OpenFoodFactsService.isValidBarcode('0748927024081'), isTrue);
      expect(OpenFoodFactsService.isValidBarcode('12345'), isFalse);
      // Valid EAN-13 check digit (3017620422003 -> check digit 3)
      expect(OpenFoodFactsService.hasValidGtinCheckDigit('3017620422003'), isTrue);
      expect(OpenFoodFactsService.hasValidGtinCheckDigit('3017620422004'), isFalse);
    });

    test('resolves offline verified gym barcodes with zero network calls', () async {
      const service = OpenFoodFactsService();
      final res = await service.lookupBarcode('0748927024081');
      expect(res.found, isTrue);
      expect(res.isFromOfflineCatalog, isTrue);
      expect(res.food, isNotNull);
      expect(res.food!.name, contains('Gold Standard 100% Whey'));
      expect(res.food!.source, OpenFoodFactsService.attributionSource);
      expect(res.food!.proteinPer100g, closeTo(78.8, 0.1));
    });

    test('queries Open Food Facts API v2 and parses nutriments, micros, and fallback kcal', () async {
      final service = OpenFoodFactsService(
        httpGetter: (uri, headers) async {
          expect(headers['User-Agent'], contains('IronFlow/2.0.0'));
          if (uri.path.contains('3017620422003')) {
            return (
              statusCode: 200,
              body: jsonEncode({
                'status': 1,
                'product': {
                  'product_name': 'High Protein Skyr',
                  'brands': 'Siggi',
                  'serving_quantity': 150,
                  'serving_size': '1 pot (150g)',
                  'categories_tags': ['en:dairies', 'en:yogurts'],
                  'nutriments': {
                    'proteins_100g': 11.0,
                    'carbohydrates_100g': 4.0,
                    'fat_100g': 0.2,
                    'fiber_100g': 0.5,
                    'sugars_100g': 3.5,
                    'sodium_100g': 0.045,
                  },
                },
              }),
            );
          }
          return (
            statusCode: 200,
            body: jsonEncode({'status': 0}),
          );
        },
      );

      final found = await service.lookupBarcode('3017620422003');
      expect(found.found, isTrue);
      expect(found.isFromOfflineCatalog, isFalse);
      expect(found.food!.name, 'Siggi High Protein Skyr');
      expect(found.food!.category, FoodCategory.dairy);
      // Fallback calories: 11*4 + 4*4 + 0.2*9 = 44 + 16 + 1.8 = 61.8
      expect(found.food!.caloriesPer100g, closeTo(61.8, 0.1));
      expect(found.food!.servingWeightGrams, 150.0);
      expect(found.food!.microsPer100g?.sodiumMg, closeTo(45.0, 0.1));

      final missing = await service.lookupBarcode('9999999999999');
      expect(missing.found, isFalse);

      final invalid = await service.lookupBarcode('abc');
      expect(invalid.found, isFalse);
    });

    testWidgets('BarcodeScannerSheet looks up barcode and invokes onFoodFound callback', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      FoodItem? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showBarcodeScannerSheet(
                  context,
                  service: const OpenFoodFactsService(),
                  onFoodFound: (food) => selected = food,
                ),
                child: const Text('OPEN SCANNER'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN SCANNER'));
      await tester.pumpAndSettle();

      expect(find.text('BARCODE SCANNER'), findsOneWidget);

      // Test invalid input warning first
      await tester.enterText(find.byKey(const Key('barcode_input_field')), '123');
      await tester.tap(find.byKey(const Key('barcode_lookup_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('barcode_error_card')), findsOneWidget);

      // Tap quick-scan chip for Optimum Nutrition Whey
      await tester.tap(find.byKey(const Key('quick_barcode_0748927024081')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('barcode_result_card')), findsOneWidget);
      expect(
        find.textContaining('Gold Standard 100% Whey'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('barcode_select_food_button')));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'off_0748927024081');
    });
  });

  group('Candidate 8.4 — Health Connect & Apple HealthKit Sync Bridge (ADR-008)', () {
    test('estimates workout active calories and deduplicates remote weight samples', () {
      final kcal = HealthSyncService.estimateWorkoutActiveCalories(
        durationMinutes: 60,
        totalVolumeKg: 10000,
        bodyWeightKg: 80.0,
      );
      // 5.0 * 80 * 1.0 + 10 * 8.5 = 400 + 85 = 485.0
      expect(kcal, closeTo(485.0, 0.1));

      final t0 = DateTime(2026, 11, 18, 8, 0);
      final local = [
        HealthWeightSample(
          id: 'loc_1',
          timestamp: t0,
          weightKg: 80.0,
        ),
      ];
      final remote = [
        // Duplicate within 2 minutes and <0.05kg difference
        HealthWeightSample(
          id: 'rem_dup',
          timestamp: t0.add(const Duration(minutes: 2)),
          weightKg: 80.02,
        ),
        // Novel measurement next day
        HealthWeightSample(
          id: 'rem_new',
          timestamp: t0.add(const Duration(days: 1)),
          weightKg: 79.6,
        ),
      ];

      final filtered = HealthSyncService.filterNewRemoteWeightSamples(
        remoteSamples: remote,
        localSamples: local,
      );
      expect(filtered.length, 1);
      expect(filtered.single.id, 'rem_new');
    });

    test('MethodChannelHealthGateway syncs workouts and two-way weights via simulated bridge and MethodChannel', () async {
      final gateway = MethodChannelHealthGateway(
        debugPlatformOverride: TargetPlatform.android,
      );
      expect(gateway.platformType, HealthPlatformType.androidHealthConnect);

      final iosGateway = MethodChannelHealthGateway(
        debugPlatformOverride: TargetPlatform.iOS,
      );
      expect(iosGateway.platformType, HealthPlatformType.appleHealthKit);

      final service = HealthSyncService(
        gateway: gateway,
        clock: () => DateTime(2026, 11, 18, 12, 0),
      );

      final report = await service.syncNow(
        exportWorkouts: true,
        twoWayWeightSync: true,
        localWorkouts: [
          HealthWorkoutRecord(
            id: 'w1',
            title: 'Push Day',
            startTime: DateTime(2026, 11, 18, 10, 0),
            endTime: DateTime(2026, 11, 18, 11, 0),
            activeEnergyKcal: 420.0,
            totalVolumeKg: 7500.0,
          ),
        ],
        localWeights: [
          HealthWeightSample(
            id: 'lw1',
            timestamp: DateTime(2026, 11, 18, 9, 0),
            weightKg: 78.0,
          ),
        ],
        since: DateTime(2026, 11, 1),
      );

      expect(report.permissionStatus, HealthPermissionStatus.granted);
      expect(report.workoutsExported, 1);
      expect(report.weightSamplesExported, 1);
      expect(report.weightSamplesImported, 1);
      expect(gateway.simulatedWorkouts.length, 1);
      expect(gateway.simulatedWeights.length, 2);

      // Verify disabled directions return early cleanly
      final disabledReport = await service.syncNow(
        exportWorkouts: false,
        twoWayWeightSync: false,
      );
      expect(disabledReport.workoutsExported, 0);
      expect(disabledReport.weightSamplesImported, 0);
    });

    test('MethodChannelHealthGateway handles bound native MethodChannel responses', () async {
      const channel = MethodChannel(MethodChannelHealthGateway.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'checkPermissions':
            return 'notDetermined';
          case 'requestPermissions':
            return 'granted';
          case 'readWeightSamples':
            return [
              {
                'id': 'native_1',
                'timestampMs': DateTime(2026, 11, 18, 7, 0).millisecondsSinceEpoch,
                'weightKg': 77.5,
                'bodyFatPercent': 13.8,
                'source': 'HealthConnect',
              },
            ];
          case 'writeWeightSamples':
            return 1;
          case 'writeWorkouts':
            return 1;
          default:
            return null;
        }
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final gateway = MethodChannelHealthGateway(
        channel: channel,
        debugPlatformOverride: TargetPlatform.android,
      );
      final service = HealthSyncService(gateway: gateway);
      final report = await service.syncNow(
        exportWorkouts: true,
        twoWayWeightSync: true,
        localWorkouts: [
          HealthWorkoutRecord(
            id: 'w_nat',
            title: 'Leg Day',
            startTime: DateTime(2026, 11, 18, 8, 0),
            endTime: DateTime(2026, 11, 18, 9, 0),
            activeEnergyKcal: 500,
            totalVolumeKg: 9000,
          ),
        ],
        localWeights: [
          HealthWeightSample(
            id: 'w_loc',
            timestamp: DateTime(2026, 11, 18, 6, 0),
            weightKg: 77.8,
          ),
        ],
      );

      expect(report.workoutsExported, 1);
      expect(report.weightSamplesExported, 1);
      expect(report.weightSamplesImported, 1);
      expect(report.importedSamples.single.id, 'native_1');
    });

    testWidgets('HealthSyncSettingsSheet toggles directions and runs Sync Now', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showHealthSyncSettingsSheet(context),
                child: const Text('OPEN HEALTH SYNC'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN HEALTH SYNC'));
      await tester.pumpAndSettle();

      expect(find.text('HEALTH CONNECT & HEALTHKIT'), findsOneWidget);
      expect(find.byKey(const Key('health_toggle_export_workouts')), findsOneWidget);
      expect(find.byKey(const Key('health_toggle_weight_sync')), findsOneWidget);

      await tester.tap(find.byKey(const Key('health_sync_now_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('health_sync_report_card')), findsOneWidget);
      expect(find.textContaining('Synced 1 workouts'), findsOneWidget);
    });
  });
}
