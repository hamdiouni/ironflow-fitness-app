import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';

void main() {
  group('MuscleRegion Canonical Model Tests', () {
    test('contains exactly 20 anatomical muscle regions', () {
      expect(MuscleRegion.values.length, 20);
    });

    test('all regions have unique IDs, non-empty display and anatomical names', () {
      final ids = <String>{};
      for (final region in MuscleRegion.values) {
        expect(region.id.isNotEmpty, isTrue);
        expect(region.displayName.isNotEmpty, isTrue);
        expect(region.anatomicalName.isNotEmpty, isTrue);
        expect(ids.add(region.id), isTrue, reason: 'Duplicate ID: ${region.id}');
        expect(region.baseRecoveryHours, inInclusiveRange(36, 96));
      }
    });

    test('frontRegions and backRegions partition canonical regions properly', () {
      expect(MuscleRegion.frontRegions.isNotEmpty, isTrue);
      expect(MuscleRegion.backRegions.isNotEmpty, isTrue);

      for (final region in MuscleRegion.frontRegions) {
        expect(region.isFront, isTrue);
      }
      for (final region in MuscleRegion.backRegions) {
        expect(region.isBack, isTrue);
      }

      // Every region is either visible from front or back (or both)
      for (final region in MuscleRegion.values) {
        final inFront = MuscleRegion.frontRegions.contains(region);
        final inBack = MuscleRegion.backRegions.contains(region);
        expect(inFront || inBack, isTrue,
            reason: '${region.id} is neither in front nor back views');
      }
    });

    test('fromId correctly resolves canonical IDs and snake_case / kebab-case variants', () {
      expect(MuscleRegion.fromId('chest'), MuscleRegion.chest);
      expect(MuscleRegion.fromId('frontDelts'), MuscleRegion.frontDelts);
      expect(MuscleRegion.fromId('front_delts'), MuscleRegion.frontDelts);
      expect(MuscleRegion.fromId('front-delts'), MuscleRegion.frontDelts);
      expect(MuscleRegion.fromId('upperAbs'), MuscleRegion.upperAbs);
      expect(MuscleRegion.fromId('upper_abs'), MuscleRegion.upperAbs);
      expect(MuscleRegion.fromId('middleBack'), MuscleRegion.middleBack);
      expect(MuscleRegion.fromId('middle_back'), MuscleRegion.middleBack);
      expect(MuscleRegion.fromId('hamstrings'), MuscleRegion.hamstrings);
      expect(MuscleRegion.fromId('non_existent_muscle'), isNull);
      expect(MuscleRegion.fromId(null), isNull);
    });

    test('fromId correctly resolves known legacy catalog aliases', () {
      expect(MuscleRegion.fromId('pecs'), MuscleRegion.chest);
      expect(MuscleRegion.fromId('pectoralis'), MuscleRegion.chest);
      expect(MuscleRegion.fromId('shoulders'), MuscleRegion.frontDelts);
      expect(MuscleRegion.fromId('abs'), MuscleRegion.upperAbs);
      expect(MuscleRegion.fromId('core'), MuscleRegion.upperAbs);
      expect(MuscleRegion.fromId('traps'), MuscleRegion.upperTraps);
      expect(MuscleRegion.fromId('latissimus'), MuscleRegion.lats);
      expect(MuscleRegion.fromId('butt'), MuscleRegion.glutes);
    });
  });
}

