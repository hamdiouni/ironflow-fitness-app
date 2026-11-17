import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/data/exercise_video_map.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';

void main() {
  group('ExerciseVideoMap Robustness, oEmbed Allowlist & Coverage (Wave 5.3)', () {
    test('getVideoId resolves standard core exercises with oEmbed-verified IDs', () {
      for (final name in ['bench press', 'squat', 'deadlift', 'overhead press']) {
        final id = ExerciseVideoMap.getVideoId(name);
        expect(id, isNotNull);
        expect(ExerciseVideoMap.verifiedOEmbedIds.contains(id), isTrue);
      }
    });

    test('getVideoId resolves case, whitespace, hyphens, and spaces', () {
      final pullUpHyphen = ExerciseVideoMap.getVideoId('pull-up');
      final pullUpSpace = ExerciseVideoMap.getVideoId('pull up');
      final pullUpUpper = ExerciseVideoMap.getVideoId('  PULL UP  ');

      expect(pullUpHyphen, isNotNull);
      expect(pullUpSpace, pullUpHyphen);
      expect(pullUpUpper, pullUpHyphen);

      final pushUpHyphen = ExerciseVideoMap.getVideoId('push-up');
      final pushUpSpace = ExerciseVideoMap.getVideoId('push up');
      expect(pushUpHyphen, isNotNull);
      expect(pushUpSpace, pushUpHyphen);
    });

    test('getVideoId resolves common exercise aliases', () {
      final alias1 = ExerciseVideoMap.getVideoId('Barbell Bench Press');
      final alias2 = ExerciseVideoMap.getVideoId('Flat Bench Press');
      final target = ExerciseVideoMap.getVideoId('Bench Press');

      expect(alias1, target);
      expect(alias2, target);

      expect(
        ExerciseVideoMap.getVideoId('Barbell Squat'),
        ExerciseVideoMap.getVideoId('Squat'),
      );
      expect(
        ExerciseVideoMap.getVideoId('chin up'),
        ExerciseVideoMap.getVideoId('pull-up'),
      );
    });

    test('dead 404 YouTube IDs are excluded and return null so UI falls back to steps', () {
      // Previously mapped to 404 IDs (ASdvSXt_IIo, NIKnFMKHHKA, EdtPAT0oCqQ, etc.)
      expect(ExerciseVideoMap.getVideoId('plank'), isNull);
      expect(ExerciseVideoMap.getVideoId('skull crusher'), isNull);
      expect(ExerciseVideoMap.getVideoId('hack squat'), isNull);
      expect(ExerciseVideoMap.getVideoId('Hyperdrive Warp Drive 9000'), isNull);
    });

    test('getCoachVideoIds returns Coach 1 and Coach 2 for deadlift', () {
      final deadliftCoaches = ExerciseVideoMap.getCoachVideoIds('Deadlift');
      expect(deadliftCoaches, equals(['op9kVnSso6Q', 'r4MzxtBKyNE']));
    });

    test('measureCoverage reports exact honest numbers across the 129 canonical exercises', () {
      final names = ExerciseCatalog.all.map((e) => e.name).toList();
      expect(names.length, 129);

      final report = ExerciseVideoMap.measureCoverage(names);
      expect(report.totalCatalogExercises, 129);
      expect(report.uniqueVerifiedYoutubeIds, 40);
      expect(report.coach1CoveredCount, 43);
      expect(report.coach2CoveredCount, greaterThanOrEqualTo(1));
      expect(report.form3dLoopCoveredCount, 0);
      expect(
        report.coach1CoveredCount + report.fallbackToStepsCount,
        equals(129),
      );
    });

    test('thumbnailUrl, watchUrl, and videoUrl return proper URLs', () {
      final benchThumb = ExerciseVideoMap.thumbnailUrl('Bench Press');
      expect(benchThumb.startsWith('https://img.youtube.com/vi/'), isTrue);
      expect(benchThumb.endsWith('/mqdefault.jpg'), isTrue);

      final unknownThumb = ExerciseVideoMap.thumbnailUrl('Unknown Exercise');
      expect(unknownThumb.isNotEmpty, isTrue);

      final watchUrl = ExerciseVideoMap.watchUrl('Bench Press');
      expect(watchUrl, isNotNull);
      expect(watchUrl!.startsWith('https://www.youtube.com/watch?v='), isTrue);

      final embedUrl = ExerciseVideoMap.videoUrl('Bench Press');
      expect(embedUrl, isNotNull);
      expect(embedUrl!.startsWith('https://www.youtube.com/embed/'), isTrue);
    });
  });
}
