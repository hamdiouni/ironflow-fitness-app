# Audit Track L — Exercise & Muscle Data Quality (Body Map Prerequisite)

> Measured audit of `lib/features/workout/data/exercise_database.dart` (1,904 LOC), `lib/features/workout/domain/entities/exercise_definition.dart`, `lib/features/workout/domain/entities/exercise.dart`, and `lib/features/analytics/data/repositories/analytics_repository_impl.dart`.

## 1. Executive Summary of Findings

| Metric | Measured Value | Impact on Body Map (Wave 4) |
| :--- | :---: | :--- |
| **Total `ExerciseDefinition` entries** | **150** | Sufficient base catalog size, but contains severe ID/name collisions. |
| **Unique `id` values** | **123** (**27 duplicate IDs!**) | **CRITICAL BLOCKER (P0/P1)**: 27 IDs are assigned to 2 different exercises each (54 entries share 27 IDs). Lookups by `exerciseDefinitionId` return the wrong exercise/muscle! |
| **Unique `name` values (case-insensitive)** | **130** (**20 duplicate names!**) | **HIGH**: 20 exercises appear twice (some with the same ID, some with different IDs such as `Assisted Pull-Up` -> `back_009` and `back_013`). |
| **Exercises with `muscleGroup` (primary coarse enum)** | **150 / 150 (100%)** | Uses `MuscleGroup` enum (9 coarse values: `chest`, `back`, `legs`, `shoulders`, `arms`, `abs`, `glutes`, `cardio`, `fullBody`). |
| **Exercises with separate `secondaryMuscles` field** | **0 / 150 (0%)** | **HIGH**: `ExerciseDefinition` has NO `secondaryMuscles` field. Instead, `primaryMuscles: List<MuscleGroup>` mixes the primary muscle group with 0–2 secondary coarse `MuscleGroup`s without weights (primary=1.0 vs secondary=0.5). |
| **Granularity of `MuscleGroup` enum vs Body Map needs (16–22 regions)** | **9 coarse values** vs **33 unnormalized `subMuscle` strings** | `MuscleGroup.arms` merges Biceps, Triceps, and Forearms; `MuscleGroup.legs` merges Quadriceps, Hamstrings, Calves, Adductors, and Abductors; `MuscleGroup.back` merges Lats, Upper Back/Rhomboids, Traps, and Lower Back/Erector Spinae; `MuscleGroup.shoulders` merges Anterior, Lateral, and Posterior Deltoids. |
| **How Workout History References Exercises** | Dual (`exerciseDefinitionId` + `name` fallback) | `Exercise.id` is a random per-session UUID (`StartWorkoutUseCase`). `Exercise.exerciseDefinitionId` (nullable `String?`) was added in Phase 1 / v2 migration, with case-insensitive `Exercise.name` fallback (`analytics_repository_impl.dart:48-50`). |

---

## 2. All 27 Duplicate Exercise IDs in `ExerciseDatabase` (`lib/features/workout/data/exercise_database.dart`)

> Because `ExerciseDatabase.all` contains two entries for each of these 27 IDs, `firstWhere((e) => e.id == id)` silently drops the second exercise (e.g., looking up `glutes_003` for `"Leg Press (Glute Focus)"` resolves to `"Cable Kickback"`, and `abs_006` / `abs_007` have their IDs swapped between `"Hanging Leg Raise"` and `"Ab Wheel Rollout"`!).

| Duplicate `id` | Occurrences | Colliding Exercise Names in `ExerciseDatabase.all` |
| :--- | :---: | :--- |
| `abs_006` | 2 | `Hanging Leg Raise`, `Ab Wheel Rollout` |
| `abs_007` | 2 | `Ab Wheel Rollout`, `Hanging Leg Raise` |
| `abs_008` | 2 | `Decline Sit-Up`, `Decline Sit-Up` |
| `arms_009` | 2 | `Cable Curl`, `Cable Curl` |
| `arms_010` | 2 | `Machine Curl`, `Dips` |
| `back_009` | 2 | `Assisted Pull-Up`, `Machine Row` |
| `back_010` | 2 | `Chin-Up`, `Seal Row` |
| `back_011` | 2 | `Machine Row`, `Inverted Row` |
| `cardio_006` | 2 | `Elliptical Machine`, `Elliptical` |
| `cardio_007` | 2 | `Treadmill`, `Treadmill` |
| `cardio_008` | 2 | `Burpees`, `Swimming` |
| `chest_009` | 2 | `Machine Chest Press`, `Machine Chest Press` |
| `chest_010` | 2 | `Smith Machine Bench Press`, `Smith Machine Bench Press` |
| `glutes_003` | 2 | `Cable Kickback`, `Leg Press (Glute Focus)` |
| `glutes_004` | 2 | `Donkey Kick`, `Smith Machine Hip Thrust` |
| `glutes_005` | 2 | `Step Up`, `Banded Hip Thrust` |
| `glutes_006` | 2 | `Leg Press (Glute Focus)`, `Glute Kickback` |
| `glutes_007` | 2 | `Smith Machine Squat`, `Cable Pull-Through` |
| `glutes_008` | 2 | `Banded Glute Bridge`, `Single-Leg Hip Thrust` |
| `legs_011` | 2 | `Goblet Squat`, `Goblet Squat` |
| `legs_012` | 2 | `Sissy Squat`, `Sissy Squat` |
| `legs_013` | 2 | `Pendulum Squat`, `Pendulum Squat` |
| `legs_014` | 2 | `Leg Abduction`, `Smith Machine Squat` |
| `legs_015` | 2 | `Leg Adduction`, `V-Squat` |
| `shoulders_007` | 2 | `Machine Shoulder Press`, `Machine Shoulder Press` |
| `shoulders_008` | 2 | `Shrug`, `Pike Push-Up` |
| `shoulders_009` | 2 | `Dumbbell Shrug`, `Upright Row` |

---

## 3. All 20 Duplicate Exercise Names in `ExerciseDatabase`

| Normalized Exercise Name | Occurrences | Assigned IDs in `ExerciseDatabase.all` |
| :--- | :---: | :--- |
| `ab wheel rollout` | 2 | `abs_007`, `abs_006` |
| `assisted pull-up` | 2 | `back_009`, `back_013` |
| `battle ropes` | 2 | `specialty_002`, `fullbody_004` |
| `cable curl` | 2 | `arms_009`, `arms_009` |
| `chin-up` | 2 | `back_010`, `back_014` |
| `decline sit-up` | 2 | `abs_008`, `abs_008` |
| `dips` | 2 | `arms_011`, `arms_010` |
| `goblet squat` | 2 | `legs_011`, `legs_011` |
| `hanging leg raise` | 2 | `abs_006`, `abs_007` |
| `kettlebell swing` | 2 | `specialty_001`, `fullbody_003` |
| `leg press (glute focus)` | 2 | `glutes_006`, `glutes_003` |
| `machine chest press` | 2 | `chest_009`, `chest_009` |
| `machine row` | 2 | `back_011`, `back_009` |
| `machine shoulder press` | 2 | `shoulders_007`, `shoulders_007` |
| `pendulum squat` | 2 | `legs_013`, `legs_013` |
| `shrug` | 2 | `shoulders_008`, `shoulders_010` |
| `sissy squat` | 2 | `legs_012`, `legs_012` |
| `smith machine bench press` | 2 | `chest_010`, `chest_010` |
| `smith machine squat` | 2 | `glutes_007`, `legs_014` |
| `treadmill` | 2 | `cardio_007`, `cardio_007` |

---

## 4. Current Muscle Taxonomy Comparison

### 4.1 Coarse `MuscleGroup` Enum Distribution (150 entries)
- `legs`: 26
- `back`: 25
- `chest`: 17
- `cardio`: 17
- `shoulders`: 15
- `arms`: 14
- `glutes`: 14
- `abs`: 11
- `fullBody`: 11

### 4.2 Unnormalized `subMuscle` Strings (33 distinct strings across 150 entries)

> Notice naming collisions that must be normalized into a canonical 18-region `MuscleRegion` enum in Wave 4.3:
> - `"Trapezius"` (3) vs `"Traps"` (1) vs `"Middle Trapezius"` (1)
> - `"Posterior Deltoid"` (1) vs `"Rear Deltoid"` (1)
> - `"Gastrocnemius"` (1) vs `"Calves"` (1)
> - `"Gluteus Maximus"` (13) vs `"Glutes"` (2)
> - Non-anatomical placeholders: `"Full Body"` (23), `"Posterior Chain"` (2), `"Legs"` (1), `"Core"` (1)

| `subMuscle` String | Exercise Count |
| :--- | :---: |
| `Full Body` | 23 |
| `Quadriceps` | 21 |
| `Latissimus Dorsi` | 15 |
| `Gluteus Maximus` | 13 |
| `Pectoralis Major` | 13 |
| `Anterior Deltoid` | 9 |
| `Biceps Brachii` | 7 |
| `Triceps Brachii` | 7 |
| `Rectus Abdominis` | 6 |
| `Lower Rectus Abdominis` | 3 |
| `Trapezius` | 3 |
| `Adductors` | 2 |
| `Erector Spinae` | 2 |
| `Glutes` | 2 |
| `Hamstrings` | 2 |
| `Lateral Deltoid` | 2 |
| `Lower Pectoralis Major` | 2 |
| `Posterior Chain` | 2 |
| `Upper Pectoralis Major` | 2 |
| `Abductors` | 1 |
| `Brachialis` | 1 |
| `Calves` | 1 |
| `Core` | 1 |
| `Gastrocnemius` | 1 |
| `Gluteus Medius` | 1 |
| `Legs` | 1 |
| `Middle Trapezius` | 1 |
| `Obliques` | 1 |
| `Posterior Deltoid` | 1 |
| `Rear Deltoid` | 1 |
| `Rhomboids` | 1 |
| `Transverse Abdominis` | 1 |
| `Traps` | 1 |

---

## 5. Required Remediation Plan (Wave 3.4 & Wave 4.3)

1. **Deduplicate the 20 exact/near-duplicate exercises** (reducing 150 raw entries to **130 unique canonical exercises**) and reassign unique, non-colliding IDs to the 7 distinct exercises that accidentally reused an existing ID (`Leg Press (Glute Focus)`, `Smith Machine Hip Thrust`, `Banded Hip Thrust`, `Seal Row`, `Inverted Row`, `V-Squat`, `Pike Push-Up`, `Upright Row`, `Swimming`, `Glute Kickback`, `Cable Pull-Through`, `Single-Leg Hip Thrust`).
2. **Write a deterministic v3 Hive migration** that inspects historical logged `Exercise` records where `exerciseDefinitionId` is in the 27 colliding IDs and re-links `exerciseDefinitionId` by matching `(exerciseDefinitionId, normalizedName)`.
3. **Define the canonical 18-region `MuscleRegion` enum** (Front: `chest`, `frontDelts`, `sideDelts`, `biceps`, `forearms`, `upperAbs`, `lowerAbs`, `obliques`, `quads`, `adductors`, `tibialis`; Back: `upperTraps`, `middleBack`, `lats`, `lowerBack`, `rearDelts`, `triceps`, `glutes`, `hamstrings`, `calves`) mapped 1-to-1 with the existing 9 coarse `MuscleGroup` values for backward-compatible analytics.
