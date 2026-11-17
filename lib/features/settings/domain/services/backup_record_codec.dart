import '../../../body/domain/entities/body_entry.dart';
import '../../../body/domain/entities/measurement_type.dart';
import '../../../nutrition/domain/entities/meal.dart';
import '../../../workout/domain/entities/exercise.dart';
import '../../../workout/domain/entities/exercise_type.dart';
import '../../../workout/domain/entities/set_entry.dart';
import '../../../workout/domain/entities/workout.dart';

/// Pure domain codec for backup, restore, and rollback snapshots.
///
/// Produces and parses canonical schema-v2 JSON maps matching `WorkoutModel`,
/// `MealModel`, and `BodyEntryModel` as well as legacy v1 snake_case backups,
/// without importing data-layer DTOs from the domain layer.
class BackupRecordCodec {
  const BackupRecordCodec._();

  static Map<String, dynamic> workoutToMap(Workout w) => {
        'id': w.id,
        'date': w.date.toIso8601String(),
        'exercises': w.exercises
            .map(
              (e) => {
                'id': e.id,
                'name': e.name,
                'type': e.type.name,
                'sets': e.sets
                    .map(
                      (s) => {
                        'id': s.id,
                        'reps': s.reps,
                        'weight': s.weight,
                        'rpe': s.rpe,
                        'type': s.type.name,
                        'timestamp': s.timestamp.toIso8601String(),
                      },
                    )
                    .toList(),
                'suggestedReps': e.suggestedReps,
                'suggestedSets': e.suggestedSets,
                'exerciseDefinitionId': e.exerciseDefinitionId,
                'supersetGroupId': e.supersetGroupId,
              },
            )
            .toList(),
        'durationSeconds': w.duration.inSeconds,
        'totalVolume': w.totalVolume,
        'caloriesBurned': w.caloriesBurned,
        'userId': w.userId,
        'programId': w.programId,
        'programDayIndex': w.programDayIndex,
        'updatedAt': w.updatedAt?.toIso8601String(),
        'deletedAt': w.deletedAt?.toIso8601String(),
      };

  static Workout parseWorkout(Map<String, dynamic> data) {
    if (data.containsKey('durationSeconds')) {
      final date = DateTime.parse(data['date'] as String);
      final exercisesList = data['exercises'] as List<dynamic>? ?? const [];
      final exercises = exercisesList.map((rawEx) {
        final eMap = Map<String, dynamic>.from(rawEx as Map);
        final rawType = (eMap['type'] as String? ?? 'strength')
            .replaceAll('ExerciseType.', '')
            .toLowerCase();
        final type = ExerciseType.values.firstWhere(
          (t) => t.name.toLowerCase() == rawType,
          orElse: () => ExerciseType.strength,
        );
        final setsList = eMap['sets'] as List<dynamic>? ?? const [];
        final sets = setsList.map((rawSet) {
          final sMap = Map<String, dynamic>.from(rawSet as Map);
          final rawSetType = (sMap['type'] as String? ?? 'normal').toLowerCase();
          return SetEntry(
            id: sMap['id'] as String,
            reps: (sMap['reps'] as num).toInt(),
            weight: (sMap['weight'] as num).toDouble(),
            rpe: (sMap['rpe'] as num?)?.toInt(),
            type: SetType.values.firstWhere(
              (t) => t.name.toLowerCase() == rawSetType,
              orElse: () => SetType.normal,
            ),
            timestamp: DateTime.parse(sMap['timestamp'] as String),
          );
        }).toList();
        return Exercise(
          id: eMap['id'] as String,
          name: eMap['name'] as String,
          type: type,
          sets: sets,
          suggestedReps: (eMap['suggestedReps'] as num?)?.toInt(),
          suggestedSets: (eMap['suggestedSets'] as num?)?.toInt(),
          exerciseDefinitionId: eMap['exerciseDefinitionId'] as String?,
          supersetGroupId: eMap['supersetGroupId'] as String?,
        );
      }).toList();

      return Workout(
        id: data['id'] as String,
        date: date,
        exercises: exercises,
        duration: Duration(seconds: (data['durationSeconds'] as num).toInt()),
        totalVolume: (data['totalVolume'] as num).toDouble(),
        caloriesBurned: (data['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
        userId: data['userId'] as String?,
        programId: data['programId'] as String?,
        programDayIndex: (data['programDayIndex'] as num?)?.toInt(),
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'] as String)
            : null,
        deletedAt: data['deletedAt'] != null
            ? DateTime.parse(data['deletedAt'] as String)
            : null,
      );
    }

    final id = data['id'] as String? ??
        'workout_${DateTime.now().millisecondsSinceEpoch}';
    final dateStr = data['date'] as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    final durationMinutes = (data['duration_minutes'] as num?)?.toInt() ?? 0;
    final totalVolume =
        ((data['total_volume'] ?? data['total_volume_kg']) as num?)
                ?.toDouble() ??
            0.0;
    final caloriesBurned = (data['calories_burned'] as num?)?.toDouble() ?? 0.0;

    final exercisesList = data['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesList.map((eData) {
      final eMap = eData as Map<String, dynamic>;
      final eId =
          eMap['id'] as String? ?? 'ex_${DateTime.now().millisecondsSinceEpoch}';
      final name = eMap['name'] as String? ?? 'Exercise';
      final rawType = (eMap['type'] as String? ?? 'strength')
          .replaceAll('ExerciseType.', '')
          .toLowerCase();
      final type = ExerciseType.values.firstWhere(
        (t) => t.name.toLowerCase() == rawType,
        orElse: () => ExerciseType.strength,
      );

      final setsList = eMap['sets'] as List<dynamic>? ?? [];
      final sets = setsList.asMap().entries.map((entry) {
        final idx = entry.key;
        final sMap = entry.value as Map<String, dynamic>;
        return SetEntry(
          id: sMap['id'] as String? ?? 'set_${idx + 1}',
          reps: (sMap['reps'] as num).toInt(),
          weight: ((sMap['weight'] ?? sMap['weight_kg']) as num).toDouble(),
          rpe: (sMap['rpe'] as num?)?.toInt(),
          timestamp: sMap.containsKey('timestamp') && sMap['timestamp'] != null
              ? DateTime.parse(sMap['timestamp'] as String)
              : date,
        );
      }).toList();

      return Exercise(
        id: eId,
        name: name,
        type: type,
        sets: sets,
      );
    }).toList();

    return Workout(
      id: id,
      date: date,
      exercises: exercises,
      duration: Duration(minutes: durationMinutes),
      totalVolume: totalVolume,
      caloriesBurned: caloriesBurned,
    );
  }

  static Map<String, dynamic> mealToMap(Meal m) => {
        'id': m.id,
        'name': m.name,
        'macros': {
          'calories': m.macros.calories,
          'protein': m.macros.protein,
          'carbs': m.macros.carbs,
          'fats': m.macros.fats,
        },
        'micros': {
          'fiber': m.micros.fiber,
          'sugar': m.micros.sugar,
          'sodium': m.micros.sodium,
          'potassium': m.micros.potassium,
        },
        'vitamins': {
          'vitaminA': m.vitamins.vitaminA,
          'vitaminB': m.vitamins.vitaminB,
          'vitaminC': m.vitamins.vitaminC,
          'vitaminD': m.vitamins.vitaminD,
          'vitaminE': m.vitamins.vitaminE,
        },
        'minerals': {
          'calcium': m.minerals.calcium,
          'iron': m.minerals.iron,
          'magnesium': m.minerals.magnesium,
          'zinc': m.minerals.zinc,
        },
        'timestamp': m.timestamp.toIso8601String(),
        'userId': m.userId,
        'foodItemId': m.foodItemId,
        'updatedAt': m.updatedAt?.toIso8601String(),
        'deletedAt': m.deletedAt?.toIso8601String(),
      };

  static Meal parseMeal(Map<String, dynamic> data) {
    if (data.containsKey('micros') &&
        data.containsKey('vitamins') &&
        data.containsKey('minerals') &&
        data['macros'] is Map &&
        data['timestamp'] is String) {
      try {
        final macrosMap = Map<String, dynamic>.from(data['macros'] as Map);
        final microsMap = Map<String, dynamic>.from(data['micros'] as Map);
        final vitaminsMap = Map<String, dynamic>.from(data['vitamins'] as Map);
        final mineralsMap = Map<String, dynamic>.from(data['minerals'] as Map);
        return Meal(
          id: data['id'] as String,
          name: data['name'] as String,
          macros: MealMacros(
            calories: (macrosMap['calories'] as num).toDouble(),
            protein: (macrosMap['protein'] as num).toDouble(),
            carbs: (macrosMap['carbs'] as num).toDouble(),
            fats: (macrosMap['fats'] as num).toDouble(),
          ),
          micros: MealMicros(
            fiber: (microsMap['fiber'] as num).toDouble(),
            sugar: (microsMap['sugar'] as num).toDouble(),
            sodium: (microsMap['sodium'] as num).toDouble(),
            potassium: (microsMap['potassium'] as num).toDouble(),
          ),
          vitamins: MealVitamins(
            vitaminA: (vitaminsMap['vitaminA'] as num).toDouble(),
            vitaminB: (vitaminsMap['vitaminB'] as num).toDouble(),
            vitaminC: (vitaminsMap['vitaminC'] as num).toDouble(),
            vitaminD: (vitaminsMap['vitaminD'] as num).toDouble(),
            vitaminE: (vitaminsMap['vitaminE'] as num).toDouble(),
          ),
          minerals: MealMinerals(
            calcium: (mineralsMap['calcium'] as num).toDouble(),
            iron: (mineralsMap['iron'] as num).toDouble(),
            magnesium: (mineralsMap['magnesium'] as num).toDouble(),
            zinc: (mineralsMap['zinc'] as num).toDouble(),
          ),
          timestamp: DateTime.parse(data['timestamp'] as String),
          userId: data['userId'] as String?,
          foodItemId: data['foodItemId'] as String?,
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : null,
          deletedAt: data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
        );
      } catch (_) {
        // Fall through to legacy parser.
      }
    }

    final id =
        data['id'] as String? ?? 'meal_${DateTime.now().millisecondsSinceEpoch}';
    final name = data['name'] as String? ?? 'Meal';
    final timestamp = data.containsKey('timestamp') && data['timestamp'] != null
        ? DateTime.parse(data['timestamp'] as String)
        : DateTime.now();

    final macrosMap = data['macros'] as Map<String, dynamic>? ?? {};
    final macros = MealMacros(
      calories: ((data['total_calories'] ?? macrosMap['calories']) as num?)
              ?.toDouble() ??
          0.0,
      protein: ((data['total_protein'] ?? macrosMap['protein']) as num?)
              ?.toDouble() ??
          0.0,
      carbs:
          ((data['total_carbs'] ?? macrosMap['carbs']) as num?)?.toDouble() ??
              0.0,
      fats:
          ((data['total_fats'] ?? macrosMap['fats']) as num?)?.toDouble() ?? 0.0,
    );

    final microsMap = data['micros'] as Map<String, dynamic>?;
    final micros = microsMap != null
        ? MealMicros(
            fiber: (microsMap['fiber'] as num?)?.toDouble() ?? 0.0,
            sugar: (microsMap['sugar'] as num?)?.toDouble() ?? 0.0,
            sodium: (microsMap['sodium'] as num?)?.toDouble() ?? 0.0,
            potassium: (microsMap['potassium'] as num?)?.toDouble() ?? 0.0,
          )
        : const MealMicros(fiber: 0, sugar: 0, sodium: 0, potassium: 0);

    final vitaminsMap = data['vitamins'] as Map<String, dynamic>?;
    final vitamins = vitaminsMap != null
        ? MealVitamins(
            vitaminA: (vitaminsMap['vitaminA'] as num?)?.toDouble() ?? 0.0,
            vitaminB: (vitaminsMap['vitaminB'] as num?)?.toDouble() ?? 0.0,
            vitaminC: (vitaminsMap['vitaminC'] as num?)?.toDouble() ?? 0.0,
            vitaminD: (vitaminsMap['vitaminD'] as num?)?.toDouble() ?? 0.0,
            vitaminE: (vitaminsMap['vitaminE'] as num?)?.toDouble() ?? 0.0,
          )
        : const MealVitamins(
            vitaminA: 0,
            vitaminB: 0,
            vitaminC: 0,
            vitaminD: 0,
            vitaminE: 0,
          );

    final mineralsMap = data['minerals'] as Map<String, dynamic>?;
    final minerals = mineralsMap != null
        ? MealMinerals(
            calcium: (mineralsMap['calcium'] as num?)?.toDouble() ?? 0.0,
            iron: (mineralsMap['iron'] as num?)?.toDouble() ?? 0.0,
            magnesium: (mineralsMap['magnesium'] as num?)?.toDouble() ?? 0.0,
            zinc: (mineralsMap['zinc'] as num?)?.toDouble() ?? 0.0,
          )
        : const MealMinerals(calcium: 0, iron: 0, magnesium: 0, zinc: 0);

    return Meal(
      id: id,
      name: name,
      macros: macros,
      micros: micros,
      vitamins: vitamins,
      minerals: minerals,
      timestamp: timestamp,
    );
  }

  static Map<String, dynamic> bodyEntryToMap(BodyEntry b) => {
        'id': b.id,
        'date': b.date.toIso8601String(),
        'weight': b.weight,
        'measurements': b.measurements
            .map((type, value) => MapEntry(type.name, value)),
        'photoPath': b.photoPath,
        'userId': b.userId,
        'updatedAt': b.updatedAt?.toIso8601String(),
        'deletedAt': b.deletedAt?.toIso8601String(),
      };

  static BodyEntry parseBodyEntry(Map<String, dynamic> data) {
    if (data.containsKey('photoPath')) {
      try {
        final rawMeas = Map<String, dynamic>.from(
          data['measurements'] as Map? ?? const {},
        );
        return BodyEntry(
          id: data['id'] as String,
          date: DateTime.parse(data['date'] as String),
          weight: (data['weight'] as num).toDouble(),
          measurements: rawMeas.map(
            (key, value) => MapEntry(
              MeasurementType.values.firstWhere((e) => e.name == key),
              (value as num).toDouble(),
            ),
          ),
          photoPath: data['photoPath'] as String?,
          userId: data['userId'] as String?,
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : null,
          deletedAt: data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
        );
      } catch (_) {
        // Fall through to legacy parser.
      }
    }

    final id =
        data['id'] as String? ?? 'body_${DateTime.now().millisecondsSinceEpoch}';
    final dateStr = data['date'] as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    final weight = (data['weight'] as num).toDouble();
    final photoPath = data['photo_path'] as String?;

    final rawMeasurements = data['measurements'] as Map<dynamic, dynamic>? ?? {};
    final measurements = <MeasurementType, double>{};
    for (final entry in rawMeasurements.entries) {
      final keyStr = entry.key.toString();
      final val = (entry.value as num?)?.toDouble();
      if (val != null) {
        for (final type in MeasurementType.values) {
          if (type.name.toLowerCase() == keyStr.toLowerCase()) {
            measurements[type] = val;
            break;
          }
        }
      }
    }

    return BodyEntry(
      id: id,
      date: date,
      weight: weight,
      measurements: measurements,
      photoPath: photoPath,
    );
  }
}

