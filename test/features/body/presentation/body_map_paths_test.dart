import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_paths.dart';

void main() {
  group('BodyMapPaths Vector Geometry & Complete 20-Region Hit-Test Suite (Wave 5.4)', () {
    test('standard viewBox dimensions are 300 x 520', () {
      expect(BodyMapPaths.viewBoxWidth, 300.0);
      expect(BodyMapPaths.viewBoxHeight, 520.0);
    });

    test('frontRegionPaths contains all front muscle regions with valid paths', () {
      for (final region in MuscleRegion.frontRegions) {
        final paths = BodyMapPaths.frontRegionPaths[region];
        expect(paths, isNotNull, reason: 'Missing front path for ${region.id}');
        expect(paths!.isNotEmpty, isTrue);
        for (final p in paths) {
          final bounds = p.getBounds();
          expect(bounds.width, greaterThan(0));
          expect(bounds.height, greaterThan(0));
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(BodyMapPaths.viewBoxWidth));
          expect(bounds.top, greaterThanOrEqualTo(0));
          expect(bounds.bottom, lessThanOrEqualTo(BodyMapPaths.viewBoxHeight));
        }
      }
    });

    test('backRegionPaths contains all back muscle regions with valid paths', () {
      for (final region in MuscleRegion.backRegions) {
        final paths = BodyMapPaths.backRegionPaths[region];
        expect(paths, isNotNull, reason: 'Missing back path for ${region.id}');
        expect(paths!.isNotEmpty, isTrue);
        for (final p in paths) {
          final bounds = p.getBounds();
          expect(bounds.width, greaterThan(0));
          expect(bounds.height, greaterThan(0));
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(BodyMapPaths.viewBoxWidth));
          expect(bounds.top, greaterThanOrEqualTo(0));
          expect(bounds.bottom, lessThanOrEqualTo(BodyMapPaths.viewBoxHeight));
        }
      }
    });

    test('silhouettes exist and have valid bounding dimensions', () {
      final frontBounds = BodyMapPaths.frontSilhouette.getBounds();
      expect(frontBounds.width, greaterThan(50));
      expect(frontBounds.height, greaterThan(200));

      final backBounds = BodyMapPaths.backSilhouette.getBounds();
      expect(backBounds.width, greaterThan(50));
      expect(backBounds.height, greaterThan(200));
    });

    test('hitTest detects every front muscle region including adductors before quads', () {
      final frontSamples = <MuscleRegion, Offset>{
        MuscleRegion.upperTraps: const Offset(128.0, 99.5),
        MuscleRegion.frontDelts: const Offset(102.8, 128.4),
        MuscleRegion.sideDelts: const Offset(81.0, 146.5),
        MuscleRegion.chest: const Offset(130.0, 140.0),
        MuscleRegion.biceps: const Offset(90.4, 186.0),
        MuscleRegion.forearms: const Offset(80.4, 261.2),
        MuscleRegion.upperAbs: const Offset(140.0, 177.0),
        MuscleRegion.lowerAbs: const Offset(140.5, 227.5),
        MuscleRegion.obliques: const Offset(119.2, 207.6),
        MuscleRegion.adductors: const Offset(142.0, 302.7),
        MuscleRegion.quads: const Offset(122.0, 312.0),
        MuscleRegion.calves: const Offset(119.6, 433.2),
      };

      expect(
        frontSamples.keys.toSet(),
        equals(MuscleRegion.frontRegions.toSet()),
      );

      for (final entry in frontSamples.entries) {
        final hit = BodyMapPaths.hitTest(
          localPosition: entry.value,
          isFront: true,
        );
        expect(
          hit,
          entry.key,
          reason: 'Expected front hitTest at ${entry.value} to resolve ${entry.key.id}, got $hit',
        );
      }

      // Out of bounds coordinate
      expect(
        BodyMapPaths.hitTest(localPosition: const Offset(10, 10), isFront: true),
        isNull,
      );
    });

    test('hitTest detects every back muscle region including abductors before glutes', () {
      final backSamples = <MuscleRegion, Offset>{
        MuscleRegion.upperTraps: const Offset(150.0, 130.7),
        MuscleRegion.middleBack: const Offset(137.0, 187.0),
        MuscleRegion.rearDelts: const Offset(98.5, 133.0),
        MuscleRegion.triceps: const Offset(86.4, 192.0),
        MuscleRegion.forearms: const Offset(80.4, 262.0),
        MuscleRegion.lats: const Offset(120.0, 188.8),
        MuscleRegion.lowerBack: const Offset(150.0, 249.0),
        MuscleRegion.abductors: const Offset(104.5, 286.0),
        MuscleRegion.glutes: const Offset(126.0, 290.0),
        MuscleRegion.hamstrings: const Offset(123.6, 352.0),
        MuscleRegion.calves: const Offset(118.8, 434.4),
      };

      expect(
        backSamples.keys.toSet(),
        equals(MuscleRegion.backRegions.toSet()),
      );

      for (final entry in backSamples.entries) {
        final hit = BodyMapPaths.hitTest(
          localPosition: entry.value,
          isFront: false,
        );
        expect(
          hit,
          entry.key,
          reason: 'Expected back hitTest at ${entry.value} to resolve ${entry.key.id}, got $hit',
        );
      }

      expect(
        BodyMapPaths.hitTest(localPosition: const Offset(10, 10), isFront: false),
        isNull,
      );
    });
  });
}
