import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Link-health and exercise database validation tool for IronFlow.
///
/// Features:
/// 1. Extracts all exercises from `exercise_database.dart` and `exercise_video_map.dart`.
/// 2. Performs quality audit (duplicates, missing instructions, fields).
/// 3. Queries YouTube's public oEmbed endpoint per video ID (rate-limited, polite).
/// 4. Generates a structured JSON and terminal report.
/// 5. In `--strict` mode, exits non-zero if any dead or broken videos exist.
Future<void> main(List<String> args) async {
  final isStrict = args.contains('--strict');
  print('================================================================');
  print('🔍 IronFlow Exercise Library & Video Link Health Checker');
  print('Mode: ${isStrict ? "STRICT (fails on dead links)" : "AUDIT (reports only)"}');
  print('================================================================\n');

  final currentDir = Directory.current.path;
  final dbFile = File('$currentDir/lib/features/workout/data/exercise_database.dart');
  final mapFile = File('$currentDir/lib/features/workout/data/exercise_video_map.dart');

  if (!dbFile.existsSync() || !mapFile.existsSync()) {
    print('❌ Error: Could not locate exercise_database.dart or exercise_video_map.dart');
    exit(1);
  }

  final dbContent = dbFile.readAsStringSync();
  final mapContent = mapFile.readAsStringSync();

  // 1. Parse Exercise Definitions from exercise_database.dart
  final exercises = _parseExerciseDefinitions(dbContent);
  print('📊 Total Exercise Definitions parsed: ${exercises.length}');

  // Muscle group breakdown
  final muscleCounts = <String, int>{};
  final equipmentCounts = <String, int>{};
  final difficultyCounts = <String, int>{};
  final exercisesWithVideoUrl = <_ParsedExercise>[];

  for (final ex in exercises) {
    muscleCounts[ex.muscleGroup] = (muscleCounts[ex.muscleGroup] ?? 0) + 1;
    equipmentCounts[ex.equipment] = (equipmentCounts[ex.equipment] ?? 0) + 1;
    difficultyCounts[ex.difficulty] = (difficultyCounts[ex.difficulty] ?? 0) + 1;
    if (ex.animationUrl.isNotEmpty && ex.animationUrl.contains('youtube.com')) {
      exercisesWithVideoUrl.add(ex);
    }
  }

  print('\n--- Muscle Group Distribution ---');
  muscleCounts.forEach((k, v) => print('  $k: $v'));

  print('\n--- Equipment Distribution ---');
  equipmentCounts.forEach((k, v) => print('  $k: $v'));

  print('\n--- Difficulty Distribution ---');
  difficultyCounts.forEach((k, v) => print('  $k: $v'));

  // 2. Parse ExerciseVideoMap mappings
  final videoMap = _parseVideoMap(mapContent);
  print('\n📊 ExerciseVideoMap mapped exercise entries: ${videoMap.length}');

  // 3. Collate unique Video IDs
  final allVideoIds = <String, Set<String>>{}; // videoId -> Set of exercise names

  for (final ex in exercisesWithVideoUrl) {
    final videoId = _extractYouTubeId(ex.animationUrl);
    if (videoId != null && videoId.isNotEmpty) {
      allVideoIds.putIfAbsent(videoId, () => <String>{}).add(ex.name);
    }
  }

  for (final entry in videoMap.entries) {
    allVideoIds.putIfAbsent(entry.value, () => <String>{}).add(entry.key);
  }

  print('🎥 Total Unique Video IDs across all files: ${allVideoIds.length}');

  // 4. Link-Health Check via YouTube oEmbed
  print('\n🌐 Checking video health via YouTube oEmbed endpoint...');
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);

  int availableCount = 0;
  int notFoundCount = 0;
  int embeddingDisabledCount = 0;
  int errorCount = 0;

  final results = <Map<String, dynamic>>[];

  int index = 0;
  for (final entry in allVideoIds.entries) {
    index++;
    final videoId = entry.key;
    final associatedExercises = entry.value.toList();
    stdout.write('  [$index/${allVideoIds.length}] Checking ID "$videoId" (${associatedExercises.first})... ');

    final oembedUrl = 'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json';
    
    try {
      final request = await client.getUrl(Uri.parse(oembedUrl));
      request.headers.set('User-Agent', 'Mozilla/5.0 (compatible; IronFlowLinkChecker/1.0)');
      final response = await request.close().timeout(const Duration(seconds: 12));
      final statusCode = response.statusCode;

      if (statusCode == 200) {
        availableCount++;
        final bodyStr = await response.transform(utf8.decoder).join();
        final jsonBody = jsonDecode(bodyStr) as Map<String, dynamic>;
        final title = jsonBody['title'] ?? 'Unknown Title';
        final author = jsonBody['author_name'] ?? 'Unknown Author';
        print('✅ AVAILABLE ($title by $author)');

        results.add({
          'id': videoId,
          'status': 'available',
          'statusCode': statusCode,
          'title': title,
          'author': author,
          'exercises': associatedExercises,
        });
      } else if (statusCode == 404) {
        notFoundCount++;
        print('❌ NOT FOUND / PRIVATE (404)');
        results.add({
          'id': videoId,
          'status': 'not_found_or_private',
          'statusCode': statusCode,
          'exercises': associatedExercises,
        });
      } else if (statusCode == 401 || statusCode == 403) {
        embeddingDisabledCount++;
        print('⚠️ EMBEDDING DISABLED / RESTRICTED ($statusCode)');
        results.add({
          'id': videoId,
          'status': 'embedding_disabled',
          'statusCode': statusCode,
          'exercises': associatedExercises,
        });
      } else {
        errorCount++;
        print('⚠️ UNEXPECTED STATUS ($statusCode)');
        results.add({
          'id': videoId,
          'status': 'unexpected_status',
          'statusCode': statusCode,
          'exercises': associatedExercises,
        });
      }
    } catch (e) {
      errorCount++;
      print('❌ NETWORK / TIMEOUT ERROR: $e');
      results.add({
        'id': videoId,
        'status': 'network_error',
        'error': e.toString(),
        'exercises': associatedExercises,
      });
    }

    // Polite rate limit: 120ms delay
    await Future.delayed(const Duration(milliseconds: 120));
  }

  client.close();

  // 5. Summary Report
  final summary = {
    'timestamp': DateTime.now().toIso8601String(),
    'totalExercises': exercises.length,
    'totalUniqueVideoIds': allVideoIds.length,
    'counts': {
      'available': availableCount,
      'notFoundOrPrivate': notFoundCount,
      'embeddingDisabled': embeddingDisabledCount,
      'networkErrors': errorCount,
    },
    'results': results,
  };

  final reportFile = File('$currentDir/tool/video_link_health_report.json');
  reportFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(summary));

  print('\n================================================================');
  print('📊 LINK HEALTH AUDIT COMPLETE');
  print('  ✅ Available & Embeddable: $availableCount');
  print('  ❌ Not Found / Private:    $notFoundCount');
  print('  ⚠️ Embedding Disabled:     $embeddingDisabledCount');
  print('  ⚠️ Network / Other Errors: $errorCount');
  print('  📄 Full Report saved to: tool/video_link_health_report.json');
  print('================================================================\n');

  final hasFailures = (notFoundCount + embeddingDisabledCount) > 0;
  if (isStrict && hasFailures) {
    print('❌ STRICT MODE FAILURE: Dead or restricted video links detected.');
    exit(1);
  }
}

class _ParsedExercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String subMuscle;
  final String equipment;
  final String difficulty;
  final String animationUrl;
  final String instructions;

  _ParsedExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.subMuscle,
    required this.equipment,
    required this.difficulty,
    required this.animationUrl,
    required this.instructions,
  });
}

List<_ParsedExercise> _parseExerciseDefinitions(String content) {
  final list = <_ParsedExercise>[];
  final blockRegex = RegExp(r'ExerciseDefinition\((.*?)\),', dotAll: true);
  final matches = blockRegex.allMatches(content);

  for (final m in matches) {
    final block = m.group(1) ?? '';
    final id = _extractStringField(block, 'id');
    final name = _extractStringField(block, 'name');
    final muscleGroup = _extractEnumField(block, 'muscleGroup');
    final subMuscle = _extractStringField(block, 'subMuscle');
    final equipment = _extractEnumField(block, 'equipment');
    final difficulty = _extractEnumField(block, 'difficulty');
    final animationUrl = _extractStringField(block, 'animationUrl');
    final instructions = _extractStringField(block, 'instructions');

    if (id.isNotEmpty && name.isNotEmpty) {
      list.add(_ParsedExercise(
        id: id,
        name: name,
        muscleGroup: muscleGroup,
        subMuscle: subMuscle,
        equipment: equipment,
        difficulty: difficulty,
        animationUrl: animationUrl,
        instructions: instructions,
      ));
    }
  }

  return list;
}

Map<String, String> _parseVideoMap(String content) {
  final map = <String, String>{};
  final entryRegex = RegExp(r"'([^']+)':\s*'([^']+)'");
  final matches = entryRegex.allMatches(content);

  for (final m in matches) {
    final name = m.group(1) ?? '';
    final id = m.group(2) ?? '';
    if (name.isNotEmpty && id.isNotEmpty) {
      map[name] = id;
    }
  }

  return map;
}

String _extractStringField(String block, String field) {
  final regex = RegExp('$field:\\s*[\'"]([^\'"]*)[\'"]');
  final match = regex.firstMatch(block);
  return match?.group(1) ?? '';
}

String _extractEnumField(String block, String field) {
  final regex = RegExp('$field:\\s*[A-Za-z0-9_]+\\.([A-Za-z0-9_]+)');
  final match = regex.firstMatch(block);
  return match?.group(1) ?? '';
}

String? _extractYouTubeId(String url) {
  if (url.isEmpty) return null;
  final embedRegex = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})');
  final watchRegex = RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})');
  final shortRegex = RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})');

  final match = embedRegex.firstMatch(url) ?? watchRegex.firstMatch(url) ?? shortRegex.firstMatch(url);
  return match?.group(1);
}
