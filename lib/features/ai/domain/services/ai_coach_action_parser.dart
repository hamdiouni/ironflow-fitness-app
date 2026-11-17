import 'dart:convert';

import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';

/// Supported structured AI Coach action types (Wave 7.3 — ADR-003).
enum AiCoachActionType {
  saveProgram('save_program'),
  swapExercise('swap_exercise'),
  logMeal('log_meal');

  const AiCoachActionType(this.wireName);
  final String wireName;

  static AiCoachActionType? fromWireName(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    for (final value in AiCoachActionType.values) {
      if (value.wireName == normalized) return value;
    }
    return null;
  }
}

/// Validated exercise item within a [saveProgram] AI action.
class AiProgramExerciseSpec {
  final String exerciseName;
  final String? canonicalExerciseId;
  final int sets;
  final String reps;
  final int restSeconds;

  const AiProgramExerciseSpec({
    required this.exerciseName,
    this.canonicalExerciseId,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    if (canonicalExerciseId != null) 'canonicalExerciseId': canonicalExerciseId,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
  };
}

/// Validated workout day within a [saveProgram] AI action.
class AiProgramDaySpec {
  final int dayNumber;
  final String name;
  final String focus;
  final bool isRestDay;
  final List<AiProgramExerciseSpec> exercises;

  const AiProgramDaySpec({
    required this.dayNumber,
    required this.name,
    required this.focus,
    this.isRestDay = false,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'name': name,
    'focus': focus,
    'isRestDay': isRestDay,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

/// Immutable, schema-validated structured action extracted from an AI response.
///
/// Never applied automatically — rendered as a `"Tap to apply"` card with
/// ownership checking and 1-tap `Undo` support (Wave 7.3).
class AiCoachAction {
  final String id;
  final AiCoachActionType type;
  final String title;
  final String summary;
  final String? ownerUserId;
  final bool isEstimate;

  // save_program fields
  final String? programName;
  final String? difficulty;
  final int? durationWeeks;
  final List<AiProgramDaySpec> programDays;

  // swap_exercise fields
  final String? fromExercise;
  final String? toExercise;
  final String? toCanonicalExerciseId;
  final int? dayIndex;

  // log_meal fields
  final String? mealName;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatsG;

  const AiCoachAction({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    this.ownerUserId,
    this.isEstimate = false,
    this.programName,
    this.difficulty,
    this.durationWeeks,
    this.programDays = const [],
    this.fromExercise,
    this.toExercise,
    this.toCanonicalExerciseId,
    this.dayIndex,
    this.mealName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatsG,
  });

  /// Verifies that this action is permitted to be applied by [activeUserId].
  bool isOwnedBy(String? activeUserId) {
    final normalizedActive = RecordOwnershipRules.normalizeUserId(activeUserId);
    final normalizedOwner = RecordOwnershipRules.normalizeUserId(ownerUserId);
    if (normalizedOwner == null) return true;
    return normalizedOwner == normalizedActive;
  }
}

/// Result of parsing an AI response into cleaned display markdown + validated actions.
class ParsedAiCoachResponse {
  final String displayMarkdown;
  final List<AiCoachAction> actions;

  const ParsedAiCoachResponse({
    required this.displayMarkdown,
    required this.actions,
  });
}

/// Schema validator and parser for structured AI Coach actions (Wave 7.3).
class AiCoachActionParser {
  const AiCoachActionParser._();

  static final RegExp _jsonFencePattern = RegExp(
    r'```(?:json|ironflow-action)\s*([\s\S]*?)```',
    multiLine: true,
  );

  /// Extracts and schema-validates structured actions from [rawResponse].
  /// Invalid or unauthorized blocks are rejected and omitted from [actions].
  static ParsedAiCoachResponse parse(
    String rawResponse, {
    String? currentUserId,
    bool forceEstimateFlag = false,
  }) {
    if (rawResponse.trim().isEmpty) {
      return const ParsedAiCoachResponse(displayMarkdown: '', actions: []);
    }

    final actions = <AiCoachAction>[];
    var cleaned = rawResponse;
    var index = 0;

    for (final match in _jsonFencePattern.allMatches(rawResponse)) {
      final rawBlock = match.group(1)?.trim() ?? '';
      if (rawBlock.isEmpty) continue;

      try {
        final decoded = jsonDecode(rawBlock);
        final candidates = decoded is List
            ? decoded.whereType<Map<String, dynamic>>().toList()
            : decoded is Map<String, dynamic>
                ? <Map<String, dynamic>>[decoded]
                : const <Map<String, dynamic>>[];

        var matchedAnyValidAction = false;
        for (final map in candidates) {
          final validated = validateActionPayload(
            map,
            currentUserId: currentUserId,
            forceEstimateFlag: forceEstimateFlag,
            fallbackId: 'action_${index++}',
          );
          if (validated != null) {
            actions.add(validated);
            matchedAnyValidAction = true;
          }
        }

        if (matchedAnyValidAction) {
          cleaned = cleaned.replaceFirst(match.group(0)!, '').trim();
        }
      } catch (_) {
        // Non-action JSON block or malformed JSON — ignore and do not execute.
      }
    }

    return ParsedAiCoachResponse(
      displayMarkdown: cleaned.isEmpty ? rawResponse.trim() : cleaned,
      actions: actions,
    );
  }

  /// Validates a single JSON map against the schema for `save_program`,
  /// `swap_exercise`, or `log_meal`, enforcing bounds and ownership.
  static AiCoachAction? validateActionPayload(
    Map<String, dynamic> map, {
    String? currentUserId,
    bool forceEstimateFlag = false,
    String fallbackId = 'action_0',
  }) {
    final rawType = (map['type'] ?? map['action'])?.toString();
    final type = AiCoachActionType.fromWireName(rawType);
    if (type == null) return null;

    // Ownership check: if payload specifies a userId, it must match currentUserId.
    final payloadUserId = map['userId']?.toString();
    if (payloadUserId != null && payloadUserId.trim().isNotEmpty) {
      final normPayload = RecordOwnershipRules.normalizeUserId(payloadUserId);
      final normActive = RecordOwnershipRules.normalizeUserId(currentUserId);
      if (normPayload != null && normPayload != normActive) {
        return null;
      }
    }

    final normalizedOwner = RecordOwnershipRules.normalizeUserId(currentUserId);
    final actionId = (map['id']?.toString().trim().isNotEmpty ?? false)
        ? map['id'].toString().trim()
        : fallbackId;

    switch (type) {
      case AiCoachActionType.saveProgram:
        return _validateSaveProgram(map, actionId, normalizedOwner);
      case AiCoachActionType.swapExercise:
        return _validateSwapExercise(map, actionId, normalizedOwner);
      case AiCoachActionType.logMeal:
        return _validateLogMeal(
          map,
          actionId,
          normalizedOwner,
          forceEstimateFlag: forceEstimateFlag,
        );
    }
  }

  static AiCoachAction? _validateSaveProgram(
    Map<String, dynamic> map,
    String actionId,
    String? ownerUserId,
  ) {
    final programName =
        (map['programName'] ?? map['name'])?.toString().trim() ?? '';
    if (programName.isEmpty || programName.length > 80) return null;

    final rawDays = map['days'];
    if (rawDays is! List || rawDays.isEmpty || rawDays.length > 7) return null;

    final days = <AiProgramDaySpec>[];
    for (var i = 0; i < rawDays.length; i++) {
      final rawDay = rawDays[i];
      if (rawDay is! Map) return null;
      final dayName = (rawDay['name'] ?? 'Day ${i + 1}').toString().trim();
      final focus = (rawDay['focus'] ?? dayName).toString().trim();
      final isRest = rawDay['isRestDay'] == true;

      final rawExercises = rawDay['exercises'];
      final exercises = <AiProgramExerciseSpec>[];
      if (!isRest) {
        if (rawExercises is! List ||
            rawExercises.isEmpty ||
            rawExercises.length > 12) {
          return null;
        }
        for (final rawEx in rawExercises) {
          if (rawEx is! Map) return null;
          final rawExName =
              (rawEx['exerciseName'] ?? rawEx['name'])?.toString().trim() ?? '';
          if (rawExName.isEmpty || rawExName.length > 80) return null;

          final resolvedDef = ExerciseCatalog.getByName(rawExName);
          final canonicalName = resolvedDef?.name ?? rawExName;
          final sets = (rawEx['sets'] is num)
              ? (rawEx['sets'] as num).toInt().clamp(1, 10)
              : 3;
          final reps = (rawEx['reps'] ?? '8-12').toString().trim();
          final restSeconds = (rawEx['restSeconds'] is num)
              ? (rawEx['restSeconds'] as num).toInt().clamp(15, 600)
              : 90;

          exercises.add(
            AiProgramExerciseSpec(
              exerciseName: canonicalName,
              canonicalExerciseId: resolvedDef?.id,
              sets: sets,
              reps: reps.isEmpty ? '8-12' : reps,
              restSeconds: restSeconds,
            ),
          );
        }
      }

      days.add(
        AiProgramDaySpec(
          dayNumber: i + 1,
          name: dayName.isEmpty ? 'Day ${i + 1}' : dayName,
          focus: focus.isEmpty ? 'Full Body' : focus,
          isRestDay: isRest,
          exercises: exercises,
        ),
      );
    }

    final difficulty = (map['difficulty'] ?? 'Intermediate').toString().trim();
    final durationWeeks = (map['durationWeeks'] is num)
        ? (map['durationWeeks'] as num).toInt().clamp(1, 52)
        : 8;

    return AiCoachAction(
      id: actionId,
      type: AiCoachActionType.saveProgram,
      title: 'Save Program: $programName',
      summary: '${days.length}-day split · $difficulty · $durationWeeks weeks',
      ownerUserId: ownerUserId,
      programName: programName,
      difficulty: difficulty,
      durationWeeks: durationWeeks,
      programDays: days,
    );
  }

  static AiCoachAction? _validateSwapExercise(
    Map<String, dynamic> map,
    String actionId,
    String? ownerUserId,
  ) {
    final fromRaw =
        (map['fromExercise'] ?? map['from'])?.toString().trim() ?? '';
    final toRaw = (map['toExercise'] ?? map['to'])?.toString().trim() ?? '';
    if (fromRaw.isEmpty || toRaw.isEmpty) return null;
    if (fromRaw.length > 80 || toRaw.length > 80) return null;

    final resolvedFrom = ExerciseCatalog.getByName(fromRaw);
    final resolvedTo = ExerciseCatalog.getByName(toRaw);
    final fromName = resolvedFrom?.name ?? fromRaw;
    final toName = resolvedTo?.name ?? toRaw;
    if (fromName.toLowerCase() == toName.toLowerCase()) return null;

    final dayIndex =
        (map['dayIndex'] is num) ? (map['dayIndex'] as num).toInt() : null;

    return AiCoachAction(
      id: actionId,
      type: AiCoachActionType.swapExercise,
      title: 'Swap Exercise',
      summary: '$fromName → $toName',
      ownerUserId: ownerUserId,
      fromExercise: fromName,
      toExercise: toName,
      toCanonicalExerciseId: resolvedTo?.id,
      dayIndex: dayIndex,
    );
  }

  static AiCoachAction? _validateLogMeal(
    Map<String, dynamic> map,
    String actionId,
    String? ownerUserId, {
    bool forceEstimateFlag = false,
  }) {
    final mealName =
        (map['mealName'] ?? map['name'])?.toString().trim() ?? '';
    if (mealName.isEmpty || mealName.length > 100) return null;

    final calories = _parseBoundedDouble(map['calories'], min: 1, max: 5000);
    final proteinG =
        _parseBoundedDouble(map['proteinG'] ?? map['protein'], min: 0, max: 500);
    final carbsG =
        _parseBoundedDouble(map['carbsG'] ?? map['carbs'], min: 0, max: 800);
    final fatsG =
        _parseBoundedDouble(map['fatsG'] ?? map['fats'], min: 0, max: 300);

    if (calories == null ||
        proteinG == null ||
        carbsG == null ||
        fatsG == null) {
      return null;
    }

    final isEstimate = forceEstimateFlag || map['isEstimate'] == true;

    return AiCoachAction(
      id: actionId,
      type: AiCoachActionType.logMeal,
      title: isEstimate ? 'Log Meal Estimate: $mealName' : 'Log Meal: $mealName',
      summary:
          '${calories.round()} kcal · ${proteinG.round()}g P · ${carbsG.round()}g C · ${fatsG.round()}g F${isEstimate ? ' (ESTIMATE)' : ''}',
      ownerUserId: ownerUserId,
      isEstimate: isEstimate,
      mealName: mealName,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatsG: fatsG,
    );
  }

  static double? _parseBoundedDouble(
    Object? raw, {
    required double min,
    required double max,
  }) {
    final double? val = switch (raw) {
      num n => n.toDouble(),
      String s => double.tryParse(s.trim()),
      _ => null,
    };
    if (val == null || val.isNaN || val.isInfinite) return null;
    if (val < min || val > max) return null;
    return val;
  }
}
