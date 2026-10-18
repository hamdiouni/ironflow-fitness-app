import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/data/exercise_video_map.dart';

void main() {
  group('ExerciseVideoMap Robustness & Video Lookup', () {
    test('getVideoId resolves standard core exercises', () {
      expect(ExerciseVideoMap.getVideoId('bench press'), isNotNull);
      expect(ExerciseVideoMap.getVideoId('squat'), isNotNull);
      expect(ExerciseVideoMap.getVideoId('deadlift'), isNotNull);
      expect(ExerciseVideoMap.getVideoId('overhead press'), isNotNull);
    });

    test('getVideoId resolves case, whitespace, hyphens, and spaces', () {
      final pullUpHyphen = ExerciseVideoMap.getVideoId('pull-up');
      final pullUpSpace = ExerciseVideoMap.getVideoId('pull up');
      final pullUpUpper = ExerciseVideoMap.getVideoId('  PULL UP  ');

      expect(pullUpHyphen, isNotNull);
      expect(pullUpSpace, isNotNull);
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

      final squatAlias = ExerciseVideoMap.getVideoId('Barbell Squat');
      expect(squatAlias, ExerciseVideoMap.getVideoId('Squat'));

      final chinUp = ExerciseVideoMap.getVideoId('chin up');
      expect(chinUp, ExerciseVideoMap.getVideoId('pull-up'));
    });

    test('getVideoId returns null for completely unknown non-exercise names', () {
      expect(ExerciseVideoMap.getVideoId('Hyperdrive Warp Drive 9000'), isNull);
    });

    test('thumbnailUrl returns valid YouTube thumbnail URL or fallback', () {
      final benchThumb = ExerciseVideoMap.thumbnailUrl('Bench Press');
      expect(benchThumb.startsWith('https://img.youtube.com/vi/'), isTrue);
      expect(benchThumb.endsWith('/mqdefault.jpg'), isTrue);

      final unknownThumb = ExerciseVideoMap.thumbnailUrl('Unknown Exercise');
      expect(unknownThumb.isNotEmpty, isTrue);
    });

    test('watchUrl and videoUrl return proper URLs', () {
      final watchUrl = ExerciseVideoMap.watchUrl('Bench Press');
      expect(watchUrl, isNotNull);
      expect(watchUrl!.startsWith('https://www.youtube.com/watch?v='), isTrue);

      final embedUrl = ExerciseVideoMap.videoUrl('Bench Press');
      expect(embedUrl, isNotNull);
      expect(embedUrl!.startsWith('https://www.youtube.com/embed/'), isTrue);

      expect(ExerciseVideoMap.watchUrl('Unknown 123'), isNull);
      expect(ExerciseVideoMap.videoUrl('Unknown 123'), isNull);
    });
  });
}
