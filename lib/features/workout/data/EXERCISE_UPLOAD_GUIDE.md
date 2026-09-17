# Exercise Database Upload Guide

## Overview

This guide explains how to upload the 150+ exercises from the local exercise database to Firestore.

## Exercise Database Structure

- **Location**: `lib/features/workout/data/exercise_database.dart`
- **Total Exercises**: 150+
- **Organization**: By muscle group (Chest, Back, Legs, Shoulders, Arms, Abs, Cardio, Glutes, Full Body)

### Exercise Fields

Each exercise contains:
- `id`: Unique identifier (e.g., 'chest_001')
- `name`: Exercise name
- `muscleGroup`: Primary muscle group (enum)
- `subMuscle`: Secondary muscle group description
- `equipment`: Equipment type (barbell, dumbbell, machine, bodyweight, cable, kettlebell, band)
- `difficulty`: Difficulty level (beginner, intermediate, advanced)
- `imageUrl`: URL to exercise image
- `animationUrl`: URL to exercise animation/video
- `instructions`: Text instructions for performing the exercise
- `primaryMuscles`: List of muscles worked

## Firestore Schema

Exercises are stored in the `exercises` collection with the following structure:

```
exercises/
  {exerciseId}: {
    id: string
    name: string
    muscleGroup: string (enum name)
    subMuscle: string
    equipment: string (enum name)
    difficulty: string (enum name)
    imageUrl: string
    animationUrl: string
    instructions: string
    primaryMuscles: string[] (enum names)
    createdAt: timestamp
  }
```

## Upload Methods

### Method 1: Programmatic Upload (Recommended)

Use the `uploadAllExercisesToFirestore()` function from `exercise_upload_script.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progression_tracker/features/workout/data/datasources/exercise_upload_script.dart';

// Upload all exercises
final firestore = FirebaseFirestore.instance;
await uploadAllExercisesToFirestore(firestore);
```

### Method 2: Using the Provider

Use the Riverpod provider to trigger upload from the UI:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/workout/presentation/providers/exercise_provider.dart';

// In a widget
ref.read(exerciseUploadStatusProvider.notifier).uploadExercises();
```

### Method 3: Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to Firestore Database
4. Create a new collection called `exercises`
5. Manually add documents (not recommended for 150+ exercises)

## Handling Duplicate IDs

**Note**: The local exercise database contains some duplicate IDs (27 duplicates). The upload script automatically handles this by:

1. Detecting duplicate IDs
2. Appending a counter suffix (e.g., `chest_009_1`, `chest_009_2`)
3. Ensuring all Firestore documents have unique IDs

This allows the local database to remain unchanged while ensuring Firestore data integrity.

## Verification

After upload, verify the exercises are in Firestore:

```dart
import 'package:progression_tracker/features/workout/data/datasources/exercise_upload_script.dart';

// Verify all exercises are uploaded
final isValid = await verifyExercisesInFirestore(firestore);
if (isValid) {
  print('✓ All exercises verified successfully!');
}
```

## Retrieval

Once uploaded, retrieve exercises from Firestore:

```dart
import 'package:progression_tracker/features/workout/presentation/providers/exercise_provider.dart';

// Get all exercises
final exercises = await ref.watch(allExercisesProvider);

// Get exercises by muscle group
final chestExercises = await ref.watch(
  exercisesByMuscleGroupProvider('chest')
);

// Search exercises
final results = await ref.watch(
  searchExercisesProvider('bench')
);

// Get single exercise
final exercise = await ref.watch(
  exerciseByIdProvider('chest_001')
);
```

## Firestore Security Rules

Ensure your Firestore security rules allow reading the exercises collection:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read exercises
    match /exercises/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

## Troubleshooting

### Upload Fails with Permission Error
- Ensure you're authenticated with admin privileges
- Check Firestore security rules
- Verify Firebase project is properly configured

### Exercises Not Appearing in Firestore
- Check that the upload completed without errors
- Verify the `exercises` collection was created
- Check Firestore quota limits

### Duplicate IDs in Firestore
- This is expected and handled by the upload script
- Duplicates are suffixed with `_1`, `_2`, etc.
- The original ID is preserved in the `id` field

## Performance Notes

- Uploading 150+ exercises uses batch writes for efficiency
- Batch operations are limited to 500 writes per batch
- The script automatically handles batching
- Typical upload time: 2-5 seconds

## Next Steps

After uploading exercises:

1. **Implement Local Caching** (Task 3.6)
   - Cache exercises locally for offline access
   - Implement cache invalidation strategy

2. **Create Exercise Picker UI** (Task 3.4)
   - Display exercises in grid view
   - Add search and filter functionality

3. **Implement Exercise Details** (Task 3.5)
   - Show exercise images and videos
   - Display instructions and common mistakes

## References

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)
- [Exercise Database](./exercise_database.dart)
- [Upload Script](./datasources/exercise_upload_script.dart)
- [Firestore Datasource](./datasources/firestore_exercise_datasource.dart)
