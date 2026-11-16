import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_paths.dart';

void main() {
  group('BodyMapPaths Vector Geometry Tests', () {
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

    test('hitTest accurately detects anatomical muscle regions on front view', () {
      // Point in Chest
      final chestHit = BodyMapPaths.hitTest(
        localPosition: const Offset(130, 140),
        isFront: true,
      );
      expect(chestHit, MuscleRegion.chest);

      // Point in Upper Abs
      final absHit = BodyMapPaths.hitTest(
        localPosition: const Offset(140, 175),
        isFront: true,
      );
      expect(absHit, MuscleRegion.upperAbs);

      // Point in Quads
      final quadsHit = BodyMapPaths.hitTest(
        localPosition: const Offset(125, 310),
        isFront: true,
      );
      expect(quadsHit, MuscleRegion.quads);

      // Out of bounds coordinate
      final emptyHit = BodyMapPaths.hitTest(
        localPosition: const Offset(10, 10),
        isFront: true,
      );
      expect(emptyHit, isNull);
    });

    test('hitTest accurately detects anatomical muscle regions on back view', () {
      // Point in Lats
      final latsHit = BodyMapPaths.hitTest(
        localPosition: const Offset(124, 180),
        isFront: false,
      );
      expect(latsHit, MuscleRegion.lats);

      // Point in Glutes
      final glutesHit = BodyMapPaths.hitTest(
        localPosition: const Offset(126, 290),
        isFront: false,
      );
      expect(glutesHit, MuscleRegion.glutes);

      // Out of bounds coordinate
      final emptyHit = BodyMapPaths.hitTest(
        localPosition: const Offset(5, 5),
        isFront: false,
      );
      expect(emptyHit, isNull);
    });
  });
}
